Terraform module to provision an EC2 Instance that is running Apache.

Non intended for production use. Just showcasing how to create a public custom module on Terraform Registry


```hcl
terraform {
  
}

provider "aws" {
  region = "us-east-1"
}

module "apache" {
  source = ".//terraform-aws-apache-example"
  vpc_id = "YOUR_VPC_ID"
  my_ip_address = "YOUR_IP_ADDRESS_CIDR_FORMAT(x.x.x.x/x)"
}
```
