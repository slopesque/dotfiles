// Based-on: ✨ vibe coding ✨

/**
 * Web Search Extension
 * ====================
 *
 * Donne à l'agent deux outils pour accéder à des informations ACTUALISÉES
 * depuis Internet, sans clé d'API :
 *
 *   - `web_search` : recherche sur le Web (via DuckDuckGo) et renvoie une
 *                    liste de résultats (titre, URL, extrait).
 *   - `web_fetch`  : récupère le contenu texte d'une page Web à partir de
 *                    son URL.
 *
 * Ces deux outils sont volontairement décrits de façon simple et explicite
 * pour qu'un petit modèle (open-source, < 12B) les détecte et les préfère
 * plutôt que d'essayer de fabriquer des commandes `curl` lui-même.
 *
 * Installation : ce fichier est auto-découvert depuis
 *   ~/.pi/agent/extensions/web-search.ts
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

// ---------------------------------------------------------------------------
// Petits utilitaires (volontairement sans dépendance externe)
// ---------------------------------------------------------------------------

/** Retire les balises HTML et normalise les espaces pour obtenir du texte brut. */
function htmlToText(html: string): string {
	return html
		.replace(/<script[\s\S]*?<\/script>/gi, " ")
		.replace(/<style[\s\S]*?<\/style>/gi, " ")
		.replace(/<[^>]+>/g, " ")
		.replace(/&nbsp;/g, " ")
		.replace(/&amp;/g, "&")
		.replace(/&lt;/g, "<")
		.replace(/&gt;/g, ">")
		.replace(/&quot;/g, '"')
		.replace(/&#39;/g, "'")
		.replace(/\s+/g, " ")
		.trim();
}

/** DuckDuckGo encapsule souvent l'URL cible dans un lien de redirection. */
function cleanDuckDuckGoUrl(href: string): string {
	try {
		const url = new URL(href, "https://duckduckgo.com");
		const target = url.searchParams.get("uddg");
		return target ? decodeURIComponent(target) : url.toString();
	} catch {
		return href;
	}
}

interface SearchResult {
	title: string;
	url: string;
	snippet: string;
}

/** Extrait les résultats de la page HTML de DuckDuckGo (endpoint "html"). */
function parseResults(html: string, limit: number): SearchResult[] {
	const results: SearchResult[] = [];
	// Chaque résultat contient un lien <a class="result__a" href="...">Titre</a>.
	const linkRe = /<a[^>]*class="[^"]*result__a[^"]*"[^>]*href="([^"]+)"[^>]*>([\s\S]*?)<\/a>/gi;
	const snippetRe = /<a[^>]*class="[^"]*result__snippet[^"]*"[^>]*>([\s\S]*?)<\/a>/gi;

	const snippets: string[] = [];
	let sm: RegExpExecArray | null;
	while ((sm = snippetRe.exec(html)) !== null) snippets.push(htmlToText(sm[1]));

	let m: RegExpExecArray | null;
	let i = 0;
	while ((m = linkRe.exec(html)) !== null && results.length < limit) {
		results.push({
			title: htmlToText(m[2]) || "(sans titre)",
			url: cleanDuckDuckGoUrl(m[1]),
			snippet: snippets[i] ?? "",
		});
		i++;
	}
	return results;
}

// ---------------------------------------------------------------------------
// Enregistrement des outils
// ---------------------------------------------------------------------------

export default function webSearchExtension(pi: ExtensionAPI) {
	// --- Outil 1 : recherche Web ------------------------------------------
	pi.registerTool({
		name: "web_search",
		label: "Recherche Web",
		description:
			"Recherche des informations À JOUR sur Internet. À utiliser pour toute " +
			"question portant sur l'actualité, des versions récentes, de la documentation, " +
			"ou dès qu'une information peut avoir changé. Renvoie une liste de résultats " +
			"(titre, URL, extrait). Préférez cet outil plutôt que de deviner ou d'écrire " +
			"une commande curl/wget vous-même.",
		parameters: Type.Object({
			query: Type.String({ description: "La requête de recherche, en langage naturel." }),
			limit: Type.Optional(
				Type.Number({ description: "Nombre maximum de résultats (défaut 5).", default: 5 }),
			),
		}),
		async execute(_toolCallId, params, signal) {
			const limit = Math.min(Math.max(params.limit ?? 5, 1), 10);
			const endpoint = "https://html.duckduckgo.com/html/";

			const response = await fetch(endpoint, {
				method: "POST",
				headers: {
					"Content-Type": "application/x-www-form-urlencoded",
					"User-Agent": "Mozilla/5.0 (compatible; PiAgent/1.0)",
				},
				body: new URLSearchParams({ q: params.query }).toString(),
				signal,
			});

			if (!response.ok) {
				return {
					content: [{ type: "text", text: `Erreur de recherche: HTTP ${response.status}` }],
					isError: true,
					details: {},
				};
			}

			const html = await response.text();
			const results = parseResults(html, limit);

			if (results.length === 0) {
				return {
					content: [{ type: "text", text: `Aucun résultat pour: ${params.query}` }],
					details: { query: params.query, results: [] },
				};
			}

			const text = results
				.map((r, idx) => `${idx + 1}. ${r.title}\n   ${r.url}\n   ${r.snippet}`)
				.join("\n\n");

			return {
				content: [{ type: "text", text: `Résultats pour "${params.query}":\n\n${text}` }],
				details: { query: params.query, results },
			};
		},
	});

	// --- Outil 2 : récupération d'une page Web ----------------------------
	pi.registerTool({
		name: "web_fetch",
		label: "Lecture Web",
		description:
			"Récupère le contenu texte d'une page Web à partir de son URL. À utiliser " +
			"pour lire en détail un résultat renvoyé par web_search. Le HTML est converti " +
			"en texte brut.",
		parameters: Type.Object({
			url: Type.String({ description: "L'URL complète (http/https) de la page à lire." }),
			maxChars: Type.Optional(
				Type.Number({ description: "Longueur max du texte renvoyé (défaut 4000).", default: 4000 }),
			),
		}),
		async execute(_toolCallId, params, signal) {
			const maxChars = Math.min(Math.max(params.maxChars ?? 4000, 200), 20000);

			let response: Response;
			try {
				response = await fetch(params.url, {
					headers: { "User-Agent": "Mozilla/5.0 (compatible; PiAgent/1.0)" },
					signal,
				});
			} catch (err) {
				return {
					content: [{ type: "text", text: `Impossible de récupérer ${params.url}: ${String(err)}` }],
					isError: true,
					details: {},
				};
			}

			if (!response.ok) {
				return {
					content: [{ type: "text", text: `Erreur HTTP ${response.status} pour ${params.url}` }],
					isError: true,
					details: {},
				};
			}

			const raw = await response.text();
			const text = htmlToText(raw);
			const truncated = text.length > maxChars;
			const body = truncated ? `${text.slice(0, maxChars)}\n\n[… contenu tronqué]` : text;

			return {
				content: [{ type: "text", text: `Contenu de ${params.url}:\n\n${body}` }],
				details: { url: params.url, length: text.length, truncated },
			};
		},
	});
}
