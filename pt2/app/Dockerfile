# Utilisation de l'image Python officielle comme base
FROM python:3.11

# Définition du répertoire de travail dans le conteneur
WORKDIR /app

# Copie des fichiers requirements avant le reste du code
# Cela permet de mettre en cache les dépendances
COPY requirements.txt .

# Installation des dépendances
RUN pip install -r requirements.txt

# Copie du code de l'application
COPY app.py .

# Commande à exécuter au démarrage du conteneur
CMD ["python", "app.py"] 