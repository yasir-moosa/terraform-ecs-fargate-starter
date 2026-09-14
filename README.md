# Terraform ECS Fargate Starter

A minimal, complete reference project for deploying a containerized app on **AWS ECS Fargate** using **Terraform**, with a remote S3 state backend. Built to be a clear, working starting point for anyone learning how these pieces fit together: VPC, security groups, an Application Load Balancer, and ECS Fargate, all wired up from scratch.

If you're learning Terraform + AWS ECS and want a small, real, working example (rather than a huge production-grade module you can't follow), this is for you. Clone it, deploy it, read through it, break it, rebuild it. That's the intended use.

## What it deploys

- A VPC with public and private subnets across two Availability Zones
- A NAT Gateway (so private-subnet tasks can reach the internet, e.g. to pull images)
- Least-privilege security groups (ALB and ECS task, separated)
- An Application Load Balancer, routing traffic to...
- An ECS Fargate service running a container built from this repo's own tiny app

## Screenshots

*Will add picture later - the app working in a browser (via the ALB DNS name).*

*Will add picture later - a successful `curl` output.*

## Prerequisites

- An AWS account with the CLI configured (`aws sts get-caller-identity` works)
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.6.0
- Docker
- An IAM role named `ecsTaskExecutionRole` in your account (the standard ECS task execution role; create it once via the AWS console/CLI if you don't already have it; this project reads it as a data source rather than creating it, since most AWS accounts already have one)

## Folder structure

```
.
├── bootstrap/
│   ├── s3_backend/          # one-time: creates the S3 bucket for remote state
│   │   ├── s3_backend.tf
│   │   └── s3_variables.tf
│   └── ecr_bootstrap/       # one-time: creates the ECR repo for your image
│       ├── ecr_bootstrap.tf
│       ├── ecr_variables.tf
│       └── ecr_outputs.tf
├── app/
│   ├── Dockerfile
│   └── index.html
└── infra/
    ├── main.tf
    ├── variables.tf
    └── modules/
        ├── vpc/   (vpc_main.tf, vpc_outputs.tf)
        ├── sg/    (sg_main.tf, sg_variables.tf, sg_outputs.tf)
        ├── alb/   (alb_main.tf, alb_variables.tf, alb_outputs.tf)
        └── ecs/   (ecs_main.tf, ecs_variables.tf, ecs_outputs.tf)
```

## Getting started

### 1. Create the S3 state bucket

```bash
cd bootstrap/s3_backend
terraform init
terraform apply
```

> S3 bucket names are globally unique across all AWS accounts. Edit `bucket_name` in `s3_variables.tf` to something unique before applying.

### 2. Create the ECR repo

```bash
cd bootstrap/ecr_bootstrap
terraform init
terraform apply
terraform output repository_url
```

### 3. Build and push your image

```bash
cd app
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<your-region>.amazonaws.com

docker build -t <your-repo-name> .
docker tag <your-repo-name>:latest <account-id>.dkr.ecr.<your-region>.amazonaws.com/<your-repo-name>:latest
docker push <account-id>.dkr.ecr.<your-region>.amazonaws.com/<your-repo-name>:latest
```

> **Windows PowerShell users:** if `docker login` fails with `400 Bad Request`, wrap the command in `cmd /c "..."`. PowerShell's pipeline can corrupt the auth token.

Before building, update the backend bucket name in `infra/main.tf` to match what you created in Step 1.

### 4. Deploy the infrastructure

```bash
cd infra
terraform init
terraform plan
terraform apply
```

### 5. Verify it's working

```bash
terraform output
curl http://<alb_dns_name>
```

### 6. Tear it down

```bash
cd infra
terraform destroy
```

This only destroys the VPC/ALB/ECS infrastructure. The S3 bucket and ECR repo from Steps 1-2 are left alone, since they're meant to be reused (rebuild the `infra/` part as many times as you like without recreating those every time).

## Notes on the design

A few deliberate choices worth knowing about if you're reading through the code:

- **`aws_vpc_security_group_ingress_rule` / `egress_rule`** are used instead of inline `ingress {}` / `egress {}` blocks: the modern, per-rule resource style, which is easier to reason about and extend.
- **`name_prefix` + `lifecycle { create_before_destroy = true }`** on the target group avoids a common failure (`ResourceInUse`) when a change forces the target group to be replaced while a listener still references it.
- **Bootstrap configs use local Terraform state**, not remote. This avoids a chicken-and-egg problem (you can't point a backend at a bucket that doesn't exist yet).
- **`target_type = "ip"`** on the target group, because Fargate tasks don't have EC2 instances behind them. Traffic is routed straight to each task's own IP address (`network_mode = "awsvpc"`).

## Extending this

This is intentionally small. Natural next steps if you want to build on it:
- HTTPS via ACM + a custom domain
- CI/CD to automate build/push/deploy on every commit
- Auto-scaling based on CPU/memory or request count
- A second NAT Gateway per AZ for high availability (this project uses one, for simplicity/cost)

## Cost warning

The NAT Gateway and ALB both incur hourly charges even when idle. Don't leave this deployed if you're not actively using it. Run `terraform destroy` when done.

## License

MIT. Use this however you like.
