# AGENTS.md — Configuration de l'agent Pi

Ce dossier contient la **configuration personnelle de l'agent Pi**. Ce fichier
s'adresse aux agents qui travaillent ici, c'est-à-dire qui modifient la
configuration de Pi.

## Contexte

- `~/.pi` est un **lien symbolique** vers `~/dotfiles/dotfiles/pi/.pi`, dans un
  dépôt git de dotfiles (géré façon GNU Stow). Les deux chemins désignent les
  mêmes fichiers. Tout changement ici finit dans ce dépôt.
- Le projet sert aussi de **support d'apprentissage** : le code doit rester
  simple, commenté (en français) et lisible par un débutant.
- Documentation officielle de Pi : dossier `docs/` du paquet `pi-coding-agent`
  (installé via Nix, dans `/nix/store`). `extensions.md` est la référence
  pour l'API. Les variables `PI_*` donnent le modèle et la session en cours.

## Objectifs de la configuration

1. **Contrôle des actions** : demander l'autorisation à l'utilisateur avant
   toute action sensible (outils MCP, écriture de fichiers, lecture de fichiers
   sensibles ou hors du dossier de la session, commandes bash à risque).
2. **Informations à jour** : l'agent doit pouvoir chercher et lire sur le Web,
   et privilégier ces sources quand une information a pu changer.
3. **Aperçu des modifications** de fichiers au format `diff` avant validation.
4. **Clarté pour tous les modèles** : outils, skills et extensions doivent être
   faciles à repérer et à utiliser, même pour de petits modèles open-source
   (< 12B). On préfère un outil dédié (ex. `web_search`) à une commande bash
   fabriquée par le modèle (ex. `curl`).
5. **Simplicité** : peu de code, zéro dépendance npm si possible. On peut
   s'appuyer sur des commandes Unix courantes (`diff`, …).

## Structure

```
~/.pi/
├── AGENTS.md                  # Ce fichier (contexte pour les agents)
├── .gitignore
└── agent/                     # Répertoire de l'agent Pi (agent-dir)
    ├── settings.json          # Réglages (NON versionné)
    ├── auth.json              # Identifiants (NON versionné, SECRET)
    ├── sessions/              # Historique des sessions (NON versionné)
    └── extensions/            # Extensions chargées automatiquement
        ├── README.md          # Doc pour l'humain (ignorée par Pi)
        ├── confirm-actions.ts # Demandes de confirmation (permission gate)
        └── web-search.ts      # Outils web_search et web_fetch
```

Pi charge automatiquement tout `agent/extensions/*.ts`. Après une modification,
lancer `/reload` dans une session ou redémarrer Pi.

## Précautions à suivre

### Sécurité (priorité absolue)

- **Ne jamais affaiblir `confirm-actions.ts` sans le demander explicitement à
  l'utilisateur.** Ce fichier est la barrière de sécurité de l'agent. Un
  changement qui laisse passer une action sensible est une régression grave.
- **Fail closed** : en cas de doute, ou sans interface (`!ctx.hasUI`), on
  **bloque** ou on **demande**. On ne laisse jamais passer par défaut.
- **Penser aux contournements** : toute nouvelle règle sur les fichiers doit
  aussi couvrir l'outil `bash` (ex. `cat`, `grep`, `cp`, `>` …). Une faille de
  ce type a déjà été corrigée : la protection de `read`/`write` était contournée
  par `bash`.
- Tout nouvel outil qui touche au disque, au réseau avec effets de bord, ou à
  des secrets doit passer par le gate de `confirm-actions.ts`.
- **Ne jamais lire, afficher ni versionner** `agent/auth.json`, des fichiers
  `.env`, des clés ou des jetons. Vérifier `git status` avant de proposer un
  commit.

### Périmètre des modifications

- Ne modifier que `~/.pi` (et donc `~/dotfiles/dotfiles/pi/.pi`). Le dépôt
  dotfiles contient d'autres configurations (nvim, hypr, bash, …) : **ne pas y
  toucher** et ne pas inclure leurs changements dans un commit.
- Ne pas modifier `agent/settings.json` ni `agent/auth.json` sans accord
  explicite de l'utilisateur.

### Style de code

- TypeScript simple, un fichier par extension, avec un en-tête qui explique
  son rôle. Commentaires en français.
- Pas de dépendance npm sauf nécessité. Utiliser `fetch`, `node:*`, l'API Pi
  (`@earendil-works/pi-coding-agent`) et `typebox` pour les schémas.
- **Descriptions d'outils** : courtes, explicites, à l'impératif, en disant
  *quand* utiliser l'outil. C'est ce que le modèle lit vraiment ; le README
  n'est pas chargé dans le contexte.

### Vérifier avant de terminer

1. Charger Pi sans erreur : `pi -p "Réponds juste: OK"`.
2. Tester la logique modifiée, par exemple un petit script Node qui couvre
   les cas attendus **et** les faux positifs (pour `confirm-actions.ts` :
   `rm`, `cat /etc/passwd`, `cat .env`, mais aussi `echo hi 2>&1`, `git status`).
   Supprimer les fichiers temporaires ensuite.
3. Mettre à jour `agent/extensions/README.md` (pour l'humain) et ce fichier
   (pour les agents) si le comportement change.

## Pistes ouvertes

Voir `feedbacks.md` pour les retours de l'utilisateur. À ce jour :

- Fait : les lectures dans `/tmp`, le dossier courant ou la doc de Pi
  (`getDocsPath()`, `getExamplesPath()`, `getReadmePath()`) ne demandent plus
  de confirmation (hors fichiers secrets ; les écritures demandent toujours).
- Fait : choix « Accepter tout » dans la boîte de dialogue, valable jusqu'à la
  fin de la réponse en cours (remis à zéro sur l'événement `agent_settled`).
- Aperçu `diff` plus riche pour l'outil `edit`.
- Un skill expliquant quand utiliser `web_search` / `web_fetch`.
- Éventuellement des sous-agents pour les tâches de recherche.
