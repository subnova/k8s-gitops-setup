terragrunt = {
  terraform {
    source = "../../../packages//cluster"
  }

  dependencies {
    paths = []
  }

  extra_arguments "no_color" {
    arguments = [
      "-no-color"
    ]
    commands = [
      "init",
    ]
  }

  remote_state {
    backend = "s3"
    config {
      bucket = "daleaws-terraform-states"
      key = "dev/cluster/terraform.tfstate"
      region = "us-east-1"
      encrypt = true
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------

aws_region = "us-east-1"
environment = "dev"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
