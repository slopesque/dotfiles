// Based-on: ✨ vibe coding ✨

/**
 * Confirm Actions Extension
 * =========================
 *
 * Demande une autorisation à l'utilisateur AVANT chaque action sensible.
 * C'est une « barrière de permission » (permission gate).
 *
 * Actions considérées comme sensibles :
 *   1. Appel d'un outil fourni par un serveur MCP (nom en `mcp__…`).
 *   2. Écriture / modification de fichier (outils `write` et `edit`).
 *      -> Un aperçu style `diff` est affiché avant la demande.
 *   3. Lecture d'un fichier sensible :
 *        - en dehors du dossier de la session (cwd), de /tmp et de la
 *          documentation de Pi (docs/, examples/, README.md), OU
 *        - fichier de type secret (.env, clés, identifiants…).
 *   4. Commandes `bash` qui contournent les outils de fichiers :
 *        - commandes qui créent/modifient/suppriment des fichiers
 *          (rm, mv, cp, touch, dd, tee, chmod, redirections `>`…),
 *        - commandes de lecture (cat, grep, sed, find…) qui visent un
 *          fichier sensible ou un chemin hors du dossier de la session
 *          (les chemins dans /tmp et la doc de Pi sont tolérés),
 *        - élévation de privilèges (sudo).
 *
 * La boîte de dialogue propose aussi « Accepter tout » : toutes les actions
 * suivantes sont alors autorisées, mais SEULEMENT jusqu'à la fin de la
 * réponse en cours de l'agent (événement `agent_settled`). Au message suivant
 * de l'utilisateur, les demandes de confirmation reprennent.
 *
 * En l'absence d'interface (mode non interactif), l'action est BLOQUÉE par
 * défaut : on « échoue fermé » pour rester sûr.
 *
 * Installation : auto-découvert depuis
 *   ~/.pi/agent/extensions/confirm-actions/index.ts
 *
 * Organisation :
 *   - index.ts         : branchement sur les événements de Pi (ce fichier)
 *   - checks/bash.ts   : analyse des commandes bash
 *   - checks/files.ts  : détection des fichiers secrets
 *   - checks/paths.ts  : détection des chemins hors des dossiers autorisés
 */

import {
	type AgentSettledEvent,
	type ExtensionAPI,
	type ExtensionContext,
	isToolCallEventType,
	type ToolCallEvent,
	type ToolCallEventResult,
} from "@earendil-works/pi-coding-agent";

import { analyzeBashCommand } from "./checks/bash.ts";
import { isSensitiveFile } from "./checks/files.ts";
import { callsSuspiciousPath } from "./checks/paths.ts";


interface DenyReason {
    title: string;
    detai: string;
}

const ALLOW = "Autoriser";
const ALLOW_ALL = "Accepter tout (jusqu'à la fin de cette réponse)";
const DENY = "Refuser";

let allowAllState = false;

function scanAction(
    event: ToolCallEvent,
    ctx: ExtensionContext,
): DenyReason | undefined {
	if (isToolCallEventType("write", event) || isToolCallEventType("edit", event)) {
		const path = event.input.path ?? "(inconnu)";
        return {
		    title: `Autoriser la modification de ${path} ?`,
		    detail: `Fichier: ${path}`,
        };
	}

    if (isToolCallEventType("read", event)) {
		const path = event.input.path ?? "";
		if (isSensitiveFile(path) || callsSuspiciousPath(path)) {
			const reason = isSensitiveFile(path)
				? "fichier potentiellement secret"
				: "fichier hors du dossier de la session";
            return {
                title: "Autoriser la lecture d'un fichier sensible ?",
                detail: `Fichier: ${path}\nRaison: ${reason}`,
            }
		}
	}

    if (isToolCallEventType("bash", event)) {
		const command = event.input.command ?? "";
		const reason = analyzeBashCommand(command);
		if (reason)
            return {
                title: "Autoriser l'exécution de cette commande ?",
                detail: `Commande: ${command}\nRaison: ${reason}`,
            };
	}

	const tool = event.toolName;

    if (tool.startsWith("mcp__"))
        return {
            title: "Autoriser l'appel d'un outil MCP ?",
            detail: `Outil: ${tool}\nArguments: ${JSON.stringify(event.input)}`,
        }

    return undefined;
}

async function resetAllowAll(_event: AgentSettledEvent, _ctx: ExtensionContext): Promise<void> {
	allowAllState = false;
}

async function handleToolCall(
	event: ToolCallEvent,
	ctx: ExtensionContext,
): Promise<ToolCallEventResult | undefined> {
    const deny = scanAction(event, ctx);

	if (!deny) return undefined;

	if (allowAllState) return undefined;

	if (!ctx.hasUI) {
		return {
            block: true,
            reason: "Action sensible bloquée (aucune interface pour confirmer)",
        };
	}

	const choice = await ctx.ui.select(
        `⚠️ ${deny.title}\n\n${deny.detail}`,
        [ALLOW, ALLOW_ALL, DENY]
    );

	if (choice === ALLOW_ALL) {
		allowAllState = true;
		ctx.ui.notify(
            "Toutes les actions sont autorisées jusqu'à la fin de cette réponse.",
            "warning"
        );
		return undefined;
	}

	if (choice === ALLOW) return undefined;

	return { block: true, reason: "Action refusée par l'utilisateur" };
}

export default function confirmActionsExtension(pi: ExtensionAPI) {
	pi.on("tool_call", handleToolCall);
	pi.on("agent_settled", resetAllowAll);
}
