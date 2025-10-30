# 📘 NOTES.md — End-to-End Learning Summary: Flask App to AWS ECR & ECS via GitHub Actions

## 🧭 Overview

This project demonstrates a modular, traceable deployment pipeline for a containerized Flask app using:

- 🐳 Docker for containerization
- 🐘 AWS ECR for image storage
- ⚙️ GitHub Actions for CI/CD automation
- 🚀 AWS ECS for service deployment
- 🧠 Makefile and shell scripts for CLI validation
- 📊 README badges and `TEST.md` for governance traceability

## Repository Structure

flask-ecr-demo/
├── app.py
├── requirements.txt
├── Dockerfile
├── deploy.sh
├── Makefile
├── ecs-task-def.json
├── .github/workflows/ecr-push.yml
├── README.md
├── TEST.md
└── NOTES.md

## Flask App & Dockerization

- Flask app exposed on port `5000`
- Dockerfile uses `python:3.10-slim`
- Requirements installed via `requirements.txt`
- Container runs `app.py` directly

## Docker Image Tags

- `latest`: for ECS default deployment
- `${{ github.sha }}`: immutable tag for traceability
- Both tags pushed to ECR for audit and rollback

## Makefile Targets

| Target         | Purpose                            |
| -------------- | ---------------------------------- |
| `build`        | Builds Docker image with both tags |
| `push`         | Pushes image to ECR                |
| `ecr-login`    | Authenticates Docker to ECR        |
| `create-ecr`   | Creates ECR repo if missing        |
| `validate-ecr` | Confirms ECR repo exists           |
| `ecs-register` | Registers ECS task definition      |
| `ecs-deploy`   | Forces ECS service redeployment    |

## GitHub Actions Workflow

Trigger: `push` to `main`  
Steps:

- Checkout code
- Assume IAM role via OIDC
- Login to ECR
- Build image with `latest` and `github.sha`
- Push both tags to ECR
- Deploy to ECS (optional)

## ECS Task Registration Workflow

🔹 Purpose
This workflow ensures traceable, audit-ready ECS deployments by injecting the current Git SHA into the task definition and registering it via AWS CLI.
🔹 Steps

- Git SHA Injection
- make inject-sha replaces {{IMAGE_TAG}} in ecs-task-def.json with the current commit SHA.
- Output: ecs-task-def-temp.json (used for registration).
- Task Definition Registration
- make ecs-register invokes inject-sha and registers the updated task definition with ECS.
- Optional Cleanup
- make clean removes the temporary task definition file.
- Optional Deployment Trigger
- make ecs-deploy forces ECS to use the newly registered task definition.

## Governance & Auditability

- Immutable SHA tags for reproducibility
- CI/CD logs for deployment traceability
- Makefile and shell scripts for CLI audit trails
- ECS task definitions versioned for rollback
- `NOTES.md` and `TEST.md` for onboarding reuse
