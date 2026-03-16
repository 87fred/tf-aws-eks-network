variable "cidr_block" {
  type        = string
  description = "CIDR block da VPC"
}

variable "project_name" {
  type        = string
  description = "Nome do projeto"
}

variable "tags" {
  type        = map(string)
  description = "Tags padrão da infraestrutura"
}