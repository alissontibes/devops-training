resource "aws_s3_bucket" "mys3prod" {
  bucket = "tf-dean-bucket-prod"
  acl    = "public-read-write"

  tags = {
    Name        = "bucket"
    Environment = "Prod"
  }
}

resource "aws_instance" "ec2-prod" {
  ami = data.aws_ami.ami.id
  instance_type = "t2.micro"
  availability_zone = "us-east-2b"
  key_name = aws_key_pair.ssh.key_name
  vpc_security_group_ids = [aws_security_group.testmysg.id]
}

resource "aws_instance" "ec2-prod2" {
  ami = data.aws_ami.ami.id
  instance_type = "t2.micro"
  availability_zone = "us-east-2b"
  key_name = aws_key_pair.ssh.key_name
  vpc_security_group_ids = [aws_security_group.testmysg.id]
}

resource "aws_security_group" "testmysg" {
  name = "testmysg2222"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "ssh" {
  key_name = "testpubkey"
  public_key = file("~/testec2.pub")
  tags = {
    env = "prod"
  }
}
resource "null_resource" "provisioner" {
  triggers = {
    public_ip = aws_instance.ec2-prod.public_ip
    public_ip = aws_instance.ec2-prod2.public_ip
  }
  connection {
    type = "ssh"
    host = aws_instance.ec2-prod.public_ip
    user = "ec2-user"
    agent = false
    private_key = file("~/testec2.pem")
  }

  provisioner "remote-exec" {
    inline = ["sudo yum -y update", "sudo yum install -y httpd", "sudo service httpd start", "echo '<!doctype html><html><body><h1>CONGRATS!!..You have configured successfully your remote exec provisioner!</h1></body></html>' | sudo tee /var/www/html/index.html"]
  }
}
