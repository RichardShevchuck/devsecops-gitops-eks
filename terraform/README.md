# terraform — EKS cluster, VPC, IAM, nodegroups

Modular layout: root module wires together `modules/vpc`, `modules/eks`, `modules/iam`.

- `modules/vpc/` — VPC, subnets, IGW/NAT, route tables
- `modules/eks/` — EKS cluster, nodegroups, OIDC provider
- `modules/iam/` — IAM roles/policies for cluster + service accounts (IRSA)
- `backend.tf` — remote state (S3 + DynamoDB), commented out until bucket/table exist
- `terraform.tfvars.example` — copy to `terraform.tfvars` (gitignored) and fill in
