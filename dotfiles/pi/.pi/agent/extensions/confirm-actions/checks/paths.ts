import { homedir, tmpdir } from "node:os";
import { isAbsolute, relative, resolve } from "node:path";
import { getDocsPath, getExamplesPath, getReadmePath } from "@earendil-works/pi-coding-agent";

/** Vrai si `path` est `dir` lui-même ou se trouve à l'intérieur de `dir`. */
function isInside(path: string, dir: string): boolean {
	const rel = relative(dir, path);
	return rel === "" || !(rel.startsWith("..") || isAbsolute(rel));
}

/**
 * Documentation de Pi (dossier docs/, exemples et README). Pi fournit
 * lui-même ces chemins, quel que soit son mode d'installation (Nix, npm…).
 * En cas d'erreur, on n'ajoute rien : les lectures redemandent alors
 * confirmation (fail closed).
 */
function piDocPaths(): string[] {
	try {
		return [getDocsPath(), getExamplesPath(), getReadmePath()];
	} catch {
		return [];
	}
}

const PI_DOC_PATHS = piDocPaths();

/**
 * Dossiers où l'agent peut lire librement (hors fichiers secrets) :
 * le dossier de la session (cwd), les dossiers temporaires et la
 * documentation de Pi.
 */
function allowedDirs(): string[] {
	return [process.cwd(), "/tmp", tmpdir(), ...PI_DOC_PATHS];
}

/**
 * Vrai si `path` se trouve en dehors de tous les dossiers autorisés
 * (dossier de travail courant, /tmp, documentation de Pi).
 * `resolve` normalise le chemin : `/tmp/../etc/passwd` devient `/etc/passwd`
 * et reste donc bien considéré comme « hors » des dossiers autorisés.
 */
export function callsSuspiciousPath(path: string): boolean {
	// `~` n'est pas compris par `resolve` : on le remplace par le dossier perso.
	const expanded = path === "~" || path.startsWith("~/") ? homedir() + path.slice(1) : path;
	const abs = resolve(process.cwd(), expanded);
	return !allowedDirs().some((dir) => isInside(abs, dir));
}
