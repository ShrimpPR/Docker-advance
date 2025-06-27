
# TP 2 Docker avancé

## Part I : Packaging basique

Voila les différents fichiers présents dans mon dossier pour cette étape:

Dockerfile
```docker
FROM node:20

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

ENV LISTEN_IP=0.0.0.0
ENV LISTEN_PORT=3000

EXPOSE 3000

CMD ["npm", "run", "dev"]

```

docker-compose.yml
```
services:
  app:
    build:
      context: .
    ports:
      - "3000:3000"
    environment:
      - LISTEN_IP=0.0.0.0
      - LISTEN_PORT=3000

```

.env.sample
```
LISTEN_IP=0.0.0.0
LISTEN_PORT=3000
```

Voici la structure de mon repo

```
➜  Portfolio git:(main) tree -a -L1
.
├── .env.sample
├── .git
├── .gitignore
├── .next
├── .nvmrc
├── components
├── config.json
├── docker-compose-dev.yml
├── docker-compose-prod.yml
├── docker-compose.yml
├── Dockerfile
├── next-env.d.ts
├── next.config.js
├── node_modules
├── package-lock.json
├── package.json
├── public
├── README.md
├── src
└── tsconfig.json
```

Et le ```curl http://localhost:3000``` quand l'image est lancée
```
<!DOCTYPE html><html><head><style data-next-hide-fouc="true">body{display:none}</style><noscript data-next-hide-fouc="true"><style>body{display:block}</style></noscript><meta charSet="utf-8"/><title>Your Portfolio</title><meta name="description" content="Your Portfolio Description"/><meta name="viewport" content="width=device-width, initial-scale=1"/><link rel="icon" href="/favicon.ico"/>{...}
```

## Part II : Des environnements différents

### Partie Prod:
docker-compose-prod.yml:
```services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: prod
    ports:
      - "3000:3000"
    environment:
      - LISTEN_IP=0.0.0.0
      - LISTEN_PORT=3000
```

Dockerfile-prod:
```
FROM node:20

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

ENV LISTEN_IP=0.0.0.0
ENV LISTEN_PORT=3000
ENV ENVIRONMENT=prod

EXPOSE 3000

ENTRYPOINT ["npm", "run", "start"]
```

```
-> docker compose -f docker-compose-prod.yml up
[+] Running 1/1
 ✔ Container portfolio-app-1  Created                                                                                                                                                                             0.0s 
Attaching to app-1
app-1  | 
app-1  | > start
app-1  | > next start -H ${LISTEN_IP} -p ${LISTEN_PORT}
app-1  | 
app-1  |   ▲ Next.js 14.2.13
app-1  |   - Local:        http://localhost:3000
app-1  |   - Network:      http://0.0.0.0:3000
app-1  | 
app-1  |  ✓ Starting...
app-1  |  ✓ Ready in 106ms
```

Et le ```curl http://localhost:3000``` de la partie prod
```
<!DOCTYPE html><html><head><style data-next-hide-fouc="true">body{display:none}</style><noscript data-next-hide-fouc="true"><style>body{display:block}</style></noscript><meta charSet="utf-8"/><title>Your Portfolio</title><meta name="description" content="Your Portfolio Description"/><meta name="viewport" content="width=device-width, initial-scale=1"/><link rel="icon" href="/favicon.ico"/>{...}
```

### Partie dev:

docker-compose-dev.yml:
```services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: dev
    ports:
      - "3000:3000"
    volumes:
      - .:/app
    environment:
      - LISTEN_IP=0.0.0.0
      - LISTEN_PORT=3000
```

Dockerfile-dev:
```
FROM node:20

WORKDIR /app

COPY package*.json ./
RUN npm install

ENV LISTEN_IP=0.0.0.0
ENV LISTEN_PORT=3000
ENV ENVIRONMENT=dev

EXPOSE 3000

CMD ["npm", "run", "dev"]
```

```
-> docker compose -f docker-compose-dev.yml up        
[+] Running 1/1
 ✔ Container portfolio-app-1  Created                                                                                                                                                                             0.0s 
Attaching to app-1
app-1  | 
app-1  | > dev
app-1  | > next dev -H ${LISTEN_IP} -p ${LISTEN_PORT}
app-1  | 
app-1  |   ▲ Next.js 14.2.13
app-1  |   - Local:        http://localhost:3000
app-1  |   - Network:      http://0.0.0.0:3000
app-1  | 
app-1  |  ✓ Starting...
app-1  |  ✓ Ready in 1152ms
```

Et le ```curl http://localhost:3000``` de la partie dev
```
<!DOCTYPE html><html><head><style data-next-hide-fouc="true">body{display:none}</style><noscript data-next-hide-fouc="true"><style>body{display:block}</style></noscript><meta charSet="utf-8"/><title>Your Portfolio</title><meta name="description" content="Your Portfolio Description"/><meta name="viewport" content="width=device-width, initial-scale=1"/><link rel="icon" href="/favicon.ico"/>{...}
```

### Multi-stage build

Voici le Dockerfile global qui utilise le multi-stage build
```
FROM node:20 AS base
WORKDIR /app
COPY package*.json ./
RUN npm install

FROM base AS dev
ENV ENVIRONMENT=dev
CMD ["npm", "run", "dev"]

FROM base AS prod
ENV ENVIRONMENT=prod
COPY . .
RUN npm run build
ENTRYPOINT ["npm", "run", "start"]
```

Les deux commandes de build
```
docker build --target dev -t portfolio-dev .
docker build --target prod -t portfolio-prod .
```

## Part III : Base image

### 1.Provenance

Lien vers image debian open source
```https://github.com/debuerreotype/docker-debian-artifacts```
(Géré par des devs Debian, officiel)

Lien vers image alpine open source
```https://github.com/alpinelinux/docker-alpine```
(Géré par la commu Alpine Linux, officiel)

Lien vers image node open source
```https://github.com/nodejs/docker-node```
(Image officielle)


### 2.Vulnérabilités connues

Rapport nombre vulnérabilités de Debian

```Total: 78 (UNKNOWN: 0, LOW: 58, MEDIUM: 12, HIGH: 7, CRITICAL: 1)```

Rapport nombre vulnérabilités d'Alpine

``` alpine:latest (alpine 3.22.0)  alpine         0            -    ```

Rapport nombre vulnérabilité de Node (version 20)

```Total: 1344 (UNKNOWN: 2, LOW: 681, MEDIUM: 487, HIGH: 165, CRITICAL: 9)```

### 3. Dockerfile writing

**Dockerfile-alpine**
- Image de base : `alpine:3.20`
- Installation de Node.js et npm via `apk`

**Dockerfile-debian**
- Image de base : `debian:12.5-slim`
- Installation de Node.js via `nodesource`

### 4. Measure!

- alpine - 37.9s de build time
- debian - 46.9s de build time

En faisant un ```docker images```, on peut vérifier la taille des deux image précédemment buildées

```
portfolio-debian                                latest           238bfaca8c1c   59 seconds ago   2.18GB
portfolio-alpine                                latest           e006b738df33   2 minutes ago    1.84GB
```

Benchmark alpine vs debian

Script qui fait 40 000 requêtes a mon API
```
#!/bin/bash

echo "Cible : http://localhost:3001"

START=$(date +%s.%N)

for i in {1..40000}
do
  curl -s -o /dev/null http://localhost:3001
done

END=$(date +%s.%N)

DURATION=$(echo "$END - $START" | bc)

echo "Temps total : $DURATION secondes"
```

Alpine
Temps total : 273.950762000 secondes

Debian
Temps total : 274.502705000 secondes


Avec du MultiThreading:

Alpine
Temps total : 59.072904000 secondes

Debian
Temps total : 61.902303000 secondes

Donc pas de différences réelles pour mon application

```
#!/bin/bash

URL="http://localhost:3002"
CONCURRENCY=500
TOTAL_REQUESTS=40000

echo "Cible : $URL"
echo "Requêtes en parallèle : $CONCURRENCY"
echo "Nombre total de requêtes : $TOTAL_REQUESTS"


START=$(date +%s.%N)

seq 1 $TOTAL_REQUESTS | xargs -P $CONCURRENCY -n 1 curl -s -o /dev/null $URL

END=$(date +%s.%N)

DURATION=$(echo "$END - $START" | bc)

echo "Temps total : $DURATION secondes"
```

J'utiliserai Debian pour la suite

## Part IV : En vrac

### I. Clean caches

```
FROM debian:12.5-slim AS base

ENV ENVIRONMENT=prod
WORKDIR /app

RUN apt-get update && \
    apt-get install -y curl gnupg ca-certificates && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY package*.json ./
RUN npm install

FROM base AS prod
COPY . .
RUN npm run build

ENTRYPOINT ["npm", "run", "start"]
```

```apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*```

```apt-get clean``` me permet de clean le cache local

```rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*``` me permet de supprimer les fichiers temporaires à différents endroits et la liste de package de l'update


### II. Labels
On peut ajouter ces Labels dans le stage prod:
```
LABEL authors="Tristan Le Du <tristan.le-du@efrei.net>" \
      url="https://github.com/ShrimpPR/portfolio" \
      source="https://github.com/ShrimpPR/portfolio" \
      vendor="EFREI Bordeaux"
```

On obtient donc cet output en faisant docker image inspect portfolio-app:
```
"Labels": {
  "authors": "Tristan Le Du <tristan.le-du@efrei.net>",
  "source": "https://github.com/ShrimpPR/portfolio",
  "url": "https://github.com/ShrimpPR/portfolio",
  "vendor": "EFREI Bordeaux"
  }
```

### Utilisateur Applicatif


Lien vers mon projet
```https://github.com/ShrimpPR/Portfolio```