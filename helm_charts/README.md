# Traefik Helm Chart Installation Guide

This guide will lead you through the deployment of the Traefik ingress controller using Helm, configured specifically with a DaemonSet deployment and annotations for an AWS Network Load Balancer (NLB).

## Prerequisites

- Kubernetes cluster
- Helm installed
- kubectl configured to connect to your cluster

## Adding the Helm Chart Repository

Begin by adding the Traefik Helm repository:

```bash
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
```

### Configuration
Create a YAML file named `values.yaml` ([already created](traefik-26.1.0/traefik/values.yaml)) and include the following configurations:

```yaml
## Deployment configuration ##
deployment:
  kind: DaemonSet

## Service configuration ##
service:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
```

These settings modify the default Traefik deployment to use a DaemonSet, ensuring a Traefik pod runs on every node. Additionally, they configure the service to use an AWS Network Load Balancer (NLB) through annotations.

### Installing the Chart
To install the chart with the release name traefik, execute the following command:

```bash
helm install traefik traefik/traefik -f values.yaml -n ingress --create-namespace
```

This command deploys Traefik on the Kubernetes cluster with your custom configuration. The values.yaml file contains the necessary changes for your setup.

### Verifying the Installation
After the deployment, you can check the status of your Traefik Pods:

```bash
kubectl get po -n ingress
```

# PostgreSQL Helm Chart Installation Guide

This guide will walk you through the process of deploying a PostgreSQL instance with specific configurations using Helm. The instance is set up with a replication architecture, custom resource allocations, pod affinity, and persistence settings.

## Prerequisites

- Kubernetes cluster
- Helm installed
- kubectl configured to connect to your cluster

### Adding the Helm Chart Repository

First, add the Bitnami Helm repository that contains the PostgreSQL chart:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```
### Configuration
Create a YAML file named `values.yaml` ([already created](postgresql-15.1.2/postgresql/values.yaml)) and paste the following configurations:

```yaml
## Primary server configuration ##
primary:
  architecture: replication
  resources:
    requests:
      cpu: 2
      memory: 512Mi
    limits:
      cpu: 3
      memory: 1024Mi
  podAffinityPreset: hard
  persistence:
    size: 8Gi

## Read replicas configuration ##
readReplicas:
  replicaCount: 2
  resources: {}
  podAffinityPreset: hard
  persistence:
    size: 8Gi
```
These settings configure the primary PostgreSQL instance and its read replicas with specific CPU, memory, and storage allocations, and set a hard pod affinity to ensure the pods are scheduled according to specific rules.

### Installing the Chart
To install the chart with the release name postgres, run the following command:

```bash
helm install postgres bitnami/postgresql -f values.yaml -n database --create-namespace
```
This command deploys PostgreSQL on the Kubernetes cluster with the specified configuration.

### Accessing the Database
After deploying, you can retrieve the postgres user password with the following command:

```bash
kubectl get secret -n database postgres -o jsonpath="{.data.postgresql-password}" | base64 --decode
```

# Keycloak Helm Chart Installation Guide

This guide will assist you in deploying a Keycloak instance using Helm with specific configurations tailored for production environments, including setting up pod affinity, resource allocations, ingress, and external database connections.

## Prerequisites

- Kubernetes cluster
- Helm installed
- kubectl configured to connect to your cluster
- External PostgreSQL database accessible within your Kubernetes cluster (if not using the built-in option)

### Adding the Helm Chart Repository

Begin by adding the Codecentric Helm repository which contains the Keycloak chart:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### Configuration
Create a YAML file named `values.yaml` ([already created](keycloak-19.3.4/keycloak/values.yaml)) and include the following configurations:

```yaml
## Authentication ##
auth:
  adminUser: "admin"
  adminPassword: # Leave blank for Helm to auto-generate a password

## General settings ##
production: true
proxy: edge
replicaCount: 3

## Resources configuration ##
resources:
  requests:
    cpu: "2"
    memory: "512Mi"
  limits:
    cpu: "3"
    memory: "1024Mi"

## Affinity settings ##
podAffinityPreset: hard

## Ingress ##
#OPTIONAL
ingress:
  enabled: true
  ingressClassName: traefik

## Metrics ##
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    namespace: monitoring
  prometheusRule:
    enabled: true
    namespace: monitoring

## External database configuration ##
postgresql:
  enabled: false
externalDatabase:
  host: postgresql-primary-0.postgresql-primary-hl.database.svc.cluster.local
  port: 5432
  user: postgres
  database: bitnami_keycloak 
  password: "password" # postgresql password retrieved earlier in the postgresql installation
```

Ensure to replace the external database settings with those corresponding to your own external PostgreSQL instance and *make sure the database exists*.

### Installing the Chart
To install the chart with the release name keycloak, execute the following command:

```bash
helm install keycloak bitnami/keycloak -f values.yaml -n identity --create-namespace
```

This command deploys Keycloak on the Kubernetes cluster with your custom settings.

### Accessing Keycloak
Once deployed, you can access your Keycloak instance through the ingress endpoint, which should be set up according to the domain configured in your ingress settings.

# Setting up Keycloak for Retool Authentication

This guide will walk you through setting up Keycloak to authenticate with Retool. You'll create a new realm and client in Keycloak, configure the client for OpenID Connect, and retrieve necessary endpoints for integration.

## Step 1: Create a New Realm

1. Log into your Keycloak admin console.
2. In the top-left corner, click on the current realm name to open the realm dropdown.
3. Click on `Add realm`.
4. Give your new realm a name and click `Create`.

## Step 2: Create a New Client

1. In the left-hand menu, click `Clients`.
2. Click `Create` to add a new client.
3. Fill in the following details:
   - `Client ID`: `retool`
   - `Client Type`: Choose `openid-connect`.
   - `Client authentication`: Switch to `On`.
   - In the `Valid Redirect URIs` field, enter your Retool application address followed by `/*` (e.g., `https://your-retool-app.com/*`).
4. Click `Save`.

## Step 3: Retrieve the Client Secret

1. On the same page, go to the `Credentials` tab.
2. Here you will find the `Client Secret`. Click the `Copy` button or make a note of this secret, as you will need it to configure authentication in Retool.

## Step 4: Retrieve Endpoints Information

1. Navigate back to the Keycloak admin console's main page.
2. Click on `Realm Settings`.
3. Scroll down to the `Endpoints` field.
4. Click on `OpenID Endpoint Configuration`.
5. In the opened JSON document, find and note down `authorization_endpoint` and `token_endpoint`. These will be used in your Retool authentication settings.

# Retool Helm Chart Installation Guide

This guide details the steps to deploy a Retool instance using Helm with custom configurations, including external PostgreSQL and Bitnami Keycloak integration for authentication.

## Prerequisites

- Kubernetes cluster
- Helm installed
- kubectl configured to connect to your cluster
- An existing PostgreSQL database
- An existing Keycloak instance for authentication

## Configuration

Create a YAML file named `values.yaml` ([already created](retool-6.1.2/retool/values.yaml)) and paste the following configurations:

```yaml
## Retool specific configurations ##
config:
  licenseKey: "xxxx-xxxxx-xxxx-xxx"
  jwtSecret: "replace-with-your-own-jwt-secret"
  encryptionKey: "replace-with-your-own-encryption-key"
  postgresql:
    host: "postgresql-primary-0.postgresql-primary-hl.database.svc.cluster.local"
    port: 5432
    db: "retool"
    user: "postgres"
    password: "password"

## Image configuration ##
image:
  tag: "3.20.18"

## Workflow and Executor configuration ##
workflows:
  enabled: true
codeExecutor:
  enabled: true

## Ingress Configuration ##
ingress:
  enabled: false

## Postgresql Configuration ##
postgresql:
  enabled: false

## Environment Variables for Keycloak Integration ##
environmentVariables:
  - name: CUSTOM_OAUTH2_SSO_CLIENT_ID
    value: "retool-auth"
  - name: CUSTOM_OAUTH2_SSO_CLIENT_SECRET
    value: "<client secret from keycloak>"
  - name: CUSTOM_OAUTH2_SSO_SCOPES
    value: "openid email profile offline_access"
  - name: CUSTOM_OAUTH2_SSO_AUTH_URL
    value: "<keycloak_auth_url>"
  - name: CUSTOM_OAUTH2_SSO_TOKEN_URL
    value: "<keycloak_token_url>"
  - name: CUSTOM_OAUTH2_SSO_JWT_EMAIL_KEY
    value: "idToken.email"
  - name: CUSTOM_OAUTH2_SSO_JWT_FIRST_NAME_KEY
    value: "idToken.given_name"
  - name: CUSTOM_OAUTH2_SSO_JWT_LAST_NAME_KEY
    value: "idToken.family_name"
  - name: CUSTOM_OAUTH2_SSO_JWT_ROLES_KEY
    value: "idToken.groups"
  - name: CUSTOM_OAUTH2_SSO_ROLE_MAPPING
    value: "devops -> admin, support -> viewer"
```

Replace the placeholders (e.g., <client secret from keycloak>, <keycloak_auth_url>, <keycloak_token_url>) with actual values from your Keycloak instance.

### Installing the Chart
To install the chart with the release name retool, run the following command:

```bash
helm repo add retool https://charts.retool.com
helm install retool retool/retool -f values.yaml -n retool --create-namespace
```

#### Verifying the Installation
After the deployment, you can verify that your Retool pods are up and running:

```bash
kubectl get pods -n retool
```

### Accessing Retool
If you have not enabled Ingress, you can access Retool through port forwarding:

```bash
kubectl port-forward svc/my-retool 3000:3000 -n retool
```

Then, navigate to http://localhost:3000 in your web browser.

# Setting Up kube-prometheus-stack 

This guide outlines how to install the kube-prometheus-stack chart with custom persistence settings for Grafana and Prometheus.

## Prerequisites

- Kubernetes cluster
- Helm installed
- kubectl configured to connect to your cluster

## Add Helm Repository

First, add the Prometheus Community Helm repository and update:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### Configuration
Create a YAML file named `values.yaml` with the following content to configure persistence for Grafana and Prometheus:

```yaml
grafana:
  persistence:
    enabled: true
    type: sts
    storageClassName: "<storageclassname>"
    accessModes:
      - ReadWriteOnce
    size: 10Gi
    finalizers:
      - kubernetes.io/pvc-protection

prometheus:
  prometheusSpec:
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: "<storageclassname>"
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi
```

Replace \<storageclassname> with the name of your storage class. This setting is crucial for specifying the type of storage and its class in your cluster.

### Installing the Chart
To install the kube-prometheus-stack with your custom values, run:

```bash
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -f values.yaml -n monitoring --create-namespace
```
This command deploys the kube-prometheus-stack on the Kubernetes cluster, applying the Grafana and Prometheus storage configurations specified in values.yaml.

### Verifying the Installation
After installation, you can check the status of your deployments:

```bash
kubectl get pods -n monitoring
```

Ensure that the pods for Grafana and Prometheus are running and that the PVCs (Persistent Volume Claims) are correctly bound:

```bash
kubectl get pvc -n monitoring
```

### Accessing Grafana and Prometheus
The kube-prometheus-stack installation provides access to Grafana and Prometheus through Kubernetes services. You can port-forward these services to access them locally:

For Grafana:

```bash
kubectl port-forward svc/kube-prometheus-stack-grafana 3000 -n monitoring
```
Then, access Grafana at http://localhost:3000.

For Prometheus:

```bash
kubectl port-forward svc/kube-prometheus-stack-prometheus 9090 -n monitoring
```
Then, access Prometheus at http://localhost:9090.