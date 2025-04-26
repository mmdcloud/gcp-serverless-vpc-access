GCP Private Access: Cloud Run to Private Instance
A secure deployment setup for connecting Cloud Run functions to private cloud instances via VPC Service Connector.
Overview
This repository contains the infrastructure code to deploy:

A serverless Cloud Run function
A private cloud instance (Compute Engine VM)
Secure connectivity between them using VPC Service Connector

Features

Serverless function execution with secure private network access
No public IP exposure for the private instance
Infrastructure as Code using Terraform
Automated CI/CD pipeline for deployment

Architecture
┌─────────────┐      ┌─────────────────┐      ┌──────────────────┐
│  Cloud Run  │──────▶ VPC Connector   │──────▶  Private Cloud   │
│  Function   │      │ Service         │      │  Instance        │
└─────────────┘      └─────────────────┘      └──────────────────┘
Getting Started
Prerequisites

Google Cloud Platform account
gcloud CLI installed
GitHub account for CI/CD integration

Installation

Clone this repository:
git clone https://github.com/yourusername/gcp-private-access.git
cd gcp-private-access

Set up your GCP credentials:
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

Run the deployment script:
./deploy.sh


Usage
Once deployed, your Cloud Run function can access the private instance via its internal IP address. The function code includes examples of how to make these connections.
Example of accessing your private instance from Cloud Run:
pythonimport requests

def access_private_instance(request):
    # The private instance is accessible via its internal IP
    response = requests.get('http://10.0.0.2:8080/api/data')
    return response.text
Configuration
Edit config.yaml to customize your deployment:
yamlproject_id: your-gcp-project
region: us-central1
vpc_connector_name: run-connector
instance_machine_type: e2-micro
Contributing

Fork the repository
Create your feature branch (git checkout -b feature/amazing-feature)
Commit your changes (git commit -m 'Add some amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a Pull Request

License
This project is licensed under the MIT License - see the LICENSE file for details.
