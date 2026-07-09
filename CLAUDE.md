# CLAUDE.md

Guidance for Claude Code when working in this repo.

## Project

Learning project: production-style DevSecOps + GitOps pipeline deploying a MERN
app ("Wanderlust" blog) onto AWS EKS.

Based on: https://github.com/NotHarshhaa/DevOps-Projects/tree/master/DevOps-Project-40

Deviations from the source project (deliberate, keep these):

- **GitHub Actions instead of Jenkins.** No Jenkins master/worker EC2, no
  Jenkins plugins/pipelines. CI and CD both run as GitHub Actions workflows.
- **OIDC everywhere, no long-lived AWS keys.**
  - GitHub Actions → AWS: use `aws-actions/configure-aws-credentials` with an
    OIDC federated IAM role (GitHub's OIDC provider `token.actions.githubusercontent.com`),
    scoped to this repo, instead of storing `AWS_ACCESS_KEY_ID`/`SECRET` as secrets.
  - EKS cluster → AWS services: use the cluster's OIDC provider + IRSA
    (IAM Roles for Service Accounts) for any pod that needs AWS API access
    (e.g. cluster-autoscaler, external-dns, ALB controller), instead of
    node-level IAM roles or static keys.
- Everything else (ArgoCD for GitOps CD, Trivy/OWASP Dependency Check/SonarQube
  for scanning, Prometheus/Grafana for monitoring, Helm for packaging) follows
  the source project.

Owner is learning DevOps hands-on and is driving implementation themselves;
Claude's role is to pair on design decisions, review/write IaC and pipeline
code, and explain the "why," not to silently take over the build. Prefer
explaining trade-offs before writing files when a decision point comes up
(e.g. node group sizing, IRSA policy scope, ArgoCD app-of-apps layout).

## Repo layout

- `frontend/` — React (Vite) app, already functional, has its own Dockerfile
- `backend/` — Node/Express API, Mongo + Redis, already functional, has its own Dockerfile
- `terraform/` — IaC for VPC/EKS/IAM (see status below)
- `kubernetes/base/` — plain manifests (empty, placeholder README only)
- `kubernetes/overlays/` — kustomize per-env overlays (empty, placeholder README only)
- `gitops/` — ArgoCD Application manifests (empty, placeholder README only)
- `jenkins/` — leftover placeholder dir from the source project; **not used**
  since CI/CD is GitHub Actions here. Safe to delete once `.github/workflows/`
  exists, or repurpose as notes.
- `monitoring/` — Prometheus/Grafana Helm values (empty, placeholder README only)
- `scripts/` — setup scripts, e.g. eksctl/tooling helpers (empty, placeholder README only)
- `docs/` — architecture notes (`architecture.md` covers local docker-compose
  wiring + the env var table; keep it updated when the K8s equivalents land)
- `.github/workflows/` — **does not exist yet**, this is where CI/CD lives

## Status — what's done

- App source (frontend + backend) copied in and documented, docker-compose
  local dev flow works, `docs/architecture.md` explains service wiring and
  env vars.
- Terraform scaffold: root module wires `vpc`, `eks`, `iam` child modules
  (currently only `vpc` is actually wired into `main.tf`; `eks`/`iam` modules
  exist but aren't called from root yet — see below).
- `terraform/modules/vpc` — complete: VPC, IGW, 2 public + 2 private subnets
  across 2 AZs, NAT gateway (single, in first public subnet), public/private
  route tables and associations.
- `terraform/modules/eks/main.tf` — only the bare `aws_eks_cluster` resource
  (name, role_arn, vpc_config with private subnets). No node group, no
  cluster OIDC provider, no addons, no security group rules.
- `terraform/modules/iam` — stub only (`main.tf` is a single comment, no
  actual resources yet). Needed: EKS cluster role, node group role, OIDC
  provider + IRSA roles, GitHub Actions OIDC federated role.
- `terraform.tfvars` example values in place (region `us-east-2`, dev CIDRs).

## Status — what's left

Roughly in dependency order:

1. **IAM module**: EKS cluster IAM role + policy attachments, node group IAM
   role + policy attachments (worker node, CNI, ECR read policies).
2. **EKS module**: node group resource, cluster OIDC identity provider
   (`aws_iam_openid_connect_provider` off the cluster's issuer URL), security
   groups/rules as needed, cluster addons (vpc-cni, coredns, kube-proxy).
3. **Wire eks + iam modules into root `main.tf`** (currently only `vpc` is
   called).
4. **GitHub Actions OIDC role**: IAM role trusting
   `token.actions.githubusercontent.com`, scoped via `sub` claim to this repo
   (and branch/environment if you want to restrict prod deploys), permissions
   scoped to what CI actually needs (ECR push, maybe `eks:DescribeCluster`
   for kubeconfig, Terraform state bucket access if CI runs `terraform plan`).
5. **GitHub Actions CI workflow** (replaces Jenkins CI stage), stage order
   matches the source project's diagram: checkout → OWASP Dependency Check →
   SonarQube (code + quality gate) → Trivy filesystem scan → build Docker
   images (frontend/backend) → push to registry (DockerHub or ECR — decide
   which; ECR pairs naturally with the OIDC role above).
6. **GitOps CD side**: Kubernetes manifests (`kubernetes/base` +
   env overlays in `kubernetes/overlays`), ArgoCD installed on the cluster,
   `gitops/` Application manifest(s) pointing at this repo, image tag bump
   step (from CI or a separate workflow) that ArgoCD picks up and syncs.
7. **Monitoring**: Prometheus + Grafana via Helm, values in `monitoring/`,
   plus notification on pipeline completion (source project used Jenkins
   email notify — with GH Actions this is a Slack/email step at the end of
   the CD workflow instead).
8. **Secrets management**: decide how `JWT_SECRET`, Mongo URI, Redis URL
   reach the cluster — Kubernetes `Secret` objects minimum, consider
   External Secrets Operator or Sealed Secrets if going further.
9. Clean up `jenkins/` placeholder once workflows land.

## Conventions

- Terraform: modules take explicit variables, no hardcoded values in
  `modules/*/main.tf` — mirror the existing `vpc` module's style
  (`variables.tf` per module, tags include `Name` + `Environment`).
- Keep `terraform.tfvars` gitignored; the tracked file is the example/template.
- Don't reintroduce Jenkins or static AWS credentials anywhere — that's the
  point of this variant of the project.
