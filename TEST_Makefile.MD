Here’s a modular test plan tailored for your Makefile-driven ECR and ECS workflow. It’s structured for onboarding clarity, audit traceability, and CI/CD validation.

---

## ✅ Test Plan: Makefile-Based ECR Build & ECS Deploy

### 🔹 Purpose

Ensure each Makefile target performs its intended function across the ECR lifecycle and ECS deployment pipeline, with Git SHA traceability and AWS CLI integration.

---

### 🧪 Test Matrix

| Target         | Purpose                                      | Validation Steps                                                            |
| -------------- | -------------------------------------------- | --------------------------------------------------------------------------- |
| `create-ecr`   | Create ECR repo with scan + encryption       | Confirm repo exists via `validate-ecr`; check scan/encryption config        |
| `validate-ecr` | Verify ECR repo exists                       | Should return repo metadata with correct name and region                    |
| `ecr-login`    | Authenticate Docker to ECR                   | Should return `Login Succeeded`                                             |
| `build`        | Build image tagged with `latest` and SHA     | Run `docker images`; confirm both tags exist                                |
| `push`         | Push both image tags to ECR                  | Run `aws ecr list-images`; confirm `latest` and SHA tags uploaded           |
| `inject-sha`   | Replace `{{IMAGE_TAG}}` in task def          | Inspect `ecs-task-def-temp.json`; confirm SHA substitution                  |
| `ecs-register` | Register ECS task definition                 | Run `aws ecs describe-task-definition`; confirm new revision registered     |
| `ecs-deploy`   | Force ECS service to use new task definition | Run `aws ecs describe-services`; confirm updated task definition in service |
| `clean`        | Remove temp task definition file             | Confirm `ecs-task-def-temp.json` is deleted                                 |

---

### 🧩 Manual Test Steps

1. **Initialize ECR**

   ```bash
   make create-ecr
   make validate-ecr
   ```

2. **Authenticate Docker**

   ```bash
   make ecr-login
   ```

3. **Build and Push Image**

   ```bash
   make build
   make push
   ```

4. **Inject SHA and Register Task**

   ```bash
   make ecs-register
   ```

5. **Deploy to ECS**

   ```bash
   make ecs-deploy
   ```

6. **Clean Up**
   ```bash
   make clean
   ```

---

### 📘 Governance Notes

- Git SHA tagging ensures traceability between source and container.
- ECR scan-on-push and encryption enforce security best practices.
- ECS registration and deployment are modular for CI/CD reuse.
- All steps are CLI-driven for audit logging and reproducibility.

Would you like this scaffolded into your `NOTES.md` or styled for PDF export as part of your onboarding documentation? I can also help modularize it into a reusable test checklist or CI validation block.
