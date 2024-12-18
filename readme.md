> Ydays
> Projet dans le cadre d'Ynov de développement d'application.

# Description

Le but de cette application est d'organiser des voyages de A à Z, notament avec de l'IA.

# Installation

Aller dans le dossier `symfony/`.
Creer un fichier `.env.local` avec APP_SECRET.
Dans le fichier `.env` inscrire dans `APP_ENV` l'environnement souhaité (dev / prod).

## En production

Tout le projet est inclus dans le container docker mais les fichiers ne sont pas mis à jour. Un build est obligatoire pour les remettre à jour.

Créer les containers (--build pour recopier les nouveaux fichiers) : `docker-compose -f compose.yaml -f compose.prod.yaml up -d --build`

## En developpement

`docker-compose up -d --build` : créé les containers (utilise compose et compose.override)

### Latence liée à la synchronisation

> Seulement pour WSL (sur windows)  
> Le mapping des dossier /var et /vendor font énormement ramer car à chaque modification, docker tente de synchroniser les fichiers avec l'hôte.

=> Les calls passes de 60ms à 1500ms

Malgré une tentative avec "read only" (ro) et "delegated" sur les volumes, les performances ne changent pas.

Pour permettre de meilleures performances, le mapping de `/var` a été retiré. Se faisant, il n'est plus synchronisé. `/vendor` ne peut pas subir la même solution sinon les librairies ne seraient plus synchronisés entre l'hôte et le container.

**Solutions :**

- Mapping de `/vendor` (latence élevée)
- Isolation de `/vendor` (synchronisation absente)

  - Chaque installation faite en local doit être suivie d'un `composer install` dans le container (pour synchroniser docker).
  - Extension d'IDE pour modifier le code directement dans le container (`/vendor` seulement sur docker).

# Base de données

## Sans migration

En production on privilégie les migrations. Pour une simple synchronisation de la structure de la BDD avec les modèles, il suffit d'executer `php bin/console doctrine:schema:update`.

## Avec migration

Une migration doit être créée à chaque nouveau push sur main lorsque les entités ont été modifiées. Cela permet au serveur de ré adapter sa structure de données sans perte.

Appliquer les migrations avec `php bin/console doctrine:migrations:migrate`.  
Vérifier que la BDD est bien à jour grace aux migrations avec `php bin/console doctrine:schema:validate`.
