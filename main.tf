provider "aws" {

#region = "${var.aws_region}"
region = var.aws_region
}


#### CREATE VPC ##############

resource "aws_vpc" "test_vpc" {

cidr_block = var.vpc_cidr
enable_dns_support = true
enable_dns_hostnames = true

tags = {
Name = "my_test_vpc"
}

}



#### CREATE INTERNET GATEWAY #############

resource "aws_internet_gateway" "test_vpc_igw" {

#vpc_id = "${aws_vpc.test_vpc.id}"
vpc_id = aws_vpc.test_vpc.id

}



########### CREATE NON-DEFAULT ROUTE TABLE ##############

resource "aws_route_table" "test_route_table" {

vpc_id = aws_vpc.test_vpc.id

route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.test_vpc_igw.id

}
}


########### CREATE DEFAULT ROUTE TABLE ##############


resource "aws_default_route_table" "test_default_route_table" {


default_route_table_id = aws_vpc.test_vpc.default_route_table_id

}


################### CREATE PUBLIC SUBNET ####################

resource "aws_subnet" "public_subnet1" {

vpc_id = aws_vpc.test_vpc.id
cidr_block = var.subnet_cidrs["public1"]
map_public_ip_on_launch = true
availability_zone = data.aws_availability_zones.available.names[0]

tags = {
   
     Name = "publicSubNet-10.0.1.0-usEast-first-available"
}


}


################### CREATE PRIVATE SUBNET ####################

resource "aws_subnet" "private_subnet1" {

vpc_id = aws_vpc.test_vpc.id
cidr_block = var.subnet_cidrs["private1"]
map_public_ip_on_launch = false
availability_zone = data.aws_availability_zones.available.names[1]

tags = {
   
     Name = "privateSubNet-10.0.2.0-usEast-next-available"
}


}

############ CREATE ROUTE TABLE ASSOCIATION FOR PUBLIC SUBNET############

resource "aws_route_table_association" "public1_route_table_association" {

subnet_id = aws_subnet.public_subnet1.id

route_table_id = aws_route_table.test_route_table.id


}



###### CREATE SECURITY GROUP ############

resource "aws_security_group" "test_security_grp" {
        
          name = "test_security_grp"
          description = "test security group to ssh from all world wide web"
          vpc_id = aws_vpc.test_vpc.id
          ingress {
               from_port = 22
               to_port = 22
               protocol = "tcp"
              cidr_blocks = ["0.0.0.0/0"] 
               
                        }

          egress {
               from_port = 22
               to_port = 22
               protocol = "tcp"
              cidr_blocks = ["0.0.0.0/0"] 
               
                        }
}



############ ASSIGN AND USE KEY PAIR ####################

resource "aws_key_pair"  "mykey" {

key_name = "my_public_key"
public_key = file("/root/.ssh/id_rsa.pub")

}

############## CREATE EC2 INSTANCE IN PUBLIC SUBNET ##################

resource "aws_instance" "public_instance" {

          instance_type = var.instance_type
          ami = var.image
          key_name = aws_key_pair.mykey.id
          vpc_security_group_ids = [aws_security_group.test_security_grp.id]
     
          subnet_id = aws_subnet.public_subnet1.id
      
          tags = {
                   Name = "public_instance"
                   
                 }


}



output "PUBLIC_INSTANCE_IP" {

value = aws_instance.public_instance.public_ip


}







