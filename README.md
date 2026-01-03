# AWS Landing Zone

A production-grade multi-account AWS foundation implementing governance, security controls, and hub-and-spoke networking. Built with Terraform and Terragrunt following AWS Well-Architected and federal compliance patterns.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              AWS Organization                                   │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                        Management Account                                │   │
│  │                    (Organizations, SCPs, Billing)                        │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                      │                                          │
│            ┌─────────────────────────┼─────────────────────────┐               │
│            │                         │                         │               │
│            ▼                         ▼                         ▼               │
│  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐         │
│  │   Security OU    │    │ Infrastructure OU │    │  Workloads OU    │         │
│  │                  │    │                  │    │                  │         │
│  │  (Future:        │    │  Shared Services │    │  Workload-Dev    │         │
│  │   Security Hub,  │    │  - Transit GW    │    │  - Application   │         │
│  │   GuardDuty)     │    │  - NAT Gateway   │    │    workloads     │         │
│  │                  │    │  - Central VPC   │    │  - No NAT        │         │
│  └──────────────────┘    └────────┬─────────┘    └────────┬─────────┘         │
│                                   │                       │                    │
│                                   │    Transit Gateway    │                    │
│                                   └───────────┬───────────┘                    │
│                                               │                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                         Network Connectivity                             │   │
│  │                                                                          │   │
│  │   Shared Services VPC          Transit Gateway         Workload VPC      │   │
│  │      10.1.0.0/16        ◄────  tgw-02647e74  ────►     10.2.0.0/16      │   │
│  │                                                                          │   │
│  │   ┌─────────────────┐                              ┌─────────────────┐   │   │
│  │   │ Public Subnets  │                              │ Public Subnets  │   │   │
│  │   │ 10.1.0.0/20     │                              │ 10.2.0.0/20     │   │   │
│  │   │ 10.1.16.0/20    │                              │ 10.2.16.0/20    │   │   │
│  │   └─────────────────┘                              └─────────────────┘   │   │
│  │   ┌─────────────────┐                              ┌─────────────────┐   │   │
│  │   │ Private Subnets │                              │ Private Subnets │   │   │
│  │   │ 10.1.32.0/20    │                              │ 10.2.32.0/20    │   │   │
│  │   │ 10.1.48.0/20    │                              │ 10.2.48.0/20    │   │   │
│  │   └─────────────────┘                              └─────────────────┘   │   │
│  │   ┌─────────────────┐                              ┌─────────────────┐   │   │
│  │   │ TGW Subnets     │                              │ TGW Subnets     │   │   │
│  │   │ 10.1.64.0/24    │                              │ 10.2.64.0/24    │   │   │
│  │   │ 10.1.65.0/24    │                              │ 10.2.65.0/24    │   │   │
│  │   └─────────────────┘                              └─────────────────┘   │   │
│  │           │                                                │             │   │
│  │           ▼                                                              │   │
│  │   ┌─────────────────┐                                                    │   │
│  │   │  NAT Gateway    │  Centralized egress for all private subnets       │   │
│  │   └─────────────────┘                                                    │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                      Service Control Policies                            │   │
│  │                                                                          │   │
│  │  • DenyLeaveOrganization     - Attached to Root                         │   │
│  │  • DenyUnapprovedRegions     - Attached to Workloads OU                 │   │
│  │  • ProtectSecurityControls   - Attached to Root                         │   │
│  │  • DenyRootUserActions       - Attached to Workloads + Infrastructure   │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## What Was Built

**Phase 1: Organization Structure**
- AWS Organization with consolidated billing and all features enabled
- Three OUs: Security, Infrastructure, Workloads
- Two member accounts provisioned via IaC

**Phase 2: Preventive Security Controls**
- Four SCPs enforcing least privilege and compliance boundaries
- Region restrictions limiting workloads to approved regions
- Root user restrictions on member accounts
- Protection for audit and security services

**Phase 3: Hub-and-Spoke Networking**
- Transit Gateway for centralized VPC connectivity
- Cross-account resource sharing via RAM
- Multi-AZ VPC design with public, private, and dedicated TGW subnets
- Centralized NAT egress through Shared Services

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| **TGW in Shared Services, not Management** | Management account should have minimal resources. Shared Services is the network hub. Required `allow_external_principals = true` for RAM sharing from member account. |
| **Dedicated TGW subnets** | Separate route tables for inbound (cross-VPC) vs outbound (instance-initiated) traffic. Enables future inspection appliances without refactoring. |
| **Centralized NAT in Shared Services** | Single egress point for logging, cost control, and security inspection. Workload VPCs route `0.0.0.0/0` through TGW to Shared Services NAT. |
| **SCPs over IAM for guardrails** | SCPs are the only mechanism to restrict root users in member accounts. IAM policies can be modified by account admins; SCPs cannot. |

## Compliance Alignment

| Control | NIST 800-53 | Implementation |
|---------|-------------|----------------|
| Account Management | AC-2 | DenyLeaveOrganization SCP prevents account removal |
| Least Privilege | AC-6 | DenyRootUserActions restricts privileged access |
| Least Functionality | CM-7 | DenyUnapprovedRegions limits to us-east-1, us-east-2 |
| Protection of Audit Information | AU-9 | ProtectSecurityControls prevents disabling CloudTrail, Config, GuardDuty |

## Cost Estimate

| Component | Monthly Cost |
|-----------|--------------|
| Transit Gateway | ~$36 (attachment hours) |
| NAT Gateway | ~$32 + data processing |
| TGW Attachments (2) | ~$14 |
| **Total** | **~$82/month** |

*No EC2 instances running. Costs are infrastructure baseline only.*

## Challenges Solved

**1. RAM Sharing from Member Account**

Initial approach used organization ARN for RAM sharing, which failed because member accounts lack organization-level visibility.

```
Error: UnknownResourceException: Organization o-xxxxx could not be found
```

**Solution:** Share with explicit account IDs and set `allow_external_principals = true`. Security maintained by controlling the account ID list.

**2. Cross-Account State Dependencies**

Workload VPC needed Transit Gateway ID from Shared Services account.

**Solution:** Terragrunt's `dependency` blocks read outputs from other state files. Mock outputs enable `plan` before dependencies exist.

```hcl
dependency "transit_gateway" {
  config_path = "../../shared-services/transit-gateway"
  mock_outputs = { transit_gateway_id = "tgw-mock" }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}
```

**3. CIDR Overlap in Subnet Design**

Initial `cidrsubnet()` calculation placed TGW subnets inside private subnet range.

**Solution:** Calculated non-overlapping ranges: Public /20 at index 0-1, Private /20 at index 2-3, TGW /24 starting at index 64.

## Tech Stack

- **IaC:** Terraform, Terragrunt
- **AWS Services:** Organizations, SCPs, Transit Gateway, RAM, VPC, IAM
- **Patterns:** Multi-account strategy, hub-and-spoke networking, preventive controls
- **Compliance:** NIST 800-53 control mapping

## Validation

```bash
# SCP Test: Unapproved region blocked
$ aws ec2 describe-vpcs --region us-west-2
Error: explicit deny in service control policy p-eaan3w2t

# SCP Test: Approved region allowed  
$ aws ec2 describe-vpcs --region us-east-1
{ "Vpcs": [{ "CidrBlock": "10.2.0.0/16" ... }] }

# Network Test: Bidirectional TGW routes confirmed
Shared Services: 10.2.0.0/16 → tgw-02647e74ac4a54d08
Workload:        10.1.0.0/16 → tgw-02647e74ac4a54d08
```

## Repository Structure

```
├── modules/
│   ├── organizations/     # Org, OUs, member accounts
│   ├── scp/               # Service Control Policies
│   ├── transit-gateway/   # TGW + RAM sharing
│   └── vpc/               # Reusable VPC module
├── accounts/
│   ├── management/
│   │   ├── organizations/
│   │   └── scp/
│   ├── shared-services/
│   │   ├── transit-gateway/
│   │   └── vpc/
│   └── workload/
│       └── vpc/
└── terragrunt.hcl         # Root config (provider, backend, common inputs)
```

## Next Steps

- [ ] Centralized logging (CloudTrail, VPC Flow Logs → S3)
- [ ] IAM Identity Center (SSO across accounts)
- [ ] Infrastructure CI/CD pipeline
- [ ] AWS Config rules for continuous compliance

---

*Built as a portfolio project demonstrating enterprise-grade AWS architecture patterns.*
