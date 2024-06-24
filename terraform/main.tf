provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "k3s_node" {
  ami           = "ami-08012c0a9ee8e21c4" # Ubuntu
  instance_type = "t2.medium"
  key_name      = var.key_name

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ec2-user",
      "curl -sfL https://get.k3s.io | sh -",
      "sudo chmod 644 /etc/rancher/k3s/k3s.yaml",
      "mkdir -p ~/.kube",
      "sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config",
      "sudo chown $(id -u):$(id -g) ~/.kube/config"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

  tags = {
    Name = "k3s-node"
  }
}

output "instance_public_ip" {
  value = aws_instance.k3s_node.public_ip
}
