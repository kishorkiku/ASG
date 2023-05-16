# Query all avilable Availibility Zone
data "aws_availability_zones" "available" {}

# Query all avilable ami
 
data "aws_ami" "app_ami" {
  most_recent = "true"
  owners = ["amazon"]
 
 filter {
   name = "name"
   values = [ "amzn2-ami-hvm*" ]
 }
}
