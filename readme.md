# Ydays

> Projet dans le cadre d'Ynov de développement d'application.

## Description

Le but de cette application est d'organiser des voyages de A à Z, notament avec de l'IA.

## Utilisation

Aller dans le dossier `symfony/`.
Creer un fichier `.env.local` avec APP_SECRET.

### Production

Tout le projet est inclus dans le container docker mais les fichiers ne sont pas mis à jour. Un build est obligatoire pour les remettre à jour.

-   Dans le fichier `.env` mettre APP_ENV=prod
-   `docker-compose -f compose.yaml -f compose.prod.yaml up -d --build` : créé les containers (--build pour recopier les nouveaux fichiers)
-   S'assurer que les migrations sont à jour avec les modèles, sinon schema:update :
    -   Migrate
    -   Check migration migrated ALL models with doctrine:migrations:up-to-date
    -   Si non, mettre a jour le code pour convenir ou synchroniser temporairement sans migration via `php bin/console doctrine:schema:update` : créé la structure de la db si besoins

### Developpement

! PHP, Composer et le CLI de Symfony doivent être installés en local.

-   Dans le fichier `.env` mettre APP_ENV=dev
-   `composer install` : télécharge les dépendances
-   `docker-compose up -d` : créé les containers (utilise compose et compose.override)
-   `php bin/console doctrine:schema:update` : créé la structure de la db si besoins
-   `symfony server:start` : démarre le serveur en local
