# Terraform configuration

resource "aws_instance" "web_server" {

  ami= "ami-0cfa91bdbc3be780c"
  instance_type= "t2.micro"
  associate_public_ip_address = true
  tags = {
    Name = "Ubuntu-web-server"
  }
}
