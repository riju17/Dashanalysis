const TOURNAMENT_STORAGE_KEY = "statstrike.activeTournamentSlug";
const TOURNAMENT_COOKIE_KEY = "statstrike_active_tournament";

function normalizeTargetPath(target: string) {
  if (!target) return "/";
  if (target.startsWith("/")) return target;
  return `/${target}`;
}

export function extractTournamentSlug(pathname?: string | null) {
  if (!pathname) return null;
  const match = pathname.match(/^\/tournament\/([^/]+)(?:\/|$)/);
  return match?.[1] ?? null;
}

export function getStoredTournamentSlug() {
  if (typeof window === "undefined") return null;

  const fromStorage = window.localStorage.getItem(TOURNAMENT_STORAGE_KEY);
  if (fromStorage) return fromStorage;

  const cookie = document.cookie
    .split(";")
    .map((entry) => entry.trim())
    .find((entry) => entry.startsWith(`${TOURNAMENT_COOKIE_KEY}=`));

  if (!cookie) return null;
  const [, value = ""] = cookie.split("=");
  return decodeURIComponent(value) || null;
}

export function setStoredTournamentSlug(slug: string) {
  if (typeof window === "undefined") return;
  window.localStorage.setItem(TOURNAMENT_STORAGE_KEY, slug);
  document.cookie = `${TOURNAMENT_COOKIE_KEY}=${encodeURIComponent(slug)}; path=/; max-age=${60 * 60 * 24 * 30}; samesite=lax`;
}

export function clearStoredTournamentSlug() {
  if (typeof window === "undefined") return;
  window.localStorage.removeItem(TOURNAMENT_STORAGE_KEY);
  document.cookie = `${TOURNAMENT_COOKIE_KEY}=; path=/; max-age=0; samesite=lax`;
}

export function resolveTournamentSlug(pathname?: string | null) {
  return extractTournamentSlug(pathname) ?? getStoredTournamentSlug();
}

export function buildTournamentPath(slug: string, target = "") {
  const normalizedTarget = normalizeTargetPath(target);
  if (normalizedTarget === "/") return `/tournament/${slug}`;
  if (normalizedTarget.startsWith("/tournament/")) return normalizedTarget;
  return `/tournament/${slug}${normalizedTarget}`;
}

export function withTournamentPath(pathname: string | null | undefined, target: string) {
  const slug = resolveTournamentSlug(pathname);
  if (!slug) return normalizeTargetPath(target);
  return buildTournamentPath(slug, target);
}

export function getBrowserTournamentPath(target: string) {
  if (typeof window === "undefined") return normalizeTargetPath(target);
  return withTournamentPath(window.location.pathname, target);
}
