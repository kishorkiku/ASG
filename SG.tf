# Ingress Security Port 22
resource "aws_security_group_rule" "ssh_inbound_access" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sg.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# All OutBound Access
resource "aws_security_group_rule" "all_outbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.sg.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Ingress Security Port 80
resource "aws_security_group_rule" "alb_http_inbound_access" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.alb-sg.id}"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]

}
resource "aws_security_group" "sg" {

  name        = "terraform-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id
  ingress {
        protocol = "tcp"
        security_groups = [aws_security_group.alb-sg.id]
        from_port = 80
        to_port = 80
    }
  tags = {
    Name = "terraform-SG"
  }
}

resource "aws_security_group_rule" "alb_outbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.alb-sg.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group" "alb-sg" {

  name        = "terraformalb-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "terraform-alb-SG"
  }
}

resource "aws_db_security_group" "dbsg" {
  name = "rds_sg"

  ingress {
   protocol ="tcp"
   from_port ="3306"
   to_port = "3306"
 //  cidr_blocks = ["0.0.0.0/0"]
   security_groups = [aws_security_group.sg.id]
    
  }
}