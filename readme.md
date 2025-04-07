# Next Step

## Description

> Ydays
> Projet dans le cadre de Ynov de développement d'application.

Le but de cette application est d'organiser des voyages de A à Z, notamment avec de l'IA.

## Installation

Dans le fichier `.env` inscrire dans `APP_ENV` l'environnement souhaité (dev / prod).

### En production

L'application nécessite un APP_SECRET unique et qui ne change pas entre les builds (notamment pour les tokens). En production, il faut le générer à la main grâce à la commande `prepare-app-secret.sh generate` avant de lancer les services (nécessite PHP en local)

Tout le projet est inclus dans des containers Docker donc les fichiers ne sont pas mis à jour. Un build est obligatoire pour les remettre à jour.

Créer les containers (--build obligatoire pour reconstruire l'image avec les nouveaux fichiers) :

```bash
docker compose \
-f compose.yaml \
-f compose.prod.yaml
up \
-d \
--build
```

### En développement

Pour développer sur symfony, 2 possibilités :

- Développer en local : l'installation en local de PHP et composer sont nécessaires. Fortement déconseillé sur Windows (lire le paragraphe suivant pour comprendre)
- Container de développement sur VSCode via l'extension "Remote Development" :
  - "Open folder in container" : mise en place complète et automatique de l'environnement de développement (extensions, paramètres...) grâce au fichier `devcontainer.json`
  - "Attach to running container" : le développement se fait dans le container sélectionné, mais aucune configuration VSCode n'est prise en compte.

Créer les containers (utilise compose et compose.override) :

```bash
docker compose \
up \
-d \
--build
```

#### Latence liée à la synchronisation (sur Windows)

> Seulement pour WSL (sur Windows)  
> La synchronisation des dossiers /var et /vendor font énormement ramer, car à chaque modification, docker tente de synchroniser les fichiers avec l'hôte.

Malgré divers tentatives avec "read only" et "delegated", les performances des volumes ne changent pas.

Pour éviter cette forte latence (60ms passent à 1500ms), `var/` et `/vendor` ne sont plus synchronisés entre l'hôte et le container.

Cependant, `/vendor` est necessaire pour utiliser les librairies lors du développement. Il doit être présent dans l'environnement de dev. Pour ce faire, 2 solutions :

- **Dans le devcontainer** : le dossier `/var` et `/vendor` du container sont accessibles dans le devcontainer mais pas par l'hôte.
- **En local** : le dossier `/vendor` est en doublon dans l'hôte et le container, obligeant à le synchroniser manuellement à chaque installation ou mise à jour de dépendances en local, via `composer install` dans le container.

#### Formatage

La librairie php-cs-formatter permet de formater les fichiers PHP, afin d'avoir une nomenclature uniforme sur le dépôt.

L'extension VSCode "junstyle.php-cs-fixer" est paramétrée dans le devcontainer. Elle formate les fichiers dès qu'on sauvegarde, en utilisant la configuration dans le fichier `.php-cs-fixer.dist.php`.

Sinon, on peut formater les fichiers manuellement grâce à `composer format`. Si l'extension n'est pas installée, il est préférable de l'exécuter avant chaque commit, ou à minima avant un merge.

Pour les fichiers autres que PHP, on peut utiliser le formateur "prettier", sois via l'extension VSCode installée dans le conteneur de dev, sois via la commande `npx prettier --write .`.

#### Linter

PHPStan est un outil d’analyse statique pour le code PHP. Il aide à détecter des bugs ou des incohérences dans le code avant même de l’exécuter.

Les paramètres pour le lint sont définies dans le fichier `phpstan.dist.neon`.

L’extension VSCode “PHPStan” est configurée dans le devcontainer pour analyser le code à la volée. En son absence, on peut aussi exécuter l'analyse manuellement grâce à la commande `composer lint`.

#### Débogage

Pour développer, XDebug est installé dans le container PHP. L'extension "PHP Debug" est nécessaire pour déboguer via VSCode (inclue dans le devcontainer).

Pour l'utiliser, il faut il suffit de mettre son IDE en écoute sur le port 9003 ("Start Debugging"), et de donner l'ordre à symfony de se mettre en mode débogage. Pour ce faire, inclure le paramètre suivant dans l'URL ou dans le header :

- Temporaire : (pour chaque requête) `XDEBUG_SESSION=VSCODE`.
- Permanente (pour que le mode débogage persiste sur plusieurs requêtes) :
  - Activation : `?XDEBUG_SESSION_START=1`
  - Désactivation : `XDEBUG_SESSION_STOP=1`

## Base de données

### Sans migration

En production on doit utiliser les migrations. Pour une simple synchronisation de la structure de la BDD avec les modèles, il suffit d'exécuter `php bin/console doctrine:schema:update --force` dans le container symfony.

### Avec migration

Une migration doit être créée à chaque fois que les entités sont modifiées. Cela permet au serveur de réadapter sa structure de données et ses données existantes sans perte.

Vérifier que la BDD est bien à jour grâce aux migrations : `php bin/console doctrine:schema:validate`.

Appliquer les migrations : `php bin/console doctrine:migrations:migrate`.
