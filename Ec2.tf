resource "aws_instance" "instance" {
  count                = 1
  ami                  = data.aws_ami.app_ami.id
  instance_type        = var.instnacetype
  subnet_id            = element(aws_subnet.public_subnet.*.id, count.index)
  security_groups      = [aws_security_group.sg.id, ]
  key_name             = "kishorkiku"
  iam_instance_profile = "admin"


  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache"
  sudo yum install httpd -y
  sudo systemctl start httpd.service
  sudo systemctl start httpd.service
  sudo bash -c 'echo My Instance! > /var/www/html/index.html'
  EOF

  tags = {
    "Name"        = "Instancefrom-terraform"
    "Environment" = "Test"
    "CreatedBy"   = "Terraform"
  }
}



