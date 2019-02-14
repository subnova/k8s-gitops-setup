data "local_file" "manifest" {
    filename = "${var.path}"
}

resource "null_resource" "exec" {    
    triggers {
        manifest = "${data.local_file.manifest.content}"
    }

    provisioner "local-exec" {
        command = "kubectl apply -f ${var.path}"

        environment {
            KUBECONFIG = "${var.kubeconfig_file}"
        }
    }
}