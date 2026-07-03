# DevSecOps + GitOps Platform (EKS)

Production-grade CI/CD: Jenkins, SonarQube, Trivy, ArgoCD, EKS, Helm, Prometheus/Grafana

Based on: https://github.com/NotHarshhaa/DevOps-Projects/tree/master/DevOps-Project-40

## Stack

MERN app → Jenkins (CI) → OWASP Dependency Check + SonarQube + Trivy (security/quality) → Docker → ArgoCD (GitOps CD) → AWS EKS + Helm → Redis (caching) → Prometheus/Grafana (monitoring)

## Structure

- `frontend/` — React app
- `backend/` — Node/Express API
- `terraform/` — EKS cluster, VPC, IAM, nodegroups
- `kubernetes/base/` — plain K8s manifests
- `kubernetes/overlays/` — kustomize overlays per env
- `gitops/` — ArgoCD Application manifests
- `jenkins/` — Jenkinsfile(s)
- `monitoring/` — Prometheus + Grafana Helm values
- `scripts/` — install/setup scripts (jenkins, sonarqube, trivy, eksctl)
- `docs/` — architecture notes, diagrams, decisions
