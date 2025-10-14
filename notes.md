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
