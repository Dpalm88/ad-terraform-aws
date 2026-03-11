# Active Directory on AWS with Terraform

Automated deployment of a Windows Server 2022 Domain Controller on AWS using Terraform. This project provisions all required infrastructure from scratch — VPC, networking, security, and EC2 — and configures Active Directory Domain Services via PowerShell userdata.

---

## Architecture

```
AWS (us-east-1)
└── VPC (10.0.0.0/16)
      └── Public Subnet (10.0.1.0/24) — us-east-1a
            ├── Internet Gateway
            ├── Route Table (0.0.0.0/0 → IGW)
            ├── Security Group (RDP 3389 inbound)
            └── EC2 — Windows Server 2022 (t3.micro)
                  └── AD DS Domain Controller
                        ├── Domain: corp.dpalm.local
                        ├── DNS Server
                        ├── Organizational Units (Corp Users, Corp Computers, Corp Admins)
                        ├── Test User (jsmith)
                        └── Password Policy (12 char min, 90-day expiry, lockout after 5 attempts)
```

---

## Technologies Used

- **Terraform** v1.14 — Infrastructure as Code
- **AWS EC2** — Windows Server 2022 compute
- **AWS VPC** — Isolated network with public subnet, IGW, and route tables
- **AWS Security Groups** — RDP access control
- **PowerShell** — Automated AD DS installation and configuration via EC2 userdata
- **Active Directory Domain Services** — Domain controller, DNS, OUs, users, GPOs

---

## Project Files

| File | Description |
|------|-------------|
| `main.tf` | Core infrastructure — VPC, IGW, subnet, route table, security group, EC2 |
| `variables.tf` | Input variables with defaults (region, CIDR blocks, instance type, domain name) |
| `outputs.tf` | Outputs after apply — instance ID, public IP, RDP connection string |
| `userdata.ps1` | PowerShell script — installs AD DS, promotes to DC, creates OUs and test user, sets password policy |
| `.gitignore` | Excludes Terraform state files and sensitive `.tfvars` from version control |

---

## What Gets Deployed

### Infrastructure
- Custom VPC with DNS hostnames enabled
- Public subnet with auto-assigned public IPs
- Internet Gateway and route table
- Security group allowing RDP (port 3389) inbound

### Active Directory
- AD DS forest with domain `corp.dpalm.local`
- DNS server configured on the domain controller
- Three Organizational Units: `Corp Users`, `Corp Computers`, `Corp Admins`
- Test user account (`jsmith`) in `Corp Users` OU
- Default domain password policy:
  - Minimum password length: 12 characters
  - Password history: 10 passwords
  - Maximum password age: 90 days
  - Account lockout: 5 failed attempts, 30-minute lockout duration

---

## Usage

### Prerequisites
- Terraform installed
- AWS CLI configured (`aws configure`)
- AWS account with EC2/VPC permissions

### Deploy

```bash
# Clone the repo
git clone https://github.com/Dpalm88/ad-terraform-aws.git
cd ad-terraform-aws

# Initialize Terraform
terraform init

# Preview the deployment
terraform plan -var="admin_password=YourSecurePassword123!"

# Deploy
terraform apply -var="admin_password=YourSecurePassword123!"
```

### Connect via RDP

After apply completes, use the output RDP connection string:

```
mstsc /v:<public_ip>
```

- **Username:** `Administrator`
- **Password:** value passed as `admin_password`

> **Note:** Allow 5–10 minutes after apply for AD DS installation and DC promotion to complete before connecting.

### Destroy

```bash
terraform destroy -var="admin_password=YourSecurePassword123!"
```

---

## Screenshots

### Terraform Apply — Resources Created
![Terraform Apply](screenshots/terraform%20apply.png)

### EC2 Instance Running
![EC2 Instance](screenshots/ec2%20isntance%20terrform.png)

### VPC, Subnet, and Route Tables
![VPC](screenshots/VPC%2C%20subnet%2C%20route%20tables.png)

---

## Security Notes

- RDP is open to `0.0.0.0/0` for demo purposes — in production, restrict to your IP
- Never commit `.tfvars` files or Terraform state to version control
- The `.gitignore` in this repo excludes all sensitive Terraform files
- Passwords should be passed via environment variables or a secrets manager in production:

```bash
export TF_VAR_admin_password="YourSecurePassword"
terraform apply
```

---

## Author

**David Palm** — Cloud/Infrastructure Engineer  
[github.com/Dpalm88](https://github.com/Dpalm88) · [linkedin.com/in/david-palm-ca](https://linkedin.com/in/david-palm-ca)
