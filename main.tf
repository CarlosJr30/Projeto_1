#ami da AWS, sistema operacional a ser instalado
data "aws_ami" "ubuntu" {
    most_recent = true
  
    filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
  #Maquina virtual
    filter {
      name   = "virtualization-type"
      values = ["hvm"]
    }
  
    owners = ["099720109477"] # Canonical
  }
  #Criando a instancia
  resource "aws_instance" "Server001" {
    ami           = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    key_name = "elb-terraform" # Insira o nome da chave criada antes.
    subnet_id = var.subnet_terraform
    vpc_security_group_ids = [aws_security_group.permitir_ssh_http.id]
    associate_public_ip_address = true
  
    tags = {
      Name = "Server001"
   # Insira o nome da instância de sua preferência.
    }
  }

  resource "aws_instance" "Server002" {
    ami           = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    key_name = "elb-terraform" # Insira o nome da chave criada antes.
    subnet_id = var.subnet_terraform
    vpc_security_group_ids = [aws_security_group.permitir_ssh_http.id]
    associate_public_ip_address = true
  
    tags = {
      Name = "Server002"
   # Insira o nome da instância de sua preferência.
    }
  }
    
  
  #Variáveis
  variable "terraform_vpc" {
    default = "vpc-0ecf90dd8e33ad1d0" # Orientações para copia da VPC ID abaixo.
  }
  
  variable "subnet_terraform" {
    default = "subnet-0f0821c8fbb88c02d" # Orientações para copia da Subnet ID abaixo.
  }
  
  #Criando grupos de segurança
  resource "aws_security_group" "permitir_ssh_http" {
    name        = "permitir_ssh"
    description = "Permite SSH e HTTP na instancia EC2"
    vpc_id      = var.terraform_vpc
  
    #Liberando portas de entrada
    ingress {
      description = "SSH to EC2"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    ingress {
      description = "HTTP to EC2"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  #Liberando porta de saída
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  #nome do grupo de segurança
    tags = {
      Name = "permitir_ssh_e_http"
    }

    ## Configuração do Load Balance
resource "aws_elb" "this" {
    name = "ec2-elb"
    ## Instâncias a serem registradas - Configuradas acima!
    instances = ["${aws_instance.Server001.id}", "${aws_instance.Server002.id}"]
    availability_zones = ["us-east-1a"]
    
    ## Listener Ports do Load Balance
    listener {
        instance_port = 80
      instance_protocol = "tcp"
      lb_port = 80
      lb_protocol = "tcp"
    }
    
    }
  
    tags {
      Name = "ec2-elb"
    }
  }
