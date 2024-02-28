data "aws_vpc" "main" {
  id = var.vpc_id
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCw5djT9AYpmQnwy7BElBQ3cx+dZd++Bvfe8n0Ia5H5iJ4CvSFA6jClZGWwLLLG9I0YsAG2PD9gizxw1v2MBKJ7IA32FyPWEmhizOpO7nIrJkxStb2m9T6lcFsTChdPJmY5PguA8wqYbQoG+oyOWSzEHHjAmkBlj5LtQUC5TacgZEKRQlVtRVEXrgWWGaQFCp5QEK5BnV+Lo7JeKjg7fPqhrTH4/S5dxtsxzADZ3z1eXKARuUVRi1R3q+OFzv4MDK8rnHbkAaFDYB2L9NVsdHn+UsxqbOCKoGDmw2pQB2Ic3p1BbTIbjUu0v56Wpzjn354KpJVNKgPiNa6QQdEWdeB3NNNsKJNw+mBaYYkZslkR7mYwphti9W6wkS3uONl5oTBjCWpwMQ7Du7eKWHYF5zy0wyOHV99Px9dLW0LY1RC2xbSNjQ4u2T8jy3Rna3BnuXZDGuzjuBJ7P9pWRQ6ZDVZqbxXvxQaEbGuqm7xcZXtGqRiSA3npS9PVnNhUqkkLjms= myaath@DESKTOP-TGTUTL2"
}


resource "aws_security_group" "my_server_sg" {
  name        = "my_server_sg"
  description = "Allow traffic to my_server :3"
  vpc_id      = data.aws_vpc.main.id


  tags = {
    Name = "my_server_sg"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
resource "aws_vpc_security_group_ingress_rule" "my_server_sg_http" {
  security_group_id = aws_security_group.my_server_sg.id
  cidr_ipv4         = var.my_ip_address
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "my_server_sg_ssh" {
  security_group_id = aws_security_group.my_server_sg.id
  cidr_ipv4         = var.my_ip_address
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

data "template_file" "user_data" {
  template = file("${abspath(path.module)}/userdata.yaml")
}

resource "aws_instance" "my_server" {
  ami                    = "ami-0a3c3a20c09d6f377"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.my_server_sg.id]
  user_data              = data.template_file.user_data.rendered


  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("terraform")
    host        = self.public_ip
  }


  tags = {
    Name = "My Server ModuleX"
  }
}