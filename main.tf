provider "aws" {
region = "eu-west-1"
}


resource "aws_instance" "web" {
  ami           = "ami-0f29c8402f8cce65c"
  instance_type = "t2.micro"
  key_name      = "your key name"
  user_data     = "${file("httpd.sh")}"
  vpc_security_group_ids = ["${aws_security_group.webSG.id}"]
  tags = {
    Name = "Test-file-provisioner"
  }
  
}

resource "null_resource" "copyhtml" {
  
    connection {
    type = "ssh"
    host = aws_instance.web.public_dns
    user = "ubuntu"
    private_key = "${file("your_private_key.pem")}" 
    }
  
  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"
  }
 
  provisioner "file" {
    source      = "copy.sh"
    destination = "/tmp/copy.sh"
  }
  
  depends_on = [ aws_instance.web ]
  
  }

resource "aws_security_group" "webSG" {
  name        = "webSG"
  description = "Allow ssh  inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
}
