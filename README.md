###################################################
### 🚀 Terraform AWS EKS Network Infrastructure ###
###################################################

Este projeto cria a base de networking necessária para executar clusters Kubernetes (EKS) na AWS, seguindo boas práticas de arquitetura cloud.

A infraestrutura provisionada inclui:

🌐 VPC dedicada  
🌍 Subnets públicas e privadas  
🚪 Internet Gateway  
🔐 NAT Gateway  
🛣️ Route Tables  
🏗️ Arquitetura Multi-AZ  

Essa infraestrutura pode ser usada como fundação para clusters EKS em ambientes reais.

---

# 🏗️ Arquitetura da Infraestrutura

Arquitetura simplificada da rede:

```
Internet
   │
🌍 Internet Gateway
   │
📦 Public Subnets
   │
🔐 NAT Gateway
   │
🔒 Private Subnets
   │
☸️ EKS Worker Nodes
```

Fluxo de comunicação:

```
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
```

---

# 📁 Estrutura do Projeto

Estrutura usada no projeto:

```bash
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
```

---

# 🌐 VPC Configuration

A VPC utiliza o seguinte bloco CIDR:

```
10.0.0.0/16
```

Isso permite aproximadamente **65 mil endereços IP privados**.

Configuração Terraform:

```hcl
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
```

Essas opções são necessárias para o funcionamento do **Amazon EKS**.

---

# 🧱 Subnets

Foram criadas **4 subnets distribuídas em duas Availability Zones**, garantindo alta disponibilidade.

---

## 🌍 Public Subnets

| Subnet | AZ | CIDR |
|------|------|------|
| Public Subnet 1a | us-east-1a | 10.0.1.0/24 |
| Public Subnet 1b | us-east-1b | 10.0.2.0/24 |

Configuração importante:

```hcl
map_public_ip_on_launch = true
```

Isso faz com que recursos nessas subnets recebam **IP público automaticamente**.

Essas subnets são usadas principalmente para:

⚖️ Application Load Balancers  
⚖️ Network Load Balancers  

Tag necessária para Kubernetes:

```hcl
"kubernetes.io/role/elb" = "1"
```

---

## 🔒 Private Subnets

| Subnet | AZ | CIDR |
|------|------|------|
| Private Subnet 1a | us-east-1a | 10.0.3.0/24 |
| Private Subnet 1b | us-east-1b | 10.0.4.0/24 |

Configuração importante:

```hcl
map_public_ip_on_launch = false
```

Isso garante que os nodes do Kubernetes **não tenham IP público**, aumentando a segurança da infraestrutura.

Tag utilizada:

```hcl
"kubernetes.io/role/internal-elb" = "1"
```

Essa tag permite a criação de **Load Balancers internos**.

---

# 🌍 Internet Gateway

O Internet Gateway permite comunicação entre a VPC e a internet.

Terraform:

```hcl
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eksdevelopment-igw"
  }
}
```

---

# 🔐 NAT Gateway

O NAT Gateway permite que recursos em subnets privadas tenham acesso de saída à internet.

Isso é necessário para:

📦 baixar imagens do Amazon ECR  
🔑 acessar APIs da AWS  
⚙️ instalar dependências  

Fluxo:

```
Private Subnet → NAT Gateway → Internet Gateway → Internet
```

Terraform:

```hcl
resource "aws_nat_gateway" "eks_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.eks_subnet_public_1a.id

  tags = {
    Name = "eks-nat-gateway"
  }
}
```

---

# 🛣️ Route Tables

## Public Route Table

Define a rota padrão para internet:

```hcl
route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.eks_igw.id
}
```

Essa route table é associada às **subnets públicas**.

---

# ▶️ Como Executar o Projeto

### 1️⃣ Clonar o repositório

```bash
git clone https://github.com/seu-usuario/terraform-aws-eks-network.git
cd terraform-aws-eks-network/terraform
```

---

### 2️⃣ Inicializar Terraform

```bash
terraform init
```

---

### 3️⃣ Ver plano de execução

```bash
terraform plan
```

---

### 4️⃣ Criar infraestrutura

```bash
terraform apply
```

---

# 📊 Resultado Esperado

Após executar o Terraform, a AWS terá:

✅ 1 VPC  
✅ 4 subnets  
✅ 1 Internet Gateway  
✅ 1 NAT Gateway  
✅ Route tables configuradas  

Infraestrutura pronta para **Amazon EKS**.

---

# 🔐 Boas Práticas Utilizadas

Este projeto segue boas práticas de **Infraestrutura como Código e Cloud Architecture**.

## Terraform

📦 Infraestrutura declarativa  
🧾 Código versionado  
🔁 Deploy reprodutível  

## AWS Networking

🌍 Multi-AZ  
🔒 Subnets públicas e privadas separadas  
🔐 Uso de NAT Gateway  

## Segurança

🚫 Nodes sem IP público  
🔐 Infraestrutura isolada  

---

# 🚀 Melhorias Futuras

Possíveis melhorias para evoluir o projeto:

☸️ Criar cluster Amazon EKS  
⚖️ Adicionar AWS Load Balancer Controller  
🧩 Implementar Terraform Modules  
🗄️ Usar Remote State no S3  
🔒 Adicionar DynamoDB Locking  
🔗 Criar VPC Endpoints  
⚙️ Implementar CI/CD com GitHub Actions  

---

# 📚 Tecnologias Utilizadas

☁️ AWS  
🏗️ Terraform  
☸️ Kubernetes / EKS  
🌐 AWS VPC  

---

# 👨‍💻 Autor

**Frederico de Almeida Morreira**

Projeto criado para estudo e implantação inicial de:

Terraform  
AWS Networking  
Arquitetura Kubernetes (EKS)