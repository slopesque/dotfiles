# Configuration de l'agent Pi — Extensions

Ce dossier contient des **extensions** auto-découvertes par Pi (tout fichier
`~/.pi/agent/extensions/*.ts` est chargé au démarrage). Chaque extension est un
module TypeScript simple, pensé pour servir d'exemple d'apprentissage.

## Extensions fournies

### 1. `web-search.ts` — Accès à Internet

Ajoute deux outils que l'agent peut appeler :

| Outil        | Rôle                                                         |
|--------------|--------------------------------------------------------------|
| `web_search` | Recherche des informations **à jour** (via DuckDuckGo).      |
| `web_fetch`  | Récupère le contenu texte d'une page Web à partir d'une URL. |

Objectif : permettre à l'agent de **chercher et privilégier des informations
actualisées** depuis le Web. Les descriptions des outils sont volontairement
explicites pour qu'un **petit modèle (< 12B)** les détecte et les préfère à la
fabrication manuelle de commandes `curl`.

Aucune clé d'API n'est nécessaire.

### 2. `confirm-actions.ts` — Contrôle des actions

Demande une **confirmation utilisateur avant chaque action sensible** :

1. Appel d'un outil d'un **serveur MCP** (`mcp__…`).
2. **Écriture / modification de fichier** (`write`, `edit`), avec un **aperçu
   des changements au format `diff`** (généré via la commande Bash `diff -u`).
3. **Lecture d'un fichier sensible** : hors du dossier de la session (et hors de
   `/tmp` et de la documentation de Pi, qui sont tolérés), ou de type secret (`.env`, clés SSH, identifiants…).
4. **Commandes `bash` à risque** : commandes qui créent/modifient/suppriment des
   fichiers (`rm`, `mv`, `cp`, `touch`, `dd`, `tee`, `chmod`, redirection `>`…),
   commandes de lecture (`cat`, `grep`, `sed`, `find`…) visant un fichier
   sensible ou un chemin hors du dossier de la session, de `/tmp` et de la doc de Pi
   (`docs/`, `examples/`, `README.md`, trouvés via `getDocsPath()`…), ou `sudo`. Cela évite
   que l'outil `bash` ne serve de contournement aux règles sur les fichiers.

Les fichiers secrets restent protégés même dans `/tmp` ou le dossier courant,
et les écritures (`write`, `edit`, `rm`, `>`…) demandent toujours confirmation.

La boîte de dialogue propose trois choix : **Autoriser**, **Accepter tout**
(autorise toutes les actions suivantes **jusqu'à la fin de la réponse en
cours** de l'agent, puis les demandes reprennent) et **Refuser**.

En mode non interactif (pas d'interface), l'action est **bloquée par défaut**
(« fail closed ») pour rester sûr.

## Comment ça marche (pour apprendre)

Une extension exporte une fonction `default` recevant l'API `pi` :

- `pi.registerTool({ name, description, parameters, execute })`
  enregistre un outil appelable par le modèle (voir `web-search.ts`).
- `pi.on("tool_call", handler)` intercepte un appel d'outil **avant** son
  exécution et peut le **bloquer** en renvoyant `{ block: true, reason }`
  (voir `confirm-actions.ts`).
- `ctx.ui.select(...)` / `ctx.ui.confirm(...)` posent une question à
  l'utilisateur ; `ctx.hasUI` indique si une interface est disponible.

## Recharger après modification

Dans une session Pi, utilisez `/reload` pour recharger les extensions après
avoir édité ces fichiers.
