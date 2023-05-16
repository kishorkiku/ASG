resource "aws_launch_configuration" "asg-config" {
  image_id = data.aws_ami.app_ami.id
  instance_type = var.instnacetype
  security_groups = ["${aws_security_group.sg.id}"]

  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache"
  sudo yum install httpd -y
  sudo systemctl start httpd.service
  sudo systemctl start httpd.service
  sudo bash -c 'echo My Instance! > /var/www/html/index.html'
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "terraform-asg" {
  Name ="teraform-asg"  
  launch_configuration    = "${aws_launch_configuration.asg-config.id}"
  availability_zones      = ["${data.aws_availability_zones.all.names}"]
  target_group_arns       = ["${aws_lb_target_group.tg.arn}"]
  health_check_type       = "ELB"
  min_size                = "1"
  max_size                = "2"
  tag {
    Name = "Terraform-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = "${aws_autoscaling_group.asg.id}"
  elb                    = "${aws_elb.lb.id}"
}