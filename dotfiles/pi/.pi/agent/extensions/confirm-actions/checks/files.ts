const SENSITIVE_PATTERNS = [
	/\.env(\..*)?$/i, // .env, .env.local, …
	/\.pem$/i,
	/\.key$/i,
	/id_rsa/i,
	/id_ed25519/i,
	/secrets?/i,
	/credentials?/i,
	/\.npmrc$/i,
	/\.aws\//i,
	/\.ssh\//i,
];

export function isSensitiveFile(path: string): boolean {
	return SENSITIVE_PATTERNS.some((p) => p.test(path));
}
