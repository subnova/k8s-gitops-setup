resource "null_resource" "exec" {    
    triggers {
        manifest = "${var.hash}"
    }

    provisioner "local-exec" {
        command = "cat ${var.path} | kubectl apply -f-"

        environment {
            KUBECONFIG = "${var.kubeconfig_file}"
        }
    }
}