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
vim kind-cluster.yaml
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
