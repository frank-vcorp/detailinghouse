# SPEC-DEPLOY-001 — Content-Security-Policy estricto en `vercel.json` (y `netlify.toml`)

**ID:** `FIX-20260710-03`
**Tipo:** Hardening de seguridad
**Prioridad:** Alta
**Estimación:** 30 minutos
**Origen:** Auditoría `ARCH-20260710-01` §3 spec

---

## 1. Contexto

El sitio `detailinghouse.com.mx` se sirve actualmente desde **Vercel** (deploy via `vercel deploy --prod --yes`). El `vercel.json` tiene `headers` con cache-control y nada más. No hay CSP.

`netlify.toml` también tiene `headers` (con X-Frame-Options, etc.) pero el deploy activo es Vercel. `netlify.toml` queda por completitud (por si en el futuro vuelven a Netlify).

**Vectores mitigados por CSP:**
- Inyección de scripts desde orígenes no autorizados (XSS reflection)
- Carga de iframes maliciosos (clickjacking)
- Conexiones a dominios no autorizados (exfiltración de datos vía fetch)
- Carga de imágenes/fuentes de CDNs no confiables

## 2. Estado actual

### `vercel.json` (en uso, deploy Vercel)

```json
"headers": [
  { "source": "/assets/images/(.*)", "headers": [{ "key": "Cache-Control", "value": "..." }] },
  { "source": "/assets/videos/(.*)", "headers": [{ "key": "Cache-Control", "value": "..." }] },
  { "source": "/assets/docs/(.*)",   "headers": [{ "key": "Cache-Control", "value": "..." }] },
  { "source": "/(.*)", "headers": [
      { "key": "X-Frame-Options", "value": "DENY" },
      { "key": "X-Content-Type-Options", "value": "nosniff" },
      { "key": "X-XSS-Protection", "value": "1; mode=block" },
      { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" },
      { "key": "Permissions-Policy", "value": "camera=(), microphone=(), geolocation=(self)" }
  ]}
]
```

**Falta:** `Content-Security-Policy`, `Strict-Transport-Security`, `Cross-Origin-*`.

### `netlify.toml` (no en uso, por completitud)

Similar a `vercel.json` pero con headers X-Frame-Options, etc. **Falta:** CSP.

## 3. Decisión de implementación

Añadir CSP a `vercel.json` (en uso) **Y** a `netlify.toml` (por completitud). Directivas elegidas conservadoramente:

| Directiva | Valor | Razón |
|---|---|---|
| `default-src` | `'self'` | Default deny |
| `script-src` | `'self' 'unsafe-inline'` | Todo el JS es inline en `index.html` (sin bundler). `'unsafe-inline'` es necesario. Trade-off conocido. |
| `style-src` | `'self' 'unsafe-inline' https://fonts.googleapis.com` | Styles inline + Google Fonts (Inter, Rajdhani) |
| `font-src` | `'self' https://fonts.gstatic.com` | Fonts de Google |
| `img-src` | `'self' data:` | Imágenes locales + avatars con `data:image/svg+xml,...` |
| `connect-src` | `'self' https://detailinghouse-api-production.up.railway.app` | Fetch a API (vía Vercel rewrite `/api/*` resuelve a railway.app, pero el browser ve mismo origen para `/api`; el dominio de la API es para futuras llamadas directas) |
| `frame-ancestors` | `'none'` | Equivalente moderno a `X-Frame-Options: DENY` (CSP reemplaza este header) |
| `base-uri` | `'self'` | Evita `<base href="...">` malicioso |
| `form-action` | `'self'` | Forms solo envíen a mismo origen |
| `object-src` | `'none'` | Sin `<object>`, `<embed>`, `<applet>` |
| `upgrade-insecure-requests` | (implícito) | Forzar HTTPS |

**Headers adicionales a añadir:**
- `Strict-Transport-Security: max-age=31536000; includeSubDomains` (HSTS)
- `Cross-Origin-Opener-Policy: same-origin` (COOP)
- `Cross-Origin-Embedder-Policy: require-corp` (COEP, opcional, puede romper)
- `Cross-Origin-Resource-Policy: same-site` (CORP)

Por seguridad inicial, **añadimos solo HSTS** y dejamos COOP/COEP/CORP para sprints futuros (pueden romper funcionalidades).

## 4. Alcance

### In-scope

- `vercel.json` — añadir `Content-Security-Policy` y `Strict-Transport-Security` al header universal `/(.*)`
- `netlify.toml` — añadir las mismas directivas en el header `/*` (por completitud, aunque no se use)
- Verificación: el sitio sigue cargando, Google Fonts funciona, los `/api/*` se llaman correctamente
- Smoke E2E en producción

### Out-of-scope

- Refactor a nonces para `script-src` (gran cambio, sprint separado)
- `report-uri` / `report-to` (CSP reporting, sprint separado)
- Mover de `'unsafe-inline'` a hashes/nonces (alto esfuerzo, sprint separado)

## 5. Implementación

### 5.1 `vercel.json` (cambio)

Añadir 2 headers al bloque existente `/(.*)`:

```json
{
  "source": "/(.*)",
  "headers": [
    { "key": "X-Frame-Options", "value": "DENY" },
    { "key": "X-Content-Type-Options", "value": "nosniff" },
    { "key": "X-XSS-Protection", "value": "1; mode=block" },
    { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" },
    { "key": "Permissions-Policy", "value": "camera=(), microphone=(), geolocation=(self)" },
    { "key": "Content-Security-Policy", "value": "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data:; connect-src 'self' https://detailinghouse-api-production.up.railway.app; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; object-src 'none'; upgrade-insecure-requests" },
    { "key": "Strict-Transport-Security", "value": "max-age=31536000; includeSubDomains" }
  ]
}
```

### 5.2 `netlify.toml` (cambio)

Añadir 2 headers al bloque existente `[headers.values]` para `/*`:

```toml
[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    X-XSS-Protection = "1; mode=block"
    Referrer-Policy = "strict-origin-when-cross-origin"
    Permissions-Policy = "camera=(), microphone=(), geolocation=(self)"
    Content-Security-Policy = "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data:; connect-src 'self' https://detailinghouse-api-production.up.railway.app; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; object-src 'none'; upgrade-insecure-requests"
    Strict-Transport-Security = "max-age=31536000; includeSubDomains"
```

## 6. Criterios de aceptación

| ID | Criterio | Verificación |
|---|---|---|
| CA-1 | `vercel.json` tiene `Content-Security-Policy` | `grep "Content-Security-Policy" vercel.json` → ≥ 1 |
| CA-2 | `vercel.json` tiene `Strict-Transport-Security` | `grep "Strict-Transport-Security" vercel.json` → ≥ 1 |
| CA-3 | `netlify.toml` tiene `Content-Security-Policy` | `grep "Content-Security-Policy" netlify.toml` → ≥ 1 |
| CA-4 | CSP incluye `default-src 'self'` | `grep "default-src 'self'" vercel.json` → ≥ 1 |
| CA-5 | CSP incluye `script-src 'self' 'unsafe-inline'` (para que el JS inline funcione) | `grep "script-src.*'unsafe-inline'" vercel.json` → ≥ 1 |
| CA-6 | CSP incluye `style-src ... https://fonts.googleapis.com` (Google Fonts) | `grep "fonts.googleapis.com" vercel.json` → ≥ 1 |
| CA-7 | CSP incluye `connect-src ... railway.app` (para llamadas a la API si Vercel rewrite falla) | `grep "railway.app" vercel.json` → ≥ 1 |
| CA-8 | CSP incluye `frame-ancestors 'none'` (anti-clickjacking) | `grep "frame-ancestors 'none'" vercel.json` → ≥ 1 |
| CA-9 | JSON válido en `vercel.json` | `python3 -c "import json; json.load(open('vercel.json'))"` |
| CA-10 | TOML válido en `netlify.toml` | `python3 -c "import tomllib; tomllib.load(open('netlify.toml', 'rb'))"` o equivalente |
| CA-11 | Header CSP visible en producción tras deploy | `curl -sI https://detailinghouse.com.mx \| grep "Content-Security-Policy"` → contiene el valor |
| CA-12 | El sitio sigue cargando (público + admin) sin errores de CSP en console | Playwright E2E con `console` listener, 0 errores de tipo "Refused to ..." |
| CA-13 | Google Fonts carga (no se rompen las fuentes) | Playwright verifica que `document.fonts.ready` resuelve sin error o que los `@font-face` están aplicados |
| CA-14 | Login admin sigue funcionando | Playwright E2E 18/18 + login + venta E2E |

## 7. Tests

### 7.1 Verificación de headers en producción

```bash
curl -sI https://detailinghouse.com.mx | grep -E "Content-Security-Policy|Strict-Transport"
```

### 7.2 Smoke E2E con Playwright

Reusar `/tmp/kilo/smoke.js` o `verify-cors-fix.js`. Verificar:
- Página pública carga
- 30 productos
- Login admin
- 7 tabs
- Venta E2E
- **0 console errors** (CSP violations aparecerían como console errors tipo "Refused to apply inline style because it violates the following Content Security Policy directive...")

### 7.3 Test específico de CSP (Playwright)

```js
// Capturar TODOS los console messages
const messages = [];
page.on('console', m => messages.push({ type: m.type(), text: m.text() }));

// Después de cargar, buscar CSP violations
const cspViolations = messages.filter(m => m.text().includes('Content Security Policy') || m.text().includes('Refused to'));
console.log('CSP violations:', cspViolations);
// debe ser []
```

## 8. Riesgos

| Riesgo | Mitigación |
|---|---|
| CSP demasiado estricto rompe Google Fonts | Incluir `fonts.googleapis.com` y `fonts.gstatic.com` en directivas correspondientes |
| CSP rompe `/api/*` calls (Vercel rewrite) | `connect-src` solo se aplica a fetch/XHR/WebSocket. Vercel rewrite hace el rewrite server-side, el browser ve `/api/*` como mismo origen. PERO incluyo `railway.app` por si en el futuro Vercel rewrite falla |
| CSP rompe `data:` URIs (avatars SVG) | Incluir `data:` en `img-src` |
| `upgrade-insecure-requests` rompe algo | El sitio ya es HTTPS-only (Netlify/Vercel forzado), no debería haber requests HTTP inseguros |
| `'unsafe-inline'` en script-src anula parcialmente la protección XSS | Trade-off conocido. Sprint futuro: mover a nonces (gran cambio). FIX-20260710-07 (XSS en dhAdminModal) cubre el vector actual más crítico |

## 9. Orden de ejecución para SOFIA

1. Backup: `cp vercel.json vercel.json.bak-pre-fix-20260710-03` y `cp netlify.toml netlify.toml.bak-pre-fix-20260710-03` (los .bak-* ya están en .gitignore)
2. Modificar `vercel.json` (añadir 2 headers al bloque `/(.*)`)
3. Modificar `netlify.toml` (añadir 2 headers al bloque `[headers.values]` para `/*`)
4. Verificar CA-1 a CA-10 con greps
5. Commit y push
6. **NO deployar a Vercel** (eso lo hace INTEGRA tras OK)
7. Generar checkpoint `context/checkpoints/CHK_2026-07-10_HHMM_fix-csp.md`

## 10. Salida esperada

- 1 commit: `feat(security): add Content-Security-Policy headers (FIX-20260710-03)`
- 2 archivos modificados (`vercel.json`, `netlify.toml`)
- Headers CSP + HSTS en producción tras deploy
- 14/14 criterios ✅
- Smoke E2E 18/18 sin nuevos console errors

---

**Aprobado por:** INTEGRA
**Pendiente:** OK del humano para delegar a SOFIA (ya dado en esta sesión).
