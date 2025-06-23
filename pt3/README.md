## Lancer le projet

Dans ce dossier :

```sh
docker compose up --build
```

## Tester l'API

### 1. Récupérer tous les utilisateurs

```sh
curl http://localhost:8000/users
```

### 2. Récupérer l'utilisateur avec l'id 3

```sh
curl http://localhost:8000/user/3
```

---

- Le port de l'API est configurable via le fichier `.env` (variable `LISTEN_PORT`).
- Les données de test sont insérées automatiquement au démarrage via le script `seed.sql`. 