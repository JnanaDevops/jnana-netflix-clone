```
http - http://git.example.com/sarah/jnana.git
```

### Creating a new repository on the command line

```
touch README.md
git init

git add README.md
git commit -m "first commit"
git remote add origin http://git.example.com/sarah/jnana.git
git push -u origin master
```
### Pushing an existing repository from the command line
```
git remote add origin http://git.example.com/sarah/jnana.git
git push -u origin master
```

### These identify you in commits.
```
git config --list #to check config
```
```
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"

```

### -------------------------------------------------------------

```
sudo apt update && sudo apt upgrade -y
```
```
sudo apt install docker.io -y
```

```
sudo apt install docker-compose -y
```
```
docker --version
```

```
sudo usermod -aG docker ubuntu && newgrp docker
```

```
vi gerrit-docker-compose.yaml
```
```
version: '3'
services:
  gerrit:
    image: gerritcodereview/gerrit
    container_name: gerrit
    ports:
      - "8080:8080"
      - "29418:29418"

    volumes:
      - gerrit-data:/var/gerrit
    environment:
      - CANONICAL_WEB_URL=http://localhost:8080
volumes:
  gerrit-data:
```

```
docker-compose -f gerrit-docker-compose.yaml up -d
```

```
curl ifconfig.me
```
```
http://<EC2_PUBLIC_IP>:8080
```
### Configure SSH access for Gerrit - Generate SSH key (on your local machine OR EC2)

```
ssh-keygen -C "gerrit" #this is 'rsa' eg: id_rsa, id_rsa.pub
```
```
ssh-keygen -t ed25519 -C "gerrit"
```
```
cat ~/.ssh/id_ed25519.pub
```

###### ------------------------------------------ OOB Git HUB (start)-----------------------------

#### or if you need keys specific to each platform..
```
ssh-keygen -t ed25519 -C "gerrit" -f ~/.ssh/id_ed25519_gerrit
ssh-keygen -t ed25519 -C "github" -f ~/.ssh/id_ed25519_github
ssh-keygen -t ed25519 -C "gitlab" -f ~/.ssh/id_ed25519_gitlab
```
```
~/.ssh/
├── id_ed25519_gerrit
├── id_ed25519_gerrit.pub
├── id_ed25519_github
├── id_ed25519_github.pub
├── id_ed25519_gitlab
└── id_ed25519_gitlab.pub
```

###### ------------ or SSH (one-time setup) ------------

```
ssh-keygen -t ed25519 -C "your-email@example.com"
```

```
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

##### this command, Start agent & add key:
##### eval "$(ssh-agent -s)" - Starts the ssh-agent, a background process that securely holds your private SSH keys in memory.
##### Result: your shell is now connected to an ssh-agent.
##### ssh-add ~/.ssh/id_ed25519 - Loads your private SSH key (id_ed25519) into the running ssh-agent.
##### Result: the agent can authenticate you to servers (GitHub, servers, etc.) using that key.


#### Copy key and add it to GitHub:
```
cat ~/.ssh/id_ed25519.pub
```
###### --------------------------------------- OOB Git HUB (end) ---------------------------------------------




### Clone the Gerrit repo

```
git clone "ssh://admin@localhost:29418/jnana"
```

```
cd demo-repo
```

#### crate a file & make a commit (this will become a CR)
```
echo "Hello Gerrit" > README.md
git add README.md
git commit -m "Initial commit"
```

####### or -------------------------

```
echo "Sunday" >> sunday.txt && echo "Monday" >> monday.txt && echo "Tuesday" >> tuesday.txt && echo "Wednessday" >> wednessday.txt && echo "Thursday" >> thursday.txt && echo "Friday" >> friday.txt && echo "Saturday" >> saturday.txt
```
```
git add sunday.txt && git commit -m "sunday"
```
```
git add monday.txt && git commit -m "monday"
```
```
git add tuesday.txt && git commit -m "tuesday"
```
```
git add wednessday.txt && git commit -m "wednessday"
```
```
git add thursday.txt && git commit -m "thursday"
```
```
git add friday.txt && git commit -m "friday"
```
```
git add saturday.txt && git commit -m "saturday"
```
####### ------------------------------------------

```
git status
```

### Run this exactly inside your repo
```
gitdir=$(git rev-parse --git-dir)
scp -O -p -P 29418 admin@localhost:hooks/commit-msg $gitdir/hooks/commit-msg
chmod +x $gitdir/hooks/commit-msg
```
#### verifiy hook installed
```
ls -l .git/hooks/commit-msg
```
#### now Amend commit (this injects Change-Id)
```
git commit --amend --no-edit
```
#### now verify
```
git log -1
```
#### Push commit as a Gerrit CR (THIS IS THE KEY STEP) In Gerrit, you do NOT push to main directly.
```
git push origin HEAD:refs/for/master
```



### history
```
    1  vi gerrit-docker-compose.yaml
    2  docker-compose -f gerrit-docker-compose.yaml up -d
    3  docker ps
    4  curl ifconfig.me
    5  ssh-keygen -t ed25519 -C "gerrit"
    6  cat ~/.ssh/id_ed25519.pub
    7  git clone "ssh://admin@localhost:29418/jnana"
    8  cd jnana/
    9  ls
   10  echo "Hello Gerrit" > README.md
   11  git add README.md
   12  git commit -m "Initial commit"
   13  git status
   14  gitdir=$(git rev-parse --git-dir)
   15  scp -O -p -P 29418 admin@localhost:hooks/commit-msg $gitdir/hooks/commit-msg
   16  chmod +x $gitdir/hooks/commit-msg
   17  ls -l .git/hooks/commit-msg
   18  git commit --amend --no-edit
   19  git log -1
   20  git push origin HEAD:refs/for/master
   21  history
```

### ===================================================

### doing with script:


```
vi install-gerrit.sh
```

```
#!/bin/bash
set -e

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing Docker and Docker Compose..."
sudo apt install -y docker.io docker-compose curl

echo "Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "Adding user to docker group..."
sudo usermod -aG docker ubuntu

echo "Creating Gerrit docker-compose file..."
cat <<EOF > gerrit-docker-compose.yaml
version: '3'
services:
  gerrit:
    image: gerritcodereview/gerrit
    container_name: gerrit
    ports:
      - "8080:8080"
      - "29418:29418"
    volumes:
      - gerrit-data:/var/gerrit
    environment:
      - CANONICAL_WEB_URL=http://localhost:8080

volumes:
  gerrit-data:
EOF

echo "Starting Gerrit..."
sudo docker-compose -f gerrit-docker-compose.yaml up -d

# ---------------- Detect IPs ----------------

# 1️⃣ Localhost
LOCALHOST_URL="http://localhost:8080"

# 2️⃣ Private IP (hostname -I)
PRIVATE_IP=$(hostname -I | awk '{print $1}')
PRIVATE_URL="http://${PRIVATE_IP}:8080"

# 3️⃣ Public IP (EC2 metadata if available)
if curl --connect-timeout 2 -s http://169.254.169.254/latest/meta-data/public-ipv4 >/dev/null 2>&1; then
    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
        -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
        http://169.254.169.254/latest/meta-data/public-ipv4)
    PUBLIC_URL="http://${PUBLIC_IP}:8080"
else
    PUBLIC_URL="Not available"
fi

# ---------------- Print URLs ----------------
echo ""
echo "============================================"
echo "✅ Gerrit is starting up!"
echo ""
echo "Access Gerrit at the following URLs:"
echo ""
echo "• Localhost:    ${LOCALHOST_URL}"
echo "• Private IP:   ${PRIVATE_URL}"
echo "• Public IP:    ${PUBLIC_URL}"
echo ""
echo "============================================"
echo "⚠️ IMPORTANT:"
echo "• Ensure firewall / security group allows TCP 8080"
echo "• Log out and log back in to use Docker without sudo"

```

```
chmod +x install-gerrit.sh
./install-gerrit.sh
```



### little advanced script

```
✅ Key improvements

Auto-waits for Gerrit to respond on http://localhost:8080

Dots printed every 5 seconds so you see progress

Ensures the URLs are ready to use immediately

Works on EC2, cloud, or local machines
```

```
#!/bin/bash
set -e

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing Docker and Docker Compose..."
sudo apt install -y docker.io docker-compose curl

echo "Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "Adding user to docker group..."
sudo usermod -aG docker ubuntu

echo "Creating Gerrit docker-compose file..."
cat <<EOF > gerrit-docker-compose.yaml
version: '3'
services:
  gerrit:
    image: gerritcodereview/gerrit
    container_name: gerrit
    ports:
      - "8080:8080"
      - "29418:29418"
    volumes:
      - gerrit-data:/var/gerrit
    environment:
      - CANONICAL_WEB_URL=http://localhost:8080

volumes:
  gerrit-data:
EOF

echo "Starting Gerrit..."
sudo docker-compose -f gerrit-docker-compose.yaml up -d

# ---------------- Detect IPs ----------------
LOCALHOST_URL="http://localhost:8080"
PRIVATE_IP=$(hostname -I | awk '{print $1}')
PRIVATE_URL="http://${PRIVATE_IP}:8080"

# Public IP (EC2 metadata if available)
if curl --connect-timeout 2 -s http://169.254.169.254/latest/meta-data/public-ipv4 >/dev/null 2>&1; then
    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
        -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
        http://169.254.169.254/latest/meta-data/public-ipv4)
    PUBLIC_URL="http://${PUBLIC_IP}:8080"
else
    PUBLIC_URL="Not available"
fi

# ---------------- Wait until Gerrit is ready ----------------
echo "Waiting for Gerrit to start on port 8080..."
until curl -s -o /dev/null http://localhost:8080; do
    printf "."
    sleep 5
done
echo ""
echo "Gerrit is up and running!"

# ---------------- Print URLs ----------------
echo ""
echo "============================================"
echo "✅ Gerrit is ready!"
echo ""
echo "Access Gerrit at the following URLs:"
echo ""
echo "• Localhost:    ${LOCALHOST_URL}"
echo "• Private IP:   ${PRIVATE_URL}"
echo "• Public IP:    ${PUBLIC_URL}"
echo ""
echo "============================================"
echo "⚠️ IMPORTANT:"
echo "• Ensure firewall / security group allows TCP 8080"
echo "• Log out and log back in to use Docker without sudo"

```
