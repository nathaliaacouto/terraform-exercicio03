provider "aws" {
  region = "ca-central-1"
}

module "vpc" {
  source = "./vpc/"
}

module "sg"{
  source = "./sg/"
}

# Referenciar Subnet existente
data "aws_subnet" "mcc2_nvc_subnet" {
  id = "subnet-0f063c7a7ee981429"
}

# Referenciar Cluster EKS existente
data "aws_eks_cluster" "mcc2_nvc_eks" {
  name = "EKSDeepDive"
}

output "eks_cluster_endpoint" {
  value = data.aws_eks_cluster.mcc2_nvc_eks.endpoint
}

output "eks_cluster_ca_certificate" {
  value = data.aws_eks_cluster.mcc2_nvc_eks.certificate_authority[0].data
}

data "aws_iam_role" "node_role" {
  name = "EKSDeepDive_NodeGroup_Role_cdcp"
}

# Criar Node Group
resource "aws_eks_node_group" "node_group_mcc2_nvc" {
  cluster_name    = data.aws_eks_cluster.mcc2_nvc_eks.name
  node_group_name = "nodeGroup008"
  node_role_arn   = data.aws_iam_role.node_role.arn
  subnet_ids      = [data.aws_subnet.mcc2_nvc_subnet.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.small"]

  ami_type = "AL2_x86_64" # Amazon Linux 2 para arquitetura x86

  tags = {
    Name = "nodeGroup008"
  }
}

# Configuração do Provider Kubernetes 
provider "kubernetes" {
  host                   = data.aws_eks_cluster.mcc2_nvc_eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.mcc2_nvc_eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.mcc2_nvc_eks.token
}

# Referenciar o Deployment de WordPress no ECR Público
resource "kubernetes_deployment" "wordpress_deployment" {
  metadata {
    name      = "wordpress-mcc2-nvc"
    namespace = "default"
    labels = {
      app = "wordpress-mcc2-nvc"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "wordpress-mcc2-nvc"
      }
    }

    template {
      metadata {
        labels = {
          app = "wordpress-mcc2-nvc"
        }
      }

      spec {
        container {
          name  = "wordpress"
          image = "public.ecr.aws/bitnami/wordpress:latest"  # Imagem pública do ECR (WordPress)
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "wordpress_service" {
  metadata {
    name      = "wordpress-service-mcc2-nvc"
    namespace = "default"
  }

  spec {
    selector = {
      app = "wordpress"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer" 
  }
}

# Obter o token para autenticação com o cluster EKS
data "aws_eks_cluster_auth" "mcc2_nvc_eks" {
  name = data.aws_eks_cluster.mcc2_nvc_eks.name
}