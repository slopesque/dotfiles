import { isSensitiveFile } from "./files.ts";
import { callsSuspiciousPath } from "./paths.ts";

const WRITE_COMMANDS = new Set([
	"rm", "rmdir", "mv", "cp", "touch", "dd", "truncate", "tee", "shred",
	"mkfifo", "ln", "install", "chmod", "chown", "mkdir",
]);

const READ_COMMANDS = new Set([
	"cat", "tac", "grep", "egrep", "fgrep", "rg", "ag", "head", "tail",
	"less", "more", "od", "xxd", "hexdump", "strings", "nl", "awk", "sed",
	"cut", "sort", "uniq", "wc", "find", "diff", "vi", "vim", "nano",
	"emacs", "xdg-open", "open",
]);

const PACKAGE_MANAGERS = new Set([
    "nix", "winget", "apt", "pacman", "yay", "dnf", "portage", "cargo", "uv",
    "pip",
]);

/** Nom de base d'une commande : `/usr/bin/rm` -> `rm`. */
function extractCmdName(token: string): string {
	const noQuotes = token.replace(/^["']|["']$/g, "");
	const parts = noQuotes.split("/");
	return parts[parts.length - 1];
}

/**
 * Rassemble les chemins candidats d'une commande : les jetons bruts et, en
 * plus, toute sous-chaîne ressemblant à un chemin absolu, `../…` ou `~/…`
 * (utile pour des cas comme `--file=/etc/passwd`).
 */
function candidatePaths(command: string, tokens: string[]): string[] {
	const paths = new Set<string>(tokens);
	const re = /(?:\/|\.\.\/|~\/)[A-Za-z0-9._\/~-]+/g;
	let m: RegExpExecArray | null;
	while ((m = re.exec(command)) !== null) paths.add(m[0]);
	return [...paths];
}

function hasSudo(command: string): boolean {
    return /\bsudo\b/.test(command);
}

function hasFileDirection(command: string): boolean {
    return /(?:^|[^0-9&<>])>>?\s*[A-Za-z0-9._\/~"'-]/.test(command);
}

export function analyzeBashCommand(command: string): string | undefined {
	if (hasSudo(command))
        return "élévation de privilèges (sudo)";

	if (hasFileDirection(command))
		return "écriture de fichier par redirection (>)";

	// Jetons « mots » (sans les opérateurs shell), pour repérer les commandes.
	const tokens = command
		.replace(/[|;&()<>]/g, " ")
		.split(/\s+/)
		.filter(Boolean);
	const bases = tokens.map(extractCmdName);

	const writeCmd = bases.find((b) => WRITE_COMMANDS.has(b));
	if (writeCmd)
        return `commande modifiant/supprimant des fichiers (${writeCmd})`;

    const packageManager = tokens.some((token) => PACKAGE_MANAGERS.has(token));
    if (packageManager)
        return `appel d'un package manager (${packageManager})`;

	const paths = candidatePaths(command, tokens);
	if (paths.some(isSensitiveFile)) return "accès à un fichier sensible";

	if (paths.some(callsSuspiciousPath)) {
	    const hasReadCmd = bases.some((b) => READ_COMMANDS.has(b));
		return hasReadCmd
			? "lecture d'un chemin hors du dossier de la session"
			: "accès à un chemin hors du dossier de la session";
	}

	return undefined;
}
