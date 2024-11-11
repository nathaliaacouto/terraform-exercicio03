provider "aws" {
  region = "ca-central-1"
}

# Referenciar VPC existente
data "aws_vpc" "my_vpc" {
  id = "vpc-04644f64fd1bd8b34"
}

# Referenciar Subnet existente
data "aws_subnet" "my_subnet" {
  id = "subnet-0f063c7a7ee981429"
}

# Referenciar Security Groups existentes
data "aws_security_group" "cluster_sg" {
  id = "sg-0a12fd16ac99680c1"
}

data "aws_security_group" "additional_sg" {
  id = "sg-03caf72cde56e0878"
}

# Referenciar Cluster EKS existente
data "aws_eks_cluster" "my_eks" {
  name = "EKSDeepDive"
}

output "eks_cluster_endpoint" {
  value = data.aws_eks_cluster.my_eks.endpoint
}

output "eks_cluster_ca_certificate" {
  value = data.aws_eks_cluster.my_eks.certificate_authority[0].data
}

# Referenciando o EKS Cluster existente
data "aws_eks_cluster" "my_eks" {
  name = "EKSDeepDive"
}

# Referenciar o Role que será usado pelo Node Group
data "aws_iam_role" "node_role" {
  name = "eks-node-role" # Substitua pelo nome da Role adequada para o Node Group
}

# Criar Node Group
resource "aws_eks_node_group" "node_group_dupla" {
  cluster_name    = data.aws_eks_cluster.my_eks.name
  node_group_name = "nodeGroupNumeroDaDupla"
  node_role_arn   = data.aws_iam_role.node_role.arn
  subnet_ids      = [data.aws_subnet.my_subnet.id]

  # Configuração do Node Group
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  # Definir tipo de instância
  instance_types = ["t3.small"]

  # Security Groups (podem incluir o SG do Cluster e adicionais)
  ami_type = "AL2_x86_64" # Amazon Linux 2 para arquitetura x86

  tags = {
    Name = "nodeGroupNumeroDaDupla"
  }
}