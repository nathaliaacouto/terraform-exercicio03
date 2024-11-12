# Referenciar Security Groups existentes
data "aws_security_group" "cluster_sg" {
  id = "sg-0a12fd16ac99680c1"
}

data "aws_security_group" "additional_sg" {
  id = "sg-03caf72cde56e0878"
}
