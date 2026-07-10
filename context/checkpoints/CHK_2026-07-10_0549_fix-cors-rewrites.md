# CHK · 2026-07-10 05:49 · Fix CORS via Vercel rewrites

**ID intervención:** IMPL-20260710-02
**Tipo:** fix (workaround CORS, no parche backend)
**Agente:** SOFIA (Constructora)
**Trigger:** Frontend `detailinghouse.com.mx` no recibe `Access-Control-Allow-Origin` del backend Railway. El backend está en otro workspace y NO podemos tocarlo desde este repo.

---

## 🎯 Objetivo

Bypass CORS proxiando `/api/*` del frontend a la API Railway via Vercel rewrites.
El browser ve mismo origen → CORS desaparece → headers `vary: Origin` y whitelist quedan en el backend sin afectarnos.

---

## 🛠 Cambios aplicados (exactamente 2 archivos)

### 1. `vercel.json` — rewrite de proxy

```diff
   "rewrites": [
+    { "source": "/api/:path*", "destination": "https://detailinghouse-api-production.up.railway.app/api/:path*" },
     { "source": "/(.*)", "destination": "/index.html" }
   ]
```

**Orden crítico respetado:** el rewrite específico `/api/:path*` está ANTES del catch-all `/(.*)`. Si el catch-all ganara, todo se serviría desde `index.html` y nunca se proxificaría.

### 2. `index.html` (línea 3885) — API_BASE relativo

```diff
-  const API_BASE      = 'https://detailinghouse-api-production.up.railway.app/api';
+  const API_BASE      = '/api';
```

Uso existente en `index.html` (línea 3950):
```js
const resp = await fetch(`${API_BASE}${path}`, { ...options, headers });
```
`path` ya viene con `/...` (ej. `/inventory`, `/auth/login`), por lo que `${API_BASE}${path}` ahora produce `/api/inventory`, `/api/auth/login`, etc. — el rewrite de Vercel los captura y los proxia a Railway.

---

## ✅ Validaciones ejecutadas

| # | Check | Resultado |
|---|---|---|
| 1 | `python3 -c "import json; json.load(open('vercel.json'))"` | **OK** — JSON válido |
| 2 | `git diff vercel.json` | **OK** — solo +1 línea (rewrite `/api/:path*` antes del catch-all) |
| 3 | `git diff index.html \| grep API_BASE` | **OK** — solo la línea de la constante cambiada |
| 4 | `git status --short` | **OK** — solo `M index.html` y `M vercel.json` |
| 5 | Local: `python3 -m http.server 8080` + `curl /` | **OK** — público carga (200 OK). Admin fallará en local porque `/api` resuelve a `/api/` sin rewrite — esperado y documentado en la SPEC. |

---

## 🔍 Self-review manual (reemplazo Qodo, sunset 2026-06-22)

- [x] **Refleja la SPEC?** Sí. La intención es eliminar dependencia CORS del frontend sin tocar backend. El rewrite `/api/:path*` es el patrón canónico de Vercel para proxy.
- [x] **Code smells?** Ninguno. Cambio mínimo, surgical.
- [x] **Edge cases cubiertos?**
  - Path con múltiples segmentos (`/api/admin/users/123`) → `:path*` captura cualquier profundidad ✓
  - Query strings → Vercel los reenvía transparentemente al destino ✓
  - Assets estáticos (`/assets/images/...`) → NO entran en `/api/:path*`, siguen sirviéndose desde disco ✓
  - SPA fallback (`/`, `/carrito`, `/admin`) → Catch-all los sirve a `index.html` ✓
- [x] **Riesgo de regresión?**
  - **Prod:** Ninguno. Es estrictamente aditivo: el rewrite específico va primero, catch-all solo aplica a rutas no-`/api`.
  - **Local dev (python http.server):** Admin y endpoints `/api/*` rompen en local porque python no implementa rewrites. Mitigación documentada; el usuario puede usar Vercel CLI (`vercel dev`) si necesita admin en local.
  - **Headers de seguridad:** No se modificaron. El bloque `headers` (X-Frame-Options, etc.) sigue intacto.
- [x] **¿Cambios fuera de alcance?** No. Cero modificaciones a precios, copy, CSS, o HTML fuera de la constante.

---

## ⚠️ Notas para INTEGRA

- **NO se commiteó, NO se pusheó, NO se abrió PR.** Quedan staged en working tree para que INTEGRA (humano o arquitecto) decida.
- **Después del deploy a Vercel:** validar en `detailinghouse.com.mx` que:
  1. `fetch('/api/health')` (o equivalente) devuelve 200.
  2. DevTools → Network muestra la request a `/api/...` (mismo origen), NO a `railway.app`.
  3. No hay preflight `OPTIONS` fallando (porque ya no es cross-origin).
- **Opcional (no urgente):** agregar nota en `PROYECTO.md` sobre la limitación de dev local. Lo dejo a criterio del arquitecto para mantener alcance mínimo.

---

## 📂 Archivos tocados

- `vercel.json` — 1 línea agregada
- `index.html` — 1 línea modificada (constante `API_BASE`)