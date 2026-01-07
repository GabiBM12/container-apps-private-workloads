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