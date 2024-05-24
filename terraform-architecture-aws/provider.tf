provider "aws" {
    region = "eu-west-3"
}

##### VPC si besoin #####
module "vpc" {
    source                    = "terraform-aws-modules/vpc/aws"
    version                   = "2.77.0"
    name                      = "vpc"
    cidr                      = "10.0.0.0/16"

    azs                       = ["eu-west-2a", "eu-west-2b"]
    public_subnets            = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets           = ["10.0.11.0/24", "10.0.12.0/24"]

    enable_nat_gateway        = true
    single_nat_gateway        = true 
    public_subnet_tags = {
        Name = "public"
    }
    private_subnet_tags = {
        Name = "private"
    }
}

