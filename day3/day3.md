# TP 3 Docker avancé

## Part 1 : Première pipeline


Output du job:
```
Processing triggers for libc-bin (2.36-9+deb12u10) ...
$ /usr/games/cowsay "Meooooooooooow"
 ________________
< Meooooooooooow >
 ----------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
Cleaning up project directory and file based variables
00:00
Job succeeded
```

### 1. Linting

***Lint me baby***

Installation d'ESLint

Premier output:
```
npm run lint

> lint
> eslint . --ext .js,.jsx,.ts,.tsx
```

Nouveau Job
```
image: node:20

stages:
  - meow
  - lint

lint-job:
  stage: lint
  before_script:
    - npm ci
  script:
    - npm run lint

  allow_failure: false
```

### Formatter

J'utilise Prettier pour formatter mon code


### Secret Scanning

Utilisation de Gitleaks

```
gitleaks-job:
  stage: secrets
  before_script:
    - apt-get update && apt-get install -y wget
    - wget -O gitleaks.tar.gz https://github.com/gitleaks/gitleaks/releases/download/v8.27.2/gitleaks_8.27.2_linux_x64.tar.gz
    - tar xvzf gitleaks.tar.gz
    - rm README.md
    - mv gitleaks /usr/local/bin/gitleaks
  script:
    - gitleaks detect --source=. --no-git --verbose --redact
  allow_failure: false
```

Build et Publish jobs

```
build-job:
  stage: build
  script:
    - docker build -t $IMAGE_NAME:$CI_COMMIT_SHORT_SHA .
    - docker save $IMAGE_NAME:$CI_COMMIT_SHORT_SHA -o craftshare.tar
  artifacts:
    paths:
      - craftshare.tar
    expire_in: 1 hour

publish-job:
  stage: publish
  script:
    - docker load -i craftshare.tar

    - echo "$CI_JOB_TOKEN" | docker login -u "$CI_REGISTRY_USER" --password-stdin "$CI_REGISTRY"

    - docker tag $IMAGE_NAME:$CI_COMMIT_SHORT_SHA $IMAGE_NAME:latest

    - docker push $IMAGE_NAME:$CI_COMMIT_SHORT_SHA
    - docker push $IMAGE_NAME:latest
  dependencies:
    - build-job
```


### Prepare Azure VM
```
ssh shrimp@52.232.36.157 -i ~/.ssh/id_ed25519_azure
Welcome to Ubuntu 24.04.2 LTS (GNU/Linux 6.11.0-1015-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Fri Jun 27 18:13:55 UTC 2025

  System load:  0.0                Processes:             139
  Usage of /:   15.1% of 28.02GB   Users logged in:       0
  Memory usage: 35%                IPv4 address for eth0: 10.0.0.5
  Swap usage:   0%

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

42 updates can be applied immediately.
40 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status
```

```
sudo -l
Matching Defaults entries for shrimp on shrimp:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin, use_pty

User shrimp may run the following commands on shrimp:
    (ALL : ALL) ALL
    (ALL) NOPASSWD: ALL
```

```
groups shrimp
shrimp : shrimp adm cdrom sudo dip lxd docker
```


```
ssh -i .ssh/id_ed25519_azure shrimp@52.232.36.157 sudo docker run registry.gitlab.com/shrimppr/craftshare

> craftshare@0.1.0 start
> next start

   ▲ Next.js 15.3.2
   - Local:        http://localhost:3000
   - Network:      http://172.17.0.2:3000

 ✓ Starting...
 ✓ Ready in 670ms
```