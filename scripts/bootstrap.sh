#!/bin/bash
# Bootstrap script for Terraform state backend
# Run this ONCE before first Terragrunt apply

# String Mode
# -e          flag exits on any command failure
# -u          flag exits on undefined variable references
# -o pipefail flag handles a failure w/ piped commands

set -euo

#------------------------------------------------------------------------------
# Colors for output | ANSI escape codes. 
#------------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# -e flag on echo tells it to interpret escape sequences. 

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Terraform State Backend Bootstrap${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

#------------------------------------------------------------------------------
# CONFIGURATION - CHANGE THESE VALUES
#------------------------------------------------------------------------------
AWS_PROFILE="management"  # Change if using named profile
AWS_REGION="us-east-1"
LOCK_TABLE="terraform-locks"


#------------------------------------------------------------------------------
# Validate AWS credentials
#------------------------------------------------------------------------------

echo -e "${YELLOW}Checking AWS credentials...${NC}"


if ! ACCOUNT_ID=$(aws sts get-caller-identity --profile "$AWS_PROFILE" --query Account --output text 2>/dev/null); then
    echo -e "${RED}ERROR: AWS credentials not configured or invalid${NC}"
    echo ""
    echo "Configure AWS with access key and secret access key..."
    echo "Run: aws configure --profile $AWS_PROFILE"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --profile "$AWS_PROFILE" --query Account --output text)


echo -e "${GREEN}✓ Authenticated to account: $ACCOUNT_ID${NC}"
echo ""

STATE_BUCKET="tfstate-management-${ACCOUNT_ID}-${AWS_REGION}" # Must be globally unique

#------------------------------------------------------------------------------
# Create S3 bucket for state
#------------------------------------------------------------------------------
echo -e "${YELLOW}Creating S3 bucket for Terraform state...${NC}"

if aws s3api head-bucket --bucket "$STATE_BUCKET" --profile "$AWS_PROFILE" 2>/dev/null; then
    echo -e "${GREEN}✓ Bucket already exists: $STATE_BUCKET${NC}"
else
    # Create bucket (different command for us-east-1)
    if [ "$AWS_REGION" = "us-east-1" ]; then
        aws s3api create-bucket \
            --bucket "$STATE_BUCKET" \
            --profile "$AWS_PROFILE" \
            --region "$AWS_REGION"
    else
        aws s3api create-bucket \
            --bucket "$STATE_BUCKET" \
            --profile "$AWS_PROFILE" \
            --region "$AWS_REGION" \
            --create-bucket-configuration LocationConstraint="$AWS_REGION"
    fi
    echo -e "${GREEN}✓ Created bucket: $STATE_BUCKET${NC}"
fi

# Enable versioning
echo -e "${YELLOW}Enabling versioning on state bucket...${NC}"

aws s3api put-bucket-versioning \
    --bucket "$STATE_BUCKET" \
    --profile "$AWS_PROFILE" \
    --versioning-configuration Status=Enabled
echo -e "${GREEN}✓ Versioning enabled${NC}"

# Enable encryption
echo -e "${YELLOW}Enabling encryption on state bucket...${NC}"
aws s3api put-bucket-encryption \
    --bucket "$STATE_BUCKET" \
    --profile "$AWS_PROFILE" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "aws:kms"
            },
            "BucketKeyEnabled": true
        }]
    }'
echo -e "${GREEN}✓ Encryption enabled (SSE-KMS)${NC}"

# Block public access
echo -e "${YELLOW}Blocking public access...${NC}"
aws s3api put-public-access-block \
    --bucket "$STATE_BUCKET" \
    --profile "$AWS_PROFILE" \
    --public-access-block-configuration '{
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }'
echo -e "${GREEN}✓ Public access blocked${NC}"
echo ""

#------------------------------------------------------------------------------
# Create DynamoDB table for state locking
#------------------------------------------------------------------------------
echo -e "${YELLOW}Creating DynamoDB table for state locking...${NC}"

if aws dynamodb describe-table --table-name "$LOCK_TABLE" --profile "$AWS_PROFILE" --region "$AWS_REGION" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Table already exists: $LOCK_TABLE${NC}"
else
    aws dynamodb create-table \
        --table-name "$LOCK_TABLE" \
        --profile "$AWS_PROFILE" \
        --region "$AWS_REGION" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --tags Key=Project,Value=landing-zone Key=ManagedBy,Value=Terraform
    
    echo -e "${YELLOW}Waiting for table to be active...${NC}"
    aws dynamodb wait table-exists \
        --table-name "$LOCK_TABLE" \
        --profile "$AWS_PROFILE" \
        --region "$AWS_REGION"
    echo -e "${GREEN}✓ Created table: $LOCK_TABLE${NC}"
fi
echo ""

#------------------------------------------------------------------------------
# Summary
#------------------------------------------------------------------------------
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Bootstrap Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "State Bucket: $STATE_BUCKET"
echo "Lock Table:   $LOCK_TABLE"
echo "Region:       $AWS_REGION"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Update terragrunt.hcl with your bucket name: $STATE_BUCKET"
echo "2. Update accounts/management/organizations/terragrunt.hcl with your email addresses"
echo "3. Run: cd accounts/management/organizations && terragrunt apply"
echo ""
