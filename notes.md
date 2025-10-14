# Installation and set-up steps:

### Launch an ubuntu ec2 instance with t3.medium 
*To create a 2GB of swap file *
```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# To make it permanent (across reboots):
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

*set hostname*
```bash
sudo hostnamectl set-hostname master
```
*instll docker*
```bash
sudo apt-get install docker.io -y

sudo usermod -aG docker $USER && newgrp docker
```

*instll java*

```bash
sudo apt install openkdk-21-jdk -y
```

*instll maven*
```bash
sudo apt install maven -y
```
*install jenkins*
```bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

apt update -y
apt install -y jenkins
```
*slack notification setup: *
*install 'slack notification' plugin, and create slac-jenkins integratin in system settings*

*making commumication between docker and jenkins*
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

*install trivy on ubunut*
```bash
sudo apt-get install wget gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
```
*to crate a github webhook for jenkins*
```text
http://your-jenkins-url(ip:port)/github-webhook/
```

* Creaate Self Managed K8S KIND cluster (docker is pre-requisite) *
```bash
sudo apt-get install docker.io -y
sudo systemctl status docker
sudo systemctl is-enabled docker
whoami
sudo usermod -aG docker ${USER} && newgrp docker # Add your user to the docker group && # Apply the group change immediately
```
*install kubectl *
```bash
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```
or
```bash
sudo snap install kubectl --classic
```

*Install KIND*
```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```
or
```bash
curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.20.0/kind-linux-amd64 # Replace v0.20.0 with the latest version
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

```bash
vim kind-config.yaml
```
```bash
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    image: kindest/node:v1.33.1
  - role: worker
    image: kindest/node:v1.33.1
  - role: worker
    image: kindest/node:v1.33.1
  - role: worker
    image: kindest/node:v1.33.1
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
```
or
```bash
# Save this as kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```
```bash
kind create cluster --config kind-config.yaml
```
if you want to specify a name to your cluster,
```bash
kind create cluster --name my-cluster --config kind-config.yaml
```
*Enable Ingress (for local testing)*
If you need ingress support inside KIND:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/kind/deploy.yaml
```
Install helm
```bash
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```

*Datadog for self managed k8s cluster *

```bash
helm repo add datadog https://helm.datadoghq.com
helm install datadog-operator datadog/datadog-operator
kubectl create secret generic datadog-secret --from-literal api-key=183bfd8be35e2e91c9b592c433567a7e
```
```yaml
kind: "DatadogAgent"
apiVersion: "datadoghq.com/v2alpha1"
metadata:
  name: "datadog"
spec:
  global:
    site: "datadoghq.com"
    credentials:
      apiSecret:
        secretName: "datadog-secret"
        keyName: "api-key"
  features:
    apm:
      instrumentation:
        enabled: true
        targets:
          - name: "default-target"
            ddTraceVersions:
              java: "1"
              python: "3"
              js: "5"
              php: "1"
              dotnet: "3"
              ruby: "2"
    logCollection:
      enabled: true
      containerCollectAll: true
````
