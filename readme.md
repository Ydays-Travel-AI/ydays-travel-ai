> Ydays
> Projet dans le cadre d'Ynov de développement d'application.

# Description

Le but de cette application est d'organiser des voyages de A à Z, notament avec de l'IA.

# Installation

Aller dans le dossier `symfony/`.
Creer un fichier `.env.local` avec APP_SECRET.

## En production

Tout le projet est inclus dans le container docker mais les fichiers ne sont pas mis à jour. Un build est obligatoire pour les remettre à jour.

- Dans le fichier `.env` mettre APP_ENV=prod
- `docker-compose -f compose.yaml -f compose.prod.yaml up -d --build` : créé les containers (--build pour recopier les nouveaux fichiers)

## En developpement

! PHP, Composer et le CLI de Symfony doivent être installés en local.

- Dans le fichier `.env` mettre APP_ENV=dev
- `composer install` : télécharge les dépendances
- `docker-compose up -d` : créé les containers (utilise compose et compose.override)
- `symfony server:start` : démarre le serveur en local

# Base de données

## Sans migration

En production on privilégie les migrations. Pour une simple synchronisation de la structure de la BDD avec les modèles, il suffit d'executer `php bin/console doctrine:schema:update`.

## Avec migration

Une migration doit être créée à chaque nouveau push sur main lorsque les entités ont été modifiées. Cela permet au serveur de ré adapter sa structure de données sans perte.

Appliquer les migrations avec `php bin/console doctrine:migrations:migrate`.  
Vérifier que la BDD est bien à jour grace aux migrations avec `php bin/console doctrine:schema:validate`.
