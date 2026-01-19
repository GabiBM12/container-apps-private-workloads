Architecture Overview

This document describes the end-to-end architecture of the Container Apps Private Workloads project. The focus is on real-world Azure patterns used in production environments across the UK/EU market: identity-based access, secret isolation, controlled deployments, and clear trust boundaries.

The goal of this architecture is to demonstrate how to run a cloud-native application without embedding secrets, without long-lived credentials, and with clear separation of responsibilities between CI/CD, infrastructure, and application runtime.

⸻

High-Level Architecture

Core components:
	•	Azure Container Apps – runtime platform for the CRM API
	•	Azure Container Registry (ACR) – private container image registry
	•	Azure Key Vault – centralised secret store
	•	User Assigned Managed Identity (UAMI) – identity used by the running application
	•	GitHub Actions (OIDC) – CI/CD pipeline with federated identity

At a high level:
	1.	Developers push code to GitHub
	2.	GitHub Actions builds and pushes a container image to ACR
	3.	Deployment updates the Azure Container App
	4.	At runtime, the container app retrieves secrets from Azure Key Vault using Managed Identity

No secrets are stored in source control, Terraform state, or GitHub.

⸻

Trust Boundaries

This project explicitly defines trust boundaries, which is a key requirement in regulated or enterprise environments.

1. CI/CD Boundary (GitHub)
	•	GitHub Actions has no access to secret values
	•	Authentication to Azure uses OIDC federation, not client secrets
	•	Deployment to Azure requires environment approval

2. Infrastructure Boundary (Azure Control Plane)
	•	Terraform defines references to secrets, not secret values
	•	Key Vault access is controlled via Azure RBAC
	•	Network access to Key Vault is restricted

3. Runtime Boundary (Application)
	•	Application receives secrets only at runtime
	•	Secrets are injected as environment variables by Azure
	•	Application code never logs or exposes secret values

⸻

Identity and Authentication Model

Managed Identities

The application uses a User Assigned Managed Identity (UAMI), which provides:
	•	Strong identity separation between workloads
	•	Predictable lifecycle management
	•	Reusability across services if required

The managed identity is granted least-privilege access:
	•	Key Vault Secrets User role on the Key Vault
	•	No permissions outside required scope

There are no passwords, API keys, or certificates associated with this identity.

⸻

Secret Flow (End-to-End)

This project demonstrates best-practice secret flow:
	1.	Secret (e.g. mailgun-email-api) is created in Azure Key Vault
	2.	Azure Container App defines a Key Vault reference to the secret
	3.	At startup, Azure resolves the reference using the managed identity
	4.	Secret is injected into the container as an environment variable
	5.	Application reads the value using standard environment access

Important characteristics:
	•	Secret value never appears in Terraform state
	•	Secret value never appears in GitHub
	•	Secret value never appears in container image layers

⸻

Application Configuration Model

Configuration is split into two categories:

Non-Sensitive Configuration
	•	Storage account name
	•	Container name
	•	Public configuration values

These are provided as plain environment variables.

Sensitive Configuration
	•	External service API keys (e.g. Mailgun)

These are:
	•	Stored in Azure Key Vault
	•	Referenced by name in Terraform
	•	Injected securely at runtime

The application validates required configuration at startup, ensuring fast failure if misconfigured.

⸻

Networking Model
	•	Azure Container App exposes a public HTTPS endpoint
	•	Outbound access is allowed only for required external services
	•	Azure Key Vault is accessed via Azure-controlled private connectivity

This mirrors common enterprise patterns where:
	•	Ingress is controlled
	•	Egress is explicit
	•	Sensitive services are not publicly exposed

⸻

Deployment and Revision Model

Azure Container Apps revisions are used to:
	•	Ensure zero-downtime deployments
	•	Allow safe rollback if required
	•	Track configuration and image changes

Each deployment creates a new revision, with traffic routed only after the revision is healthy.

⸻

Failure Scenarios and Behaviour

Scenario	Behaviour
Key Vault unavailable	Application fails fast at startup
Identity permissions removed	Secret resolution fails, app does not start
Bad deployment	Previous revision remains available

This behaviour is intentional and aligns with fail-fast, observable systems.

⸻

This architecture demonstrates:
	•	Real-world Azure identity usage
	•	Secure secret management without shortcuts
	•	Clear separation of CI, infrastructure, and runtime concerns
	•	Patterns used in regulated UK/EU environments

It reflects how cloud platforms are designed to be used at scale and under governance, not just for demos.