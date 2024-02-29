packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ##ami_name      = "my_first_ami_{{isotime '2006.01.02.15:04:05'}}"
  ami_name = "my_first_ami_${local.timestamp}"
  instance_type = "t2.micro"
  region        = "${var.my_region}"
  source_ami_filter {
    filters = {
      name                = "${var.source_ami_name}"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name    = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
    source = "app_files"
    destination = "/home/ubuntu/"
  }

  provisioner "shell" {
    inline = [
      "ls /home/ubuntu",
      "echo 'Install packages with apt'",
      "sudo apt update -y",
      "sudo apt install python3-pip -y",
      "sudo apt install gcc -y",
      "sudo snap install redis",
      "sudo gcc -o dummyserv dummy_serv.c",
      "echo 'Setup the my app service with system'",
      "sudo cp /home/ubuntu/app_files/myapp.service /etc/systemd/system/myapp.service",
      "sudo systemctl enable myapp",
    ]
  }

  

}

variable "my_region" {
  type = string
  default = "us-east-1"
}

variable "source_ami_name" {
  type = string
  default = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}
