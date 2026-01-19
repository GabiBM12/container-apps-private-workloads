# Security Model – Container Apps Workloads (Repo #3)

This document describes the security architecture, controls, and design decisions applied to the workload layer deployed in this repository.

The focus is on **identity-first access**, **least privilege**, and **removal of long-lived secrets**, aligned with Azure and EU/UK enterprise security expectations.

---

## Security Principles Applied

The following principles guided all design decisions:

1. **Identity over credentials**
2. **Least privilege by default**
3. **Separation of platform and workload responsibilities**
4. **No secrets in code, state, or CI**
5. **Auditability and traceability**
6. **Fail fast and observable**

---

## Threat Model (High Level)

This repository assumes the following realistic threats:

- Source code is public
- CI/CD logs may be visible to contributors
- Infrastructure state files may be accessed by operators
- Application endpoints are internet-facing
- Containers may be compromised at runtime

Security controls are designed to **limit blast radius** even if one layer is compromised.

---

## Identity & Access Management

### Managed Identities (Primary Control)

All workload access is handled using **Azure Managed Identities**.

The Azure Container App is assigned a **user-assigned managed identity**, which is used to authenticate to:

- Azure Container Registry (image pull)
- Azure Blob Storage (application data)
- Azure Key Vault (secret retrieval)

No passwords, keys, or tokens are embedded in:
- Source code
- Docker images
- Terraform state
- CI/CD pipelines

---

### RBAC Assignments

RBAC is scoped **only to required resources**.

| Resource | Role | Purpose |
|-------|------|--------|
| Azure Container Registry | `AcrPull` | Pull container images at runtime |
| Azure Storage Account | `Storage Blob Data Contributor` | Read/write application blobs |
| Azure Key Vault | `Key Vault Secrets User` | Read application secrets |

No wildcard permissions or subscription-level roles are used.

---

## Secrets Management

### Azure Key Vault

All application secrets are stored in **Azure Key Vault**.

Example:
- External email provider (Mailgun) API key

Key Vault protections:
- Access controlled via Azure AD (RBAC)
- No shared secrets
- No Key Vault access keys exposed

---

### Secret Injection Pattern

Secrets are:
1. Stored in Key Vault
2. Referenced in Azure Container App as **secret references**
3. Injected into the container as environment variables **at runtime**

At no point does Terraform or CI/CD handle the secret value itself.

---

### Application-Level Safeguards

The application:
- Validates required environment variables at startup
- Fails fast if a required secret is missing
- Never logs secret values
- Exposes only presence/length checks for verification

Example verification endpoint:
GET /health/mailgun
This confirms secret availability without exposing sensitive data.

CI/CD Security

GitHub Actions Authentication

CI/CD uses OIDC-based federation between GitHub and Azure.
	•	No Azure service principal secrets
	•	No stored credentials in GitHub
	•	Tokens are short-lived and scoped per workflow

    Network Security

Platform Separation

Networking is owned by Repo #2.

Repo #3:
	•	Consumes approved subnets
	•	Does not modify network topology
	•	Inherits Private DNS and routing controls

This separation ensures:
	•	Workload teams cannot weaken platform guardrails
	•	Network security remains centrally governed

⸻

Ingress Exposure
	•	Azure Container App exposes HTTPS-only ingress
	•	TLS termination handled by Azure
	•	No direct container port exposure

Future enhancements may include:
	•	IP allowlists
	•	WAF integration
	•	Private ingress for internal workloads

Container Security

Image Build
	•	Minimal Python base image
	•	No secrets baked into image
	•	Dependencies explicitly defined

Runtime Isolation
	•	Containers run inside Azure Container Apps sandbox
	•	No host access
	•	No privileged containers
	•	No volume mounts with sensitive data



Observability & Detection

Logs
	•	Application logs streamed to Azure
	•	Used to diagnose:
	•	Startup failures
	•	Missing configuration
	•	Identity and permission errors

Auditability

All sensitive operations are auditable via:
	•	Azure Activity Logs
	•	Key Vault access logs
	•	GitHub Actions logs

Security Incidents Encountered & Resolved

During development, several real-world issues were identified and fixed:

1. Missing Runtime Secrets
	•	Symptom: Application returned HTTP 500
	•	Cause: Environment variable not injected
	•	Resolution: Verified Key Vault → ACA secret mapping and app config

2. Identity Scope Errors
	•	Symptom: Image pull or storage access failures
	•	Cause: Incorrect RBAC scope
	•	Resolution: Scoped RBAC to resource-level assignments

3. Configuration Drift
	•	Symptom: App behaved differently than test deployments
	•	Cause: Reused test Container App configuration
	•	Resolution: Deployed clean, workload-specific Container App

Each issue reinforced the importance of least privilege, clean deployments, and runtime validation.

What This Repo Explicitly Avoids

This project intentionally avoids:
	•	Hardcoded secrets
	•	.env files in production
	•	Long-lived service principals
	•	Shared credentials
	•	Admin access to subscriptions
	•	Manual portal-only configuration

    Final Note

This repository does not claim to be “perfectly secure”.

It does demonstrate:
	•	Awareness of real-world threats
	•	Correct use of Azure-native security controls
	•	A clear separation between learning and operating

Security here is treated as a first-class design concern, not an afterthought.