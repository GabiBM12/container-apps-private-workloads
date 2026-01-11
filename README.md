# Repo #3 – Container Apps Workloads (Azure)

This repository deploys workload resources on top of the secure networking foundation created in Repo #2.

## Milestone 1
- Uses a dedicated remote backend state (separate key)
- Reads platform outputs from Repo #2 via `terraform_remote_state`
- Creates a dedicated Resource Group for workloads
- Exposes platform IDs (subnets / DNS zones) as outputs for later milestones

## How it connects to Repo #2
Repo #2 owns the VNet, subnets, Private DNS, and guardrails.  
Repo #3 consumes those outputs and deploys workload services (Container Apps, identities, etc.) into the platform network.


## Milestone 2 – Application Deployment & Identity-Based Access

In this milestone, the initial test "hello" Container App was removed and replaced with a dedicated Azure Container App configured specifically for the CRM workload.

The following was implemented:

- Built a production-ready Docker image for the CRM API
- Pushed the image to Azure Container Registry (ACR)
- Deployed a new Azure Container App aligned with the application configuration
- Enabled system-assigned managed identity on the Container App
- Assigned required RBAC roles:
  - **AcrPull** on Azure Container Registry (image pull at runtime)
  - **Storage Blob Data Contributor** on the Storage Account (application data access)
- Connected the application to Azure Blob Storage using **managed identity authentication**
- Verified end-to-end functionality via public FQDN using `curl` (health checks and API operations)

At no point were secrets, storage keys, or registry credentials stored in code, Terraform state, or environment files.  
All access is handled via Azure AD identities and role-based access control.

---

## Container Image & Registry Flow

The application image is built locally using Docker and pushed to ACR using explicit version tags (e.g. `0.1.0`) as well as a moving `latest` tag.

The Container App pulls images from ACR using its managed identity, eliminating the need for admin credentials or registry secrets.

This mirrors real-world CI/CD pipelines where image build and push are automated, and runtime workloads authenticate using Azure-native identity.

---

## Application Verification

The deployed application exposes a public HTTPS endpoint via Azure Container Apps.

Verified functionality includes:
- Health endpoint responding with HTTP 200
- POST and GET operations against the `/contacts` API
- Successful runtime access to Azure Blob Storage using managed identity
All validation was performed using direct HTTP calls to the Container App FQDN.

## Why This Project Exists

This repository represents my transition from learning Azure concepts in isolation to operating a real cloud workload end-to-end.

Rather than following a single tutorial, I intentionally built and connected multiple Azure services:
- Azure Container Apps
- Azure Container Registry
- Azure Storage Accounts
- Azure RBAC and Managed Identities
- Terraform remote state and cross-repository dependencies

Along the way, I encountered configuration mistakes, deployment failures, and identity-related issues — and treated each one as a debugging exercise rather than a blocker.

By the end of this milestone, I was able to:
- Diagnose misaligned Container App configurations
- Understand the difference between infrastructure identity and application runtime identity
- Correct RBAC scoping issues
- Verify application behavior directly via logs and HTTP responses
This project reflects how I learn: by building, breaking, fixing, and documenting real systems.

## Lessons Learned
An early version of this deployment reused a test Container App configuration, which led to image pull and routing issues when the application was accessed via its FQDN.

By reviewing:
- Container App configuration
- Image source and identity bindings
- Application logs in Log Analytics

I identified a mismatch between the test Container App and the intended workload configuration.

The issue was resolved by deploying a clean, application-specific Container App with the correct identity, image, and runtime settings.

This reinforced the importance of environment parity and avoiding configuration drift between test and production workloads.