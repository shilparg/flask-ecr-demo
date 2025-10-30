Here’s a modular test plan for `gitflow ecr-push.yml` GitHub Actions workflow, tailored for auditability, CI/CD validation, and onboarding clarity:

---

## ✅ Test Plan: `Build and Push to ECR` Workflow

### 🔹 Purpose

Validate that the GitHub Actions workflow:

- Builds and tags Docker images with Git SHA
- Pushes images to Amazon ECR
- Injects SHA into ECS task definition
- Registers and deploys updated ECS service

---

### 🧪 Test Matrix

| Test Case               | Trigger                                      | Expected Outcome                                             |
| ----------------------- | -------------------------------------------- | ------------------------------------------------------------ |
| 1. Push to `main`       | `git push origin main`                       | Workflow initiates automatically                             |
| 2. AWS credential setup | IAM role assumed via OIDC                    | AWS CLI commands succeed                                     |
| 3. Docker build         | Valid `Dockerfile` in repo                   | Image built and tagged with `latest` and `${{ github.sha }}` |
| 4. ECR login            | Valid ECR permissions                        | `docker push` succeeds                                       |
| 5. Image push           | ECR URI reachable                            | Both tags pushed to ECR                                      |
| 6. SHA injection        | `ecs-task-def.json` contains `{{IMAGE_TAG}}` | `ecs-task-def-temp.json` created with correct SHA            |
| 7. Task registration    | Valid ECS task definition                    | New task definition registered                               |
| 8. ECS deployment       | Valid cluster/service names                  | Service updated with new task definition                     |

---

### 🧩 Manual Validation Steps

1. **Push to `main`**

   ```bash
   git checkout main
   git commit --allow-empty -m "Trigger workflow"
   git push origin main
   ```

2. **Verify Workflow Execution**

   - Go to GitHub → Actions tab → Confirm `Build and Push to ECR` runs.

3. **Check ECR Image Tags**

   ```bash
   aws ecr list-images --repository-name flask-ecr-demo
   ```

   - Confirm presence of `latest` and `${GITHUB_SHA}` tags.

4. **Inspect ECS Task Definition**

   ```bash
   aws ecs describe-task-definition --task-definition flask-ecr-demo
   ```

   - Confirm image tag matches pushed SHA.

5. **Confirm ECS Deployment**
   ```bash
   aws ecs describe-services \
     --cluster flask-ecr-cluster \
     --services flask-ecr-service
   ```
   - Confirm `taskDefinition` matches newly registered version.

---

### 📘 Governance Notes

- Git SHA tagging ensures traceability between source and container.
- OIDC role assumption avoids long-lived AWS credentials.
- ECS deployment is forced to ensure latest image is used.
- All steps are modular and CI/CD compatible.
