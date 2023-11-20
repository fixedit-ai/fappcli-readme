#!/bin/bash

# Function to check if a command exists
command_exists() {
    type "$1" &> /dev/null
}

# Check if AWS CLI is installed
if ! command_exists aws; then
    echo "Error: AWS CLI is not installed. Please install it and try again."
    exit 1
fi

# Check if pip is installed
if ! command_exists pip; then
    echo "Error: pip is not installed. Please install pip/Python and try again."
    exit 1
fi

# Check if both AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Usage: ./install.sh <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY> [VERSION: optional]"
    exit 1
fi

export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2

# Check if the version argument is provided (optional), otherwise default to latest release
# If $3 is an empty string, we will list all packages (done by pip with fappcli==)
if [ $# -lt 3 ]; then
    PACKAGE=fappcli
else
    PACKAGE=fappcli==$3
fi

# Get pypi info and login token
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
CODEARTIFACT_AUTH_TOKEN=$(aws codeartifact get-authorization-token --domain acap-dev-support --domain-owner $ACCOUNT_ID --region eu-north-1 --query authorizationToken --output text)
INDEX_URL=https://aws:$CODEARTIFACT_AUTH_TOKEN@acap-dev-support-$ACCOUNT_ID.d.codeartifact.eu-north-1.amazonaws.com/pypi/acap-dev-support/simple/

echo "Installing $PACKAGE from $INDEX_URL"

# Install the package
pip install $PACKAGE --extra-index-url=$INDEX_URL