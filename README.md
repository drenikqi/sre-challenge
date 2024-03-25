# AWS EKS Cluster and ArgoCD Setup with Terraform

This project automates the setup of an AWS EKS cluster using Terraform. It includes the installation of the AWS Load Balancer Controller (ALB Controller) with the necessary roles and the deployment of ArgoCD for continuous delivery. After the initial setup, you can deploy applications using Helm charts located in the `helm_charts` directory.

## Project Overview

- **Terraform**: Automates the creation of the AWS EKS cluster, VPC, ALB, ArgoCD and associated resources.
- **AWS Load Balancer Controller**: Manages Elastic Load Balancers for a Kubernetes cluster on AWS.
- **ArgoCD**: A declarative, GitOps continuous delivery tool for Kubernetes.
- **PostgreSQL backups**: Cronjob for creating Postgresql backups and uploading them to S3.

## Prerequisites

- AWS CLI, configured with EKS and VPC creation (including NAT gateways and subnets) access.
- Terraform installed
- Helm installed

## Getting Started

1. **Initialize Terraform:**

    Navigate to the Terraform directory and initialize the Terraform project:

    ```bash
    cd terraform
    terraform init
    ```

2. **Plan and Apply:**

    Review the execution plan and apply it to create the AWS EKS cluster along with VPC, ALB controller and ArgoCD:

    ```bash
    terraform plan
    terraform apply
    ```

    Confirm the action in the CLI when prompted.

## Deploying Helm Charts

After setting up the EKS cluster, ALB Controller, and ArgoCD, you can deploy applications using Helm:

- Navigate to the `helm_charts` directory:

  ```bash
  cd helm_charts
  ```
See the [helm_charts/README.md](helm_charts/README.md) file for more information on deploying the Helm charts.
## Cleanup
To remove all the resources created by Terraform:

```bash
cd terraform
terraform destroy
```

### Rationale

This project was designed with the intention of creating a scalable, secure, and highly available Kubernetes environment using AWS EKS, complemented by robust deployment mechanisms via ArgoCD and efficient load balancing through the AWS Load Balancer Controller.

**AWS EKS**: Chosen for its seamless integration with AWS services, EKS provides a managed Kubernetes service that eliminates the complexity of managing the control plane. It offers high availability, scalability, and security which are crucial for production-grade environments.

**AWS Load Balancer Controller**: Integrating the AWS Load Balancer Controller enables us to leverage AWS’s native load balancing technologies directly within our Kubernetes ecosystem. This choice was driven by the need for a robust solution that can automatically adjust to the changing traffic and operational demands, ensuring high availability and fault tolerance.

**ArgoCD**: Adopting ArgoCD for continuous delivery aligns with our goal to implement a GitOps approach. ArgoCD automates the deployment of applications, allowing us to maintain and track versions based on Git repositories. This enhances our deployment processes with better control, auditability, and ease of use.

**Terraform**: For infrastructure provisioning, I opted for a modular approach using Terraform. By leveraging modules rather than writing extensive individual resources, I minimize code redundancy and improve readability and maintainability. This approach significantly reduces the effort needed to manage infrastructure as code. Additionally, I've configured Terraform to save state information in an S3 bucket, ensuring our infrastructure state is securely stored and easily accessible for team collaboration.

**Traefik**: For the ingress solution, I opted for a DaemonSet deployment strategy. This ensures that Traefik pods are launched in every worker node, providing a consistent entry point for all inbound traffic and ensuring that the load balancing capabilities are uniformly distributed across the cluster. This setup enhances the overall performance and reliability of our application traffic management.

**PostgreSQL**: I chose the replication architecture for the PostgreSQL setup, consisting of one primary and two read replicas, with persistence enabled. This design was selected to ensure high availability and data durability. By enabling persistence, I ensured that the data remains safe across pod restarts and deployments, essential for maintaining the stateful nature of database services.

Furthermore, I added the **podAffinityPreset** to the configuration to distribute the PostgreSQL pods across different worker nodes. This approach provides added protection against node failure, ensuring that not all database instances are affected simultaneously and thereby enhancing the overall resilience of the system.

By implementing this architecture, I aimed to achieve a balance between high availability, data integrity, and performance, ensuring that the application can handle read-heavy workloads more efficiently while maintaining consistent data across the database replicas.

**Keycloak**: For the authentication layer, I deployed Keycloak with three replica pods to enhance system resiliency. The decision to use multiple replicas is rooted in the need for high availability and fault tolerance; should one Keycloak instance become unavailable, the other replicas can continue to handle authentication requests without service interruption.

In addition to the replication setup, I enabled the service monitor and PrometheusRule within Keycloak for seamless integration with the kube-prometheus-stack. This allows for detailed monitoring and alerting capabilities, ensuring that I can maintain a proactive stance on the health and performance of the authentication services.

Furthermore, I connected Keycloak to an external PostgreSQL database that was set up earlier in the project. This approach not only leverages the high availability and data persistence features of the PostgreSQL setup but also ensures that Keycloak has a robust and scalable database backend, which is crucial for managing the authentication data and transactions efficiently.

By configuring Keycloak in this manner, I aimed to create a secure, scalable, and resilient authentication framework that integrates smoothly with the rest of the Kubernetes infrastructure and monitoring systems.

**Retool**: For internal tooling, I set up Retool, also connecting it to the external PostgreSQL database established earlier. This decision ensures consistency across our services and leverages the reliability and availability of the pre-configured PostgreSQL setup. The use of an external database with Retool helps in managing application data more effectively, while also ensuring that the data remains secure and scalable alongside our growing needs.

Additionally, I integrated Retool with Keycloak for seamless user authentication and management. This integration is crucial for maintaining a centralized user authentication system, allowing for consistent security policies and simplified user management across our internal tools. By connecting Retool with Keycloak, I enabled single sign-on (SSO) capabilities, enhancing user experience by reducing the need for multiple logins and improving security by centralizing user credentials and access control.

By configuring Retool in this manner, I aimed to ensure that our internal tools are both easy to use and secure, enhancing productivity while maintaining high standards of security and data integrity.

**PostgreSQL Backups**: Understanding the critical nature of our data, I've implemented a Kubernetes cron job to manage PostgreSQL backups regularly. This cron job is configured to create backups of the PostgreSQL database at scheduled intervals and then upload these backups directly to an S3 bucket. This approach was chosen for its simplicity and reliability, leveraging AWS's robust storage solutions for long-term data preservation.

The use of a cron job allows for automated, periodic backups without manual intervention, ensuring that we always have recent snapshots of our data available. By storing these backups in S3, we benefit from AWS's durability and scalability, providing a secure and cost-effective solution for disaster recovery. In the event of a system failure or data corruption, these backups can be quickly retrieved and used to restore the PostgreSQL database to a previous state, minimizing downtime and data loss.

By incorporating this backup strategy, I aimed to add an extra layer of protection for our data, ensuring that we can recover quickly from unforeseen incidents and maintain the integrity and availability of our services.


#### Sources
(EKS) https://github.com/terraform-aws-modules/terraform-aws-eks  
(ArgoCD) https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd  
(Traefik) https://github.com/traefik/traefik-helm-chart  
(PostgreSQL) https://github.com/bitnami/charts/tree/main/bitnami/postgresql  
(Keycloak) https://github.com/bitnami/charts/tree/main/bitnami/keycloak  
(Retool) https://docs.retool.com/self-hosted/quickstarts/kubernetes/helm  
(Retool) https://docs.retool.com/sso/quickstarts/custom/oidc  
(Monitoring) https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack  
