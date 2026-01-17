# priyata-example

## Prerequisites

Before you begin, ensure you have the following installed:
- Docker
- AWS CLI (configured with your AWS credentials)
- Access to AWS ECR repository

## Building the Docker Image

To build the Docker image locally, run the following command in the project directory:

```bash
docker build -t priyata-example:latest .
```

**Options:**
- `-t` or `--tag`: Specifies the name and optionally a tag for the image (format: `name:tag`)
- `.`: Specifies the build context (current directory containing the Dockerfile)

**Example with version tag:**
```bash
docker build -t priyata-example:v1.0 .
```

## Running the Docker Image

To run the Docker image locally, use the following command:

```bash
docker run priyata-example:latest
```

**Common options:**
- `--name <container-name>`: Assigns a name to the container
- `-d`: Runs the container in detached mode (background)
- `-it`: Runs in interactive mode with a terminal
- `-p <host-port>:<container-port>`: Maps ports (if your application needs it)

**Example with container name:**
```bash
docker run --name my-priyata-container priyata-example:latest
```

**Example in detached mode:**
```bash
docker run -d --name my-priyata-container priyata-example:latest
```

## Pushing to AWS ECR

### Step 1: Get AWS Account ID and Create ECR Repository

```bash
# Get your AWS Account ID
aws sts get-caller-identity --query Account --output text
```

### Step 2: Create an ECR Repository (if not already created)

```bash
aws ecr create-repository --repository-name priyata-example --region <your-region>
```

Replace `<your-region>` with your AWS region (e.g., `us-east-1`)

### Step 3: Retrieve ECR Login Token and Authenticate Docker

```bash
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.<your-region>.amazonaws.com
```

Replace:
- `<your-region>` with your AWS region
- `<aws-account-id>` with your AWS Account ID

### Step 4: Tag the Image for ECR

```bash
docker tag priyata-example:latest <aws-account-id>.dkr.ecr.<your-region>.amazonaws.com/priyata-example:latest
```

### Step 5: Push the Image to ECR

```bash
docker push <aws-account-id>.dkr.ecr.<your-region>.amazonaws.com/priyata-example:latest
```

**Full workflow example:**
```bash
# Assuming AWS_ACCOUNT_ID=123456789012 and AWS_REGION=us-east-1
docker tag priyata-example:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/priyata-example:latest
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/priyata-example:latest
```

## Deleting the Local Docker Image

After successfully pushing to AWS ECR, you can remove the local image to free up disk space:

### Delete by Image Tag

```bash
docker rmi priyata-example:latest
```

### Delete by Image ID

```bash
docker images  # First, list all images to find the IMAGE ID
docker rmi <image-id>
```

### Force Delete (if image is in use)

```bash
docker rmi -f priyata-example:latest
```

### Delete All Associated Images

To remove both the local image and the ECR-tagged image:

```bash
docker rmi priyata-example:latest <aws-account-id>.dkr.ecr.<your-region>.amazonaws.com/priyata-example:latest
```

### Verify Deletion

```bash
docker images | grep priyata-example
```

If no output is returned, the image has been successfully deleted.

## Complete Workflow Script

Here's a complete example combining all steps:

```bash
#!/bin/bash

# Configuration
AWS_ACCOUNT_ID="123456789012"
AWS_REGION="us-east-1"
IMAGE_NAME="priyata-example"
IMAGE_TAG="latest"

# Step 1: Build the image
echo "Building Docker image..."
docker build -t $IMAGE_NAME:$IMAGE_TAG .

# Step 2: Authenticate with ECR
echo "Authenticating with ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Step 3: Tag the image for ECR
echo "Tagging image for ECR..."
docker tag $IMAGE_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:$IMAGE_TAG

# Step 4: Push to ECR
echo "Pushing image to ECR..."
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:$IMAGE_TAG

# Step 5: Delete local images
echo "Deleting local images..."
docker rmi $IMAGE_NAME:$IMAGE_TAG
docker rmi $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:$IMAGE_TAG

echo "Done!"
```

Save this script as `deploy-to-ecr.sh`, make it executable with `chmod +x deploy-to-ecr.sh`, and run it with `./deploy-to-ecr.sh`

## Troubleshooting

- **Authentication Error**: Ensure your AWS credentials are configured correctly and you have permission to push to ECR
- **Repository Not Found**: Make sure the ECR repository exists in your AWS account in the specified region
- **Image in Use**: If you can't delete the image, stop all running containers first with `docker stop <container-id>`
- **Permission Denied**: Run Docker commands with `sudo` if you see permission errors, or add your user to the docker group