# Terraform Azure Infrastructure Project

---

## Overview

This repository contains a Terraform project that provisions and manages a complete set of resources on Microsoft Azure. The goal of this project is to deploy a production-ready infrastructure, including App Services, MySQL databases, Redis cache, Blob Storage, and an Application Gateway, while ensuring security and scalability. The infrastructure is designed to utilize private networking for enhanced security, with minimal exposure to public endpoints. 

### Key Highlights:
- **App Services**: Includes Azure App Service and App Service Plan, configured for private networking and integration with other services like MySQL, Redis, and Blob Storage.
- **Database**: MySQL servers with replica configurations for high availability and reliability, all within secure private networks.
- **Redis Cache**: Provisioned with private endpoints to avoid public exposure, improving performance and security.
- **Blob Storage**: Configured for secure data storage and retrieval with managed access.
- **Application Gateway**: Configured for SSL termination and traffic routing, ensuring efficient and secure delivery of web traffic.
- **Networking**: Comprehensive management of Virtual Networks (VNets) and subnets to create an isolated and secure environment for resources.
- **Modular Design**: Organized into reusable modules for improved maintainability and scalability.

This project is designed with production environments in mind, incorporating Terraform best practices, dependency management, and secure secrets handling.

---

## Features

1. **Modular Infrastructure**: The project employs a modular structure where each resource or related set of resources (e.g., App Service, MySQL, Redis) is isolated into separate modules, making the code reusable and easier to maintain.
2. **Dynamic Naming**: Resources are dynamically named using a random string suffix to avoid conflicts, especially in shared or multi-environment setups.
3. **Private Networking**: All services are integrated into a Virtual Network (VNet) with private endpoints, ensuring secure communication.
4. **SSL Configuration**: The Application Gateway is set up with an SSL certificate to ensure secure traffic encryption.
5. **Dependency Management**: Inter-module dependencies are explicitly defined, ensuring resources are created in the correct order.
6. **Customizability**: Variables are extensively used, allowing easy customization for different environments or resource configurations.

---

## Infrastructure Details

### App Service
- **Purpose**: Hosts web applications in a secure and scalable environment.
- **Features**:
  - App Service Plan configuration.
  - Private endpoint integration for secure communication.
  - Configured with Redis Cache, MySQL, and Blob Storage for backend services.
- **Security**:
  - Communication occurs within the private subnet.
  - No public endpoint is exposed.

### MySQL Database
- **Purpose**: Provides a scalable and secure relational database solution.
- **Features**:
  - Primary and replica configurations for high availability.
  - Integration with App Service for backend operations.
- **Security**:
  - Private endpoint for database access.
  - Admin credentials securely passed through Terraform variables.

### Redis Cache
- **Purpose**: Provides high-performance caching to improve application response times.
- **Features**:
  - Configured with private networking.
  - Secure access keys provided as outputs.
- **Security**:
  - Private endpoint access only.

### Blob Storage
- **Purpose**: Provides secure and scalable storage for application data.
- **Features**:
  - Blob containers for data organization.
  - Integration with App Service for storing user data or application logs.
- **Security**:
  - Private endpoint for secure access.
  - Access keys managed securely within Terraform.

### Application Gateway
- **Purpose**: Acts as a load balancer and secure traffic router for web applications.
- **Features**:
  - SSL termination for secure traffic.
  - Configured backend pools for App Service.
- **Security**:
  - Private subnet integration.
  - Uses SSL certificates for encrypted communication.

### Networking
- **Purpose**: Provides the backbone for secure communication between resources.
- **Features**:
  - VNet configuration with multiple subnets for isolation.
  - Dynamic allocation of subnet IDs using Terraform variables.
- **Security**:
  - Ensures no resource is directly accessible from the public internet.

---

## Project Structure

- **main.tf**: Main configuration file.
- **providers.tf**: Provider configurations.
- **modules/**: Directory for reusable resource modules:
  - **network/**: VNet and subnet configurations.
  - **appservice/**: App Service configurations.
  - **db/**: MySQL database configurations.
  - **redis/**: Redis Cache configurations.
  - **blob_storage/**: Blob Storage configurations.
  - **application_gateway/**: Application Gateway configurations.
- **cert/**: Directory for SSL certificates.
- **ReadMe.md**: Documentation for the project.

---

## Security Considerations

1. **Secrets Management**:
   - Use Azure Key Vault to securely manage sensitive information such as database credentials and SSL passwords.
   - Avoid hardcoding sensitive values directly in the Terraform files.

2. **State Management**:
   - Use a remote backend such as Azure Blob Storage to securely store Terraform state files.
   - Enable state locking to prevent concurrent changes.

3. **Private Networking**:
   - All resources should be accessible only through private endpoints.
   - Ensure proper firewall rules for additional layers of security.

---

## Contributions

We welcome contributions! If you encounter issues or have suggestions for new features, feel free to submit an issue or create a pull request.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Prerequisites

1. Install [Terraform CLI](https://www.terraform.io/downloads).
2. Ensure access to an Azure subscription with sufficient permissions to create and manage resources.
3. Install Azure CLI for easy authentication and testing.

---

## Setup Instructions

### Clone the Repository
```bash
git clone https://github.com/abdelrhman-kh/Terraform-Azure-PrivateInfra.git
cd Terraform-Azure-PrivateInfra
```






---
---
---
# Initialize Terraform

Run `terraform init` to initialize the Terraform deployment. This command downloads the Azure provider required to manage your Azure resources.

Console:

```bash
terraform init -upgrade
```

### Key points:

- The `-upgrade` parameter upgrades the necessary provider plugins to the newest version that complies with the configuration's version constraints.

---

# Create a Terraform execution plan

Run `terraform plan` to create an execution plan.

Console:

```bash
terraform plan -out main.tfplan
```

### Key points:

- The `terraform plan` command creates an execution plan, but doesn't execute it. Instead, it determines what actions are necessary to create the configuration specified in your configuration files. This pattern allows you to verify whether the execution plan matches your expectations before making any changes to actual resources.
- The optional `-out` parameter allows you to specify an output file for the plan. Using the `-out` parameter ensures that the plan you reviewed is exactly what is applied.

---

# Apply a Terraform execution plan

Run `terraform apply` to apply the execution plan to your cloud infrastructure.

Console:

```bash
terraform apply main.tfplan
```

### Key points:

- The example `terraform apply` command assumes you previously ran `terraform plan -out main.tfplan`.
- If you specified a different filename for the `-out` parameter, use that same filename in the call to `terraform apply`.
- If you didn't use the `-out` parameter, call `terraform apply` without any parameters.

---

# Clean up resources

When you no longer need the resources created via Terraform, do the following steps:

1. Run `terraform plan` and specify the destroy flag.

Console:

```bash
terraform plan -destroy -out main.destroy.tfplan
```

### Key points:

- The `terraform plan` command creates an execution plan, but doesn't execute it. Instead, it determines what actions are necessary to destroy the resources specified in your configuration files. This pattern allows you to verify whether the execution plan matches your expectations before making any changes to actual resources.
- The optional `-out` parameter allows you to specify an output file for the plan. Using the `-out` parameter ensures that the plan you reviewed is exactly what is applied.

2. Run `terraform apply` to apply the execution plan.

Console:

```bash
terraform apply main.destroy.tfplan
```
