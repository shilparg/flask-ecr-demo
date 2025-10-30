`create-role.sh` is a shell script that automates the creation of an AWS IAM role — typically used to streamline onboarding, CI/CD setup, or infrastructure provisioning. In your context, it would encapsulate the steps needed to create the `GITHUB_OIDC_ROLE` with its trust policy and attach permissions.

---

## 🧩 What `create-role.sh` Typically Does

### ✅ 1. **Defines Role Name and Trust Policy**

```bash
ROLE_NAME="GITHUB_OIDC_ROLE"
TRUST_POLICY="infra/iam/trust-policy.json"
```

### ✅ 2. **Creates the IAM Role**

```bash
aws iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document file://$TRUST_POLICY
```

### ✅ 3. **Attaches Required Policies**

```bash
aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess

aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/AmazonECS_FullAccess
```

### ✅ 4. **Validates Role Creation**

```bash
aws iam get-role --role-name $ROLE_NAME
```

---

## 📁 Where to Store It

Place it in your onboarding repo:

```
infra/
├── iam/
│   ├── trust-policy.json
│   ├── create-role.sh
```

Make it executable:

```bash
chmod +x infra/iam/create-role.sh
```

---

Here’s a modular version of your `create-role.sh` script, tailored for GitHub OIDC onboarding with AWS IAM:

---

## 🧩 `create-role.sh`: GitHub OIDC Role Creation Script

```bash
#!/bin/bash

# === Configuration ===
ACCOUNT_ID="255945442255"
ROLE_NAME="GITHUB_OIDC_ROLE"
TRUST_POLICY_PATH="infra/iam/trust-policy.json"
REGION="ap-southeast-1"

# === Create IAM Role ===
echo "Creating IAM role: $ROLE_NAME"
aws iam create-role \
  --role-name "$ROLE_NAME" \
  --assume-role-policy-document "file://$TRUST_POLICY_PATH" \
  --region "$REGION"

# === Attach Policies ===
echo "Attaching ECR and ECS policies"
aws iam attach-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess

aws iam attach-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-arn arn:aws:iam::aws:policy/AmazonECS_FullAccess

# === Validate Role ===
echo "Validating role creation"
aws iam get-role --role-name "$ROLE_NAME" --region "$REGION"
```

---

## ✅ How to Use

1. Save as `infra/iam/create-role.sh`
2. Make it executable:
   ```bash
   chmod +x infra/iam/create-role.sh
   ```
3. Run:
   ```bash
   ./infra/iam/create-role.sh
   ```

---

## 🔐 Governance Tips

- Keep `trust-policy.json` version-controlled and scoped to specific repos/branches.
- Modularize with environment variables or flags for reuse across projects.
- Document usage in `NOTES.md` or `README.md` for onboarding clarity.
- Keep it modular and parameterized for reuse across projects.
- Use environment variables or flags to support dry-run, region override, or custom role names.
