/*data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Official Canonical (Ubuntu) owner ID


  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

  resource "aws_instance" "example" {
  count         = 3
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  
  tags = {
    Name = "HelloWorld"
  }
}*/

