AWS_REGION=us-east-1
REPO_NAME=flask-ecr-demo
ACCOUNT_ID=$(shell aws sts get-caller-identity --query Account --output text)
IMAGE_URI=$(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(REPO_NAME)
# Capture current Git commit SHA for traceable image tagging
GIT_SHA := $(shell git rev-parse HEAD)
IMAGE_TAG := $(GIT_SHA)

# ─────────────────────────────────────────────────────────────
# Declare phony targets to avoid file conflicts
.PHONY: build push ecr-login create-ecr validate-ecr inject-sha ecs-register clean ecs-deploy


#build:
#	docker build -t $(IMAGE_URI):latest -t $(IMAGE_URI):$(shell git rev-parse HEAD) .

#push:
#	docker push $(IMAGE_URI):latest
#	docker push $(IMAGE_URI):$(shell git rev-parse HEAD)

build: validate-login
	docker build -t $(IMAGE_URI):latest -t $(IMAGE_URI):$(IMAGE_TAG) .

push: validate-login
	docker push $(IMAGE_URI):latest
	docker push $(IMAGE_URI):$(IMAGE_TAG)

ecr-login:
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(IMAGE_URI)

validate-login:
	@aws sts get-caller-identity || (echo "❌ AWS login failed"; exit 1)

create-ecr:
	aws ecr create-repository --repository-name $(REPO_NAME) --region $(AWS_REGION) \
	--image-scanning-configuration scanOnPush=true \
	--encryption-configuration encryptionType=AES256

validate-ecr:
	aws ecr describe-repositories \
	--repository-names $(REPO_NAME) \
	--region $(AWS_REGION)

# Replace {{IMAGE_TAG}} in task definition with current Git SHA
inject-sha:
	sed "s/{{IMAGE_TAG}}/$(GIT_SHA)/" ecs-task-def.json > ecs-task-def-temp.json

# Register ECS task definition using the injected SHA
#ecs-register:
#	make inject-sha
#	aws ecs register-task-definition \
#	--cli-input-json file://ecs-task-def-temp.json

ecs-register: inject-sha
	aws ecs register-task-definition \
	--cli-input-json file://ecs-task-def-temp.json

# Optional cleanup of temp files
clean:
	rm -f ecs-task-def-temp.json

# Optional: force ECS service to use new task definition
ecs-deploy:
	aws ecs update-service \
	--cluster flask-ecr-cluster \
	--service flask-ecr-service \
	--force-new-deployment