# ─────────────────────────────────────────────────────────────
#  Environment Configuration
AWS_REGION = us-east-1
REPO_NAME = flask-ecr-demo
ACCOUNT_ID = $(shell aws sts get-caller-identity --query Account --output text)
IMAGE_URI = $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(REPO_NAME)
GIT_SHA := $(shell git rev-parse HEAD)
IMAGE_TAG := $(GIT_SHA)

# ─────────────────────────────────────────────────────────────
#  Declare phony targets to avoid file conflicts
.PHONY: build push ecr-login validate-login create-ecr validate-ecr inject-sha ecs-register ecs-deploy clean

# ─────────────────────────────────────────────────────────────
#  AWS Authentication
validate-login:
	@aws sts get-caller-identity || (echo "❌ AWS login failed"; exit 1)

ecr-login:
	aws ecr get-login-password --region $(AWS_REGION) | \
	docker login --username AWS --password-stdin $(IMAGE_URI)

# ─────────────────────────────────────────────────────────────
#  Build and Push Docker Image
build: validate-login
	docker build -t $(IMAGE_URI):latest -t $(IMAGE_URI):$(IMAGE_TAG) .

push: validate-login
	docker push $(IMAGE_URI):latest
	docker push $(IMAGE_URI):$(IMAGE_TAG)

# ─────────────────────────────────────────────────────────────
#  ECR Repository Management
create-ecr:
	aws ecr create-repository \
		--repository-name $(REPO_NAME) \
		--region $(AWS_REGION) \
		--image-scanning-configuration scanOnPush=true \
		--encryption-configuration encryptionType=AES256

validate-ecr:
	aws ecr describe-repositories \
		--repository-names $(REPO_NAME) \
		--region $(AWS_REGION)

# ─────────────────────────────────────────────────────────────
#  ECS Deployment
inject-sha:
	sed "s/{{IMAGE_TAG}}/$(IMAGE_TAG)/" ecs-task-def.json > ecs-task-def-temp.json

ecs-register: inject-sha
	aws ecs register-task-definition \
		--cli-input-json file://ecs-task-def-temp.json

ecs-deploy:
	aws ecs update-service \
		--cluster flask-ecr-cluster \
		--service flask-ecr-service \
		--force-new-deployment

# ─────────────────────────────────────────────────────────────
# Validate full pipeline (login + build + push + deploy)
pipeline: validate-login build push ecs-register ecs-deploy

# ─────────────────────────────────────────────────────────────
#  Cleanup
clean:
	rm -f ecs-task-def-temp.json