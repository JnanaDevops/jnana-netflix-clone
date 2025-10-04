#this script downloads 'java',  'jenkins', 'docker', 'trivy', 'maven'

echo "###### let me first update the system and download the java-21 #####"
sudo atp update && sudo apt upgrade -y

sudo apt install openjdk-21-jdk -y
echo "########INSTALLING JENKINS#######"

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

apt update -y
apt install -y jenkins

echo "please run: 'sudo systemctl status jenkins' to check the status of jenkins service"

echo "######## INSTALLING DOCKER ##########"
sudo apt install docker.io -y
sudo usermod -aG docker $USER && newgrp docker

echo "####### INSTALLING TRIVY ############"
sudo apt-get install wget gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy


echo "########### INSTALLING MAVEN ############"
sudo apt install maven -y

echo "######## please take the jenkins initial admin pasword ######"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo "now start the jenkins & set up the 'slack-notification' then please don't foget to run 'sudo usermod -aG docker jenkins' && 'sudo systemctl restart jenkins'"
