variable "cidr_block" {
  type = string
  #default = "10.0.0.0/16"
  description = "Networking CIDR block to be used for the VPC"
}

variable "project_name" {
  type        = string
  description = "Project name to be used to name the resource (name tag)"
}

variable "tags" {
  type = map
  description = "Tags to be added to AWS resources"
}

#A CIDR está declarada como variável no terraform.tfvars