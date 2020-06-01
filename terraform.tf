variable "aws_region" {}
variable "vpc_cidr" {}
data "aws_availability_zones" "available" {}

variable "subnet_cidrs" {
#type = "map"
type = map(string)

}
variable "instance_type" {}
variable "image" {}
