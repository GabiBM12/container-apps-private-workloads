# Repo #3 – Azure Container Apps Workloads (CRM API)

This repository deploys and operates application workloads on top of a secure Azure platform foundation built in **Repo #2**.

It demonstrates how a real-world containerised application is:
- Built
- Deployed
- Secured
- Integrated with external services
- Operated via CI/CD

using **Azure-native identity, networking, and security patterns**.

This repo intentionally avoids shortcuts (hardcoded secrets, shared credentials, manual portal configuration) and instead reflects how modern cloud workloads are deployed in production environments.

---

## Repository Scope

**Repo #3 owns the workload layer**, not the underlying platform.

It is responsible for:
- Application infrastructure (Azure Container Apps)
- Workload identities and RBAC
- CI/CD pipelines
- Runtime configuration and secrets
- External service integration
- Application-level verification and debugging

All shared infrastructure (VNet, subnets, Private DNS, guardrails) is owned by **Repo #2** and consumed here via Terraform remote state.

---

## Architecture Overview

- Containerised **CRM API** (FastAPI, Python)
- Deployed to **Azure Container Apps**
- Images stored in **Azure Container Registry**
- Secrets stored in **Azure Key Vault**
- Identity-based access using **Managed Identity**
- CI/CD implemented with **GitHub Actions + OIDC**
- External email service integration (Mailgun)

📄 **Detailed architecture:**  
➡️ [`docs/architecture.md`](docs/architecture.md)

📄 **Security model & threat considerations:**  
➡️ [`docs/security.md`](docs/security.md)

---

## Milestone 1 – Workload State & Platform Integration

### What was implemented

- Dedicated Terraform **remote backend state** (separate key from Repo #2)
- `terraform_remote_state` used to consume platform outputs:
  - VNet and subnet IDs
  - Private DNS zone IDs
  - Shared platform resource IDs
- Dedicated **Resource Group** for workloads
- Clear separation between:
  - Platform ownership (Repo #2)
  - Application ownership (Repo #3)

### Why this matters

This mirrors how real organisations split responsibilities between:
- Platform / Cloud Enablement teams
- Application / Product teams

---

## Milestone 2 – Container App Deployment & Identity-Based Access

The initial test Container App was removed and replaced with a **dedicated CRM workload**.

### Implemented

- Docker image for the CRM API
- Image pushed to **Azure Container Registry**
- Azure Container App deployed with:
  - Application-specific configuration
  - Explicit CPU / memory limits
  - External HTTPS ingress
- **User-assigned managed identity** attached to the Container App
- RBAC assignments:
  - **AcrPull** → image pull at runtime
  - **Storage Blob Data Contributor** → application data access
- Azure Blob Storage accessed **without keys**, using managed identity only
- End-to-end verification via public FQDN (`curl`)

🔐 At no point were secrets, storage keys, or registry credentials stored in:
- Source code
- Terraform state
- GitHub
- Environment files

All access is handled via **Azure AD + RBAC**.

---

## Milestone 3 – CI/CD with GitHub Actions (OIDC)

A two-stage CI/CD pipeline was implemented using **GitHub Actions** and **OIDC-based authentication**.

### CI Stage
- Triggered on:
  - Pull requests
  - Feature branch pushes
- Builds the container image locally
- Does **not** push images
- Safe for untrusted branches

### CD Stage
- Triggered only on:
  - Merge into `main`
  - Manual dispatch
- Protected by **GitHub Environments**
- Requires explicit approval before deployment
- Uses **federated credentials (OIDC)**:
  - No stored Azure secrets
  - No long-lived service principals

### Outcome
- Image is built and pushed to ACR
- Container App is updated to the new image
- Deployment is auditable, gated, and repeatable

---

## Milestone 4 – Key Vault & External Service Integration (Mailgun)

To demonstrate secure external service integration, the application was extended with **Mailgun email support**.

### Implementation Details

- Mailgun API key stored in **Azure Key Vault**
- Key Vault access restricted to private network + trusted identity
- Container App configured with:
  - **Key Vault secret reference**
  - Secret injected as an environment variable at runtime
- No secrets stored in Terraform state or CI/CD

### Application Verification

A dedicated health endpoint was added:

GET /health/mailgun

This endpoint:
	•	Confirms the secret is present at runtime
	•	Returns only presence and length (never the value)
	•	Used to verify Key Vault → Container App → Application flow

Logs and HTTP responses were used to validate:
	•	Identity access
	•	Secret injection
	•	Runtime behaviour


Application Structure

app/
  crm_api/
    main.py        # FastAPI app entrypoint
    routes.py      # API routes (health, contacts, mailgun check)
    config.py      # Environment & settings (Pydantic)
    storage.py     # Azure Blob Storage integration
    models.py      # API models
  Dockerfile
  requirements.txt

The application is intentionally split into small, focused modules, mirroring how larger services are structured in production.

This repo reflects operational troubleshooting, not just successful deployments.

Debugging & Operations

During development, several real issues were encountered and resolved, including:
	•	Image pull failures due to incorrect identity binding
	•	Container App configuration drift from test deployments
	•	Missing runtime environment variables
	•	Incorrect secret references
	•	Application startup failures visible only via logs

Each issue was diagnosed using:
	•	Container App logs
	•	Azure CLI inspection
	•	Revision history
	•	HTTP-based health checks

This repo reflects operational troubleshooting, not just successful deployments.

Why This Project Exists

This repository marks my transition from:

“Learning Azure services”
to
“Operating a real cloud workload end-to-end”

Rather than following a single tutorial, I intentionally:
	•	Built the platform first
	•	Layered workloads on top
	•	Integrated CI/CD
	•	Introduced real security constraints
	•	Debugged failures in a live environment
	•	Documented architectural and security decisions

This is how I learn: build → break → fix → understand → document.

Key Azure Services Used
	•	Azure Container Apps
	•	Azure Container Registry
	•	Azure Key Vault
	•	Azure Storage Accounts
	•	Azure RBAC & Managed Identities
	•	Azure Monitor / Logs
	•	GitHub Actions (OIDC)
	•	Terraform (remote state, modules, environments)