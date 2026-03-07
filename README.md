###################################################
### 🚀 Terraform AWS EKS Network Infrastructure ###
###################################################


Este projeto provisiona a infraestrutura de rede necessária para um cluster Amazon EKS utilizando Terraform.

A arquitetura segue boas práticas de AWS Networking e Kubernetes.

Recursos provisionados:

VPC dedicada

Subnets públicas e privadas

Internet Gateway

NAT Gateway

Route Tables

Multi-AZ networking

Essa infraestrutura serve como base para clusters EKS em produção.

🏗️ Arquitetura

Arquitetura da rede criada:

Internet
   │
Internet Gateway
   │
Public Subnets (Load Balancers)
   │
NAT Gateway
   │
Private Subnets
   │
EKS Worker Nodes

Fluxo de rede:

Internet
   │
Internet Gateway
   │
Public Route Table
   │
Public Subnets
   │
NAT Gateway
   │
Private Route Table
   │
Private Subnets
   │
EKS Nodes
📁 Estrutura do Projeto

Estrutura recomendada usada em projetos Terraform profissionais.

terraform-aws-eks-network/
│
├ terraform/
│   ├ provider.tf
│   ├ variables.tf
│   ├ locals.tf
│   ├ vpc.tf
│   ├ subnets.tf
│   ├ nat.tf
│   ├ routes.tf
│   ├ outputs.tf
│
├ diagrams/
│   └ architecture.png
│
├ .gitignore
│
└ README.md
🌐 VPC Configuration

A VPC utiliza o bloco CIDR:

10.0.0.0/16

Isso permite até 65.536 IPs privados.

Configuração importante habilitada:

resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "eksdevelopment-vpc"
    Environment = "Development"
    Project     = "EKS"
  }
}

Essas opções são necessárias para funcionamento correto do Amazon EKS.

🧱 Subnets

Foram criadas 4 subnets distribuídas em duas Availability Zones.

🌍 Public Subnets
Subnet	AZ	CIDR
Public Subnet 1a	us-east-1a	10.0.1.0/24
Public Subnet 1b	us-east-1b	10.0.2.0/24

Configuração importante:

map_public_ip_on_launch = true

Isso permite que recursos lançados nessas subnets recebam IP público automaticamente.

Essas subnets são usadas para:

Application Load Balancers

Network Load Balancers

Tag necessária para Kubernetes:

"kubernetes.io/role/elb" = "1"
🔒 Private Subnets
Subnet	AZ	CIDR
Private Subnet 1a	us-east-1a	10.0.3.0/24
Private Subnet 1b	us-east-1b	10.0.4.0/24

Configuração importante:

map_public_ip_on_launch = false

Isso garante que nodes do Kubernetes não tenham IP público, aumentando a segurança.

Tag utilizada para Kubernetes:

"kubernetes.io/role/internal-elb" = "1"

Isso permite a criação de Load Balancers internos.

🌍 Internet Gateway

O Internet Gateway (IGW) permite que recursos em subnets públicas se comuniquem com a internet.

Terraform:

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eksdevelopment-igw"
  }
}
🔐 NAT Gateway

O NAT Gateway permite que recursos em subnets privadas tenham acesso de saída à internet.

Isso é necessário para:

baixar imagens do Amazon ECR

acessar AWS APIs

instalar dependências

Arquitetura:

Private Subnet → NAT Gateway → Internet Gateway → Internet

Terraform:

resource "aws_nat_gateway" "eks_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.eks_subnet_public_1a.id

  tags = {
    Name = "eks-nat-gateway"
  }
}
🛣️ Route Tables
Public Route Table

Define a rota padrão para internet:

route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.eks_igw.id
}

Essa route table é associada às subnets públicas.

▶️ Como Executar o Projeto
1️⃣ Clonar o repositório
git clone https://github.com/seu-usuario/terraform-aws-eks-network.git
cd terraform-aws-eks-network/terraform
2️⃣ Inicializar Terraform
terraform init
3️⃣ Verificar plano de execução
terraform plan
4️⃣ Criar infraestrutura
terraform apply
📊 Resultado Esperado

Após executar o Terraform, a AWS terá:

1 VPC

4 subnets

1 Internet Gateway

1 NAT Gateway

Route tables configuradas

Infraestrutura pronta para Amazon EKS

🔐 Boas Práticas Utilizadas

Este projeto segue boas práticas de infraestrutura como código.

Terraform

Infraestrutura declarativa

Código versionado

Reprodutibilidade

AWS Networking

Multi AZ

Separação entre subnets públicas e privadas

Uso de NAT Gateway

CIDR estruturado

Segurança

Nodes em subnets privadas

Sem exposição direta à internet

🚀 Melhorias Futuras

Possíveis melhorias para evoluir o projeto:

Criar cluster Amazon EKS

Adicionar AWS Load Balancer Controller

Implementar Terraform Modules

Usar Remote State no S3

Adicionar DynamoDB Locking

Criar VPC Endpoints

Implementar CI/CD com GitHub Actions

🔐 Remote State (Recomendado)

Para ambientes reais, utilize remote state no S3.

Exemplo:

terraform {
  backend "s3" {
    bucket         = "terraform-state-eks"
    key            = "network/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

Isso permite:

versionamento do state

colaboração entre equipes

state locking

📚 Tecnologias Utilizadas

Terraform

AWS VPC

AWS NAT Gateway

AWS Internet Gateway

Amazon EKS

👨‍💻 Autor

Projeto criado para estudo de:

Terraform

AWS Networking

Arquitetura Kubernetes (EKS)
