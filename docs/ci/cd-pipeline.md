# CI/CD Pipeline

## Pipeline Stages
1. Build & Test
2. Image Push to ACR
3. Deployment to Azure Container Apps

## Branch Strategy
- Feature branches → CI only
- main → CI + CD (approval required)

## Deployment Safeguards
- GitHub Environment with reviewers
- Manual approval before production deploy

## Why This Matters
- Prevents accidental deployments
- Mirrors real production governance