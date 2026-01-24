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
ssh-keygen -t ed25519 -C "gerrit"
```

```
cat ~/.ssh/id_ed25519.pub
```

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
