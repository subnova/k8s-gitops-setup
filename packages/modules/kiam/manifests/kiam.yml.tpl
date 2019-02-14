---
apiVersion: v1
kind: Secret
metadata:
  name: kiam-server-tls
  namespace: kube-system
  labels:
    app: kiam-server
    role: server
type: Opaque
data:
  "ca.pem": ${CA_PEM}
  "server.pem": ${SERVER_PEM}
  "server-key.pem": ${SERVER_KEY_PEM}
---
apiVersion: v1
kind: Secret
metadata:
  name: kiam-agent-tls
  namespace: kube-system
  labels:
    app: kiam-agent
    role: agent
type: Opaque
data:
  "ca.pem": ${CA_PEM}
  "agent.pem": ${AGENT_PEM}
  "agent-key.pem": ${AGENT_KEY_PEM}
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  namespace: kube-system
  name: kiam-agent
  labels:
    system: kiam
spec:
  selector:
    matchLabels:
      app: kiam-agent
      system: kiam
      role: agent
  template:
    metadata:
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ""
      labels:
        app: kiam-agent
        system: kiam
        role: agent
    spec:
      hostNetwork: true
      dnsPolicy: ClusterFirstWithHostNet
      nodeSelector:
        workload: gp
      volumes:
        - name: ssl-certs
          hostPath:
            # for AWS linux or RHEL distros
            path: /etc/pki/ca-trust/extracted/pem/
            # path: /usr/share/ca-certificates
        - name: tls
          secret:
            secretName: kiam-agent-tls
        - name: xtables
          hostPath:
            path: /run/xtables.lock
      containers:
        - name: kiam
          securityContext:
            privileged: true
            capabilities:
              add: ["NET_ADMIN"]
          image: quay.io/uswitch/kiam:v3.0
          imagePullPolicy: Always
          resources:
            limits:
              memory: 200Mi
              cpu: 200m
            requests:
              cpu: 10m
              memory: 24Mi
          command:
            - /kiam
          args:
            - "agent"
            - "--iptables"
            - "--host-interface=eni+"
            - "--json-log"
            - "--port=8181"
            - "--cert=/etc/kiam/tls/agent.pem"
            - "--key=/etc/kiam/tls/agent-key.pem"
            - "--ca=/etc/kiam/tls/ca.pem"
            - "--server-address=kiam-server:443"
            - "--prometheus-listen-addr=0.0.0.0:9620"
            - "--prometheus-sync-interval=5s"
            - "--gateway-timeout-creation=1s"
          env:
            - name: HOST_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
          volumeMounts:
            - mountPath: /etc/ssl/certs
              name: ssl-certs
            - mountPath: /etc/kiam/tls
              name: tls
            - mountPath: /var/run/xtables.lock
              name: xtables
          livenessProbe:
            httpGet:
              path: /ping
              port: 8181
            initialDelaySeconds: 3
            periodSeconds: 3
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: kube-system
  name: kiam-server
  labels:
    system: kiam
spec:
  replicas: 2
  selector:
    matchLabels:
      app: kiam-server
      system: kiam
      role: server
  template:
    metadata:
      labels:
        app: kiam-server
        system: kiam
        role: server
    spec:
      serviceAccountName: kiam-server
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - topologyKey: kubernetes.io/hostname
      nodeSelector:
        workload: kiam
      tolerations:
        - key: "workload"
          operator: "Equal"
          value: "kiam"
          effect: "NoSchedule"
        - key: "workload"
          operator: "Equal"
          value: "kiam"
          effect: "NoExecute"
      volumes:
        - name: ssl-certs
          hostPath:
            # for AWS linux or RHEL distros
            path: /etc/pki/ca-trust/extracted/pem/
            # path: /usr/share/ca-certificates
            # path: /etc/kubernetes/pki/
        - name: tls
          secret:
            secretName: kiam-server-tls
      containers:
        - name: kiam
          image: quay.io/uswitch/kiam:v3.0
          imagePullPolicy: Always
          resources:
            limits:
              memory: 512Mi
              cpu: 500m
            requests:
              cpu: 200m
              memory: 128Mi
          command:
            - /kiam
          args:
            - "server"
            - "--json-log"
            - "--bind=0.0.0.0:443"
            - "--cert=/etc/kiam/tls/server.pem"
            - "--key=/etc/kiam/tls/server-key.pem"
            - "--ca=/etc/kiam/tls/ca.pem"
            - "--role-base-arn-autodetect"
            - "--sync=1m"
            - "--prometheus-listen-addr=0.0.0.0:9620"
            - "--prometheus-sync-interval=5s"
          env:
            - name: GRPC_GO_LOG_SEVERITY_LEVEL
              value: "info"
            - name: GRPC_GO_LOG_VERBOSITY_LEVEL
              value: "8"
          volumeMounts:
            - mountPath: /etc/ssl/certs
              name: ssl-certs
            - mountPath: /etc/kiam/tls
              name: tls
          livenessProbe:
            exec:
              command:
                - /kiam
                - "health"
                - "--cert=/etc/kiam/tls/server.pem"
                - "--key=/etc/kiam/tls/server-key.pem"
                - "--ca=/etc/kiam/tls/ca.pem"
                - "--server-address=localhost:443"
                - "--gateway-timeout-creation=1s"
                - "--timeout=5s"
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 10
          readinessProbe:
            exec:
              command:
                - /kiam
                - "health"
                - "--cert=/etc/kiam/tls/server.pem"
                - "--key=/etc/kiam/tls/server-key.pem"
                - "--ca=/etc/kiam/tls/ca.pem"
                - "--server-address=localhost:443"
                - "--gateway-timeout-creation=1s"
                - "--timeout=5s"
            initialDelaySeconds: 3
            periodSeconds: 10
            timeoutSeconds: 10
---
kind: ServiceAccount
apiVersion: v1
metadata:
  name: kiam-server
  namespace: kube-system
  labels:
    system: kiam
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: kiam-read
  labels:
    system: kiam
rules:
  - apiGroups:
      - ""
    resources:
      - namespaces
      - pods
    verbs:
      - watch
      - get
      - list
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kiam-server
  labels:
    system: kiam
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kiam-read
subjects:
  - kind: ServiceAccount
    name: kiam-server
    namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  name: kiam-server
  namespace: kube-system
  labels:
    system: kiam
spec:
  clusterIP: None
  selector:
    app: kiam-server
    system: kiam
    role: server
  ports:
    - name: grpclb
      port: 443
      targetPort: 443
      protocol: TCP
