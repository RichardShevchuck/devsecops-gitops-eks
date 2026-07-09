---
name: tf-wire-module
description: Wires a specified Terraform child module (under terraform/modules/<name>) into the root module — adds outputs.tf entries the module is missing, adds a module block to root main.tf, adds any new root variables.tf entries, adds matching terraform.tfvars entries. Use when user says "wire module X", "connect module X to main", "hook up module X".
---

# Wire Terraform module into root

Input: module name (e.g. `iam`, `eks`).

## Steps

1. Read `terraform/modules/<name>/variables.tf` — list every required input.
2. Read `terraform/modules/<name>/outputs.tf` — check it exposes every
   resource attribute (arn/id/name) another module or root will plausibly
   need. If missing, add output blocks (resource attrs only — never invent
   values).
3. Read root `terraform/main.tf`, `terraform/variables.tf`,
   `terraform/terraform.tfvars`, and outputs.tf of already-wired modules
   (`vpc`, and any others already present in main.tf).
4. For each required input of `<name>`, resolve where its value comes from:
   - If another wired module already outputs a matching value (e.g.
     `vpc_id`, `private_subnet_ids`) → wire as `module.<other>.<output>`.
   - Otherwise → it's a root-level config value: add a `variable` block to
     root `variables.tf` (with description) and an entry in
     `terraform.tfvars` (ask the user for the actual value if it's not
     obvious from existing project context — never invent
     region/CIDR/names/sizing).
5. Insert a `module "<name>" { source = "./modules/<name>" ... }` block into
   root `main.tf`, matching the existing file's style (see the `vpc` block
   already there — comment header, attribute alignment).
6. Do not touch resources inside the target module itself — only its
   `outputs.tf`, and the root's `main.tf` / `variables.tf` /
   `terraform.tfvars` / `outputs.tf` (root outputs.tf only if something the
   module now exposes is worth surfacing at root level, e.g. cluster
   endpoint).
7. Report a short list of what was added/changed per file.
8. Never run `terraform init/plan/apply` — that's the user's call. End by
   suggesting `terraform validate` / `terraform plan`.
