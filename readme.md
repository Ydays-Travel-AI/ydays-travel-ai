> Ydays
> Projet dans le cadre d'Ynov de développement d'application.

# Description

Le but de cette application est d'organiser des voyages de A à Z, notament avec de l'IA.

# Installation

Aller dans le dossier `symfony/`.
Creer un fichier `.env.local` avec APP_SECRET.
Dans le fichier `.env` inscrire dans `APP_ENV` l'environnement souhaité (dev / prod).

Pour developper sur symfony, 2 possibilités:

- Développer en local : l'installation en local de php et composer sont necessaires (pour l'analyse de code).
- Container de développement :
  - Sur VSCode : Extension "Remote Development" :
    - "Open foler in container" (`CTRL+SHIFT+P`). Lecture du fichier devcontainer.json et lancement des container et des extensions automatiquement.
    - "Attach to running container" (`CTRL+SHIFT+P`). Simple entrée dans un container en cours, sans toucher à la configuration du vscode.

## En production

Tout le projet est inclus dans le container docker mais les fichiers ne sont pas mis à jour. Un build est obligatoire pour les remettre à jour.

Créer les containers (--build pour recopier les nouveaux fichiers) : `docker-compose -f compose.yaml -f compose.prod.yaml up -d --build`

## En developpement

`docker-compose up -d --build` : créé les containers (utilise compose et compose.override).

Pour développer, XDebug est installé. Pour l'activer il suffit de mettre son IDE en écoute sur le port 9003 ("Start Debugging"), et de donner l'ordre à symfony de se mettre en mode deboggage. Pour ce faire 2 solutions :

- Temporaire : pour chaque requete, inclure le paramètre `?XDEBUG_SESSION=VSCODE` dans l'url ou dans le header.
- Permanente : Pour que le mode deboggage persiste sur plusieurs requêtes, aller dans la console du navigateur puis :
  - Activation : fabriquer un cookie via `document.cookie = "XDEBUG_SESSION=VSCODE";`.
  - Désactivatioon : supprimer le cookie via `document.cookie = "XDEBUG_SESSION; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/";`.

### Latence liée à la synchronisation (sur Windows)

> Seulement pour WSL (sur windows)  
> Le mapping des dossier /var et /vendor font énormement ramer car à chaque modification, docker tente de synchroniser les fichiers avec l'hôte.

=> Les calls passent de 60ms à 1500ms

Malgré une tentative avec "read only" (ro) et "delegated" sur les volumes, les performances ne changent pas.

Pour permettre de meilleures performances, `var/` n'est plus synchronisé entre l'hôte et le container. On peut faire ceci car il n'est pas très utile pour le développement et peut rester uniquement dans le container. Ce n'est pas aussi simple pour `vendor/` car il est necessaire en local pour développer.

**Solutions :**

- Mapping de `/vendor` (latence élevée sur Windows)
- Isolation de `/vendor` (synchronisation absente)
  - Développement dans un devcontainer : accès direct aux librairies présentes dans le container.
  - Sinon : il faut exécuter un `composer install` dans le conteneur après chaque installation ou mise à jour de dépendances en local, car les bibliothèques (`/vendor`) ne sont pas synchronisées automatiquement.

Puisque nous développons en windows, nous avons décidé d'isoler `/vendor`.

### Formatage

En développement, la librairie "php-cs-formatter" permet de formater les fichiers PHP, afin d'avoir une nomenclature uniforme sur le dépôt.

L'extension VSCode "junstyle.php-cs-fixer" est parametrée dans le devcontainer. Elle formate les fichiers dès qu'on sauvegarde, en utilisant la configuration dans le fichier `.php-cs-fixer.dist.php`.

Sinon, on peut formater les fichiers manuellement grâce à `composer format`. Ce script est par ailleurs exécuté à chaque commit.

# Base de données

## Sans migration

En production on privilégie les migrations. Pour une simple synchronisation de la structure de la BDD avec les modèles, il suffit d'executer `php bin/console doctrine:schema:update`.

## Avec migration

Une migration doit être créée à chaque nouveau push sur main lorsque les entités ont été modifiées. Cela permet au serveur de ré adapter sa structure de données sans perte.

Appliquer les migrations avec `php bin/console doctrine:migrations:migrate`.  
Vérifier que la BDD est bien à jour grace aux migrations avec `php bin/console doctrine:schema:validate`.
