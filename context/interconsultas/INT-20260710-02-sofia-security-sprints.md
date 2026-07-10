# INT-20260710-02 — Handoff a SOFIA: Sprints de seguridad (XSS + CSP)

**De:** INTEGRA
**Para:** SOFIA (`subagent_type='sofia'`)
**Fecha:** 2026-07-10
**Sprint:** `FIX-20260710-07` (XSS) + `FIX-20260710-03` (CSP)
**SPECs:** [`SPEC-FRONTEND-002-xss-dhmodal.md`](../SPECs/SPEC-FRONTEND-002-xss-dhmodal.md) + [`SPEC-DEPLOY-001-csp-headers.md`](../SPECs/SPEC-DEPLOY-001-csp-headers.md)
**Estado:** Pendiente de delegación

---

## 🎯 Objetivo

Ejecutar 2 sprints de seguridad en `index.html` y `vercel.json` + `netlify.toml`:

1. **FIX-20260710-07** — Sanitizar `dhAdminModal` para prevenir XSS
2. **FIX-20260710-03** — Añadir Content-Security-Policy headers

Ambos son cambios pequeños, ambos son quick wins de seguridad, ambos caben en una sesión.

## 📚 Documentación obligatoria

1. **SPECs (LÉE PRIMERO):**
   - `context/SPECs/SPEC-FRONTEND-002-xss-dhmodal.md` — diseño exacto del fix XSS
   - `context/SPECs/SPEC-DEPLOY-001-csp-headers.md` — diseño exacto del CSP

2. **ADRs relevantes:**
   - `context/decisions/ADR-20260710-05-escape-html-no-dompurify.md` — decisión de usar `escapeHtml` inline en vez de DOMPurify

3. **PROYECTO.md** — backlog completo

## 📦 Alcance concreto

### FIX-07 (XSS) — 1 archivo: `index.html`

**3 cambios:**

a) Añadir helper al top del IIFE principal (después de `formatCurrency`):
```js
const escapeHtml = s => String(s == null ? '' : s)
  .replace(/[&<>"']/g, c => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  }[c]));
```

b) Caller 1 (L4883-4887) "Editar stock": envolver `item.name`, `item.sku`, `item.stock` (×2) con `escapeHtml(...)`.

c) Caller 2 (L5001-5005) "Actualizar cita": envolver `appt.client`, `appt.service`, `appt.date`, `appt.time`, `appt.address` con `escapeHtml(...)`.

### FIX-03 (CSP) — 2 archivos: `vercel.json` + `netlify.toml`

**Cambio en `vercel.json`** (en uso, deploy Vercel):

Añadir 2 headers al bloque `/(.*)`:
- `Content-Security-Policy` con directivas (ver SPEC §3)
- `Strict-Transport-Security: max-age=31536000; includeSubDomains`

**Cambio en `netlify.toml`** (no en uso, por completitud):

Añadir los mismos 2 headers al bloque `[[headers]]` con `for = "/*"`.

## 🛠️ Orden de ejecución que DEBES seguir

1. **Backup:**
   ```bash
   cp index.html index.html.bak-pre-fix-20260710-07
   cp vercel.json vercel.json.bak-pre-fix-20260710-03
   cp netlify.toml netlify.toml.bak-pre-fix-20260710-03
   ```
   (Los .bak-* ya están en .gitignore, no se commitearán)

2. **FIX-07 primero** (orden importa: queremos el fix de seguridad antes de que CSP rompa algo en debug)
   - Lee `SPEC-FRONTEND-002-xss-dhmodal.md` completa
   - Implementa el helper + 2 callers según §5.1, §5.2, §5.3 de la SPEC
   - Verifica CA-1 a CA-10 con greps

3. **FIX-03 segundo**
   - Lee `SPEC-DEPLOY-001-csp-headers.md` completa
   - Modifica `vercel.json` y `netlify.toml` según §5.1, §5.2
   - Verifica CA-1 a CA-10 con greps

4. **Validaciones automatizables** (corre y reporta output):
   ```bash
   # FIX-07
   grep -c "const escapeHtml" index.html                              # CA-1
   grep -A1 "Editar stock" index.html | grep "escapeHtml" | wc -l      # CA-2
   grep -A1 "Actualizar cita" index.html | grep "escapeHtml" | wc -l    # CA-3
   grep -E "body:.*\\\${(item|appt)\." index.html                     # CA-4 (debe ser 0)

   # FIX-03
   grep "Content-Security-Policy" vercel.json                          # CA-1
   grep "Strict-Transport-Security" vercel.json                        # CA-2
   grep "Content-Security-Policy" netlify.toml                         # CA-3
   grep "default-src 'self'" vercel.json                               # CA-4
   grep "script-src.*'unsafe-inline'" vercel.json                     # CA-5
   grep "fonts.googleapis.com" vercel.json                             # CA-6
   grep "railway.app" vercel.json                                      # CA-7
   grep "frame-ancestors 'none'" vercel.json                           # CA-8
   python3 -c "import json; json.load(open('vercel.json'))"            # CA-9
   python3 -c "import tomllib; tomllib.load(open('netlify.toml','rb'))" # CA-10
   ```

5. **Tests funcionales** (NO deployar a Vercel):
   - Correr smoke E2E localmente (reusar `/tmp/kilo/smoke.js`)
   - Iniciar `python3 -m http.server 8080` (lo haré yo)
   - **NO deployar a Vercel** (eso lo hace INTEGRA tras OK)

## ✅ Entregables del reporte final

- Archivos modificados (deben ser 3: `index.html`, `vercel.json`, `netlify.toml`)
- Output de los 11 greps de validación
- Resultado del smoke E2E local
- Self-review manual (ver bloque siguiente)
- 2 checkpoints generados:
  - `context/checkpoints/CHK_2026-07-10_HHMM_fix-xss.md`
  - `context/checkpoints/CHK_2026-07-10_HHMM_fix-csp.md`

## 🔍 Self-review manual (obligatorio en lugar de Qodo)

Incluye en tu reporte final:

### FIX-07
1. ¿`escapeHtml` se aplica a TODOS los valores user-input en los 2 callers?
2. ¿Hay algún otro caller de `dhAdminModal` que se me haya escapado al auditar?
3. ¿Algún valor user-input se renderiza en otro `innerHTML` del archivo (no solo en `dhAdminModal`) que también necesite escape?
4. ¿`escapeHtml` maneja correctamente `null` / `undefined` / números?

### FIX-03
1. ¿Las directivas CSP son las mínimas necesarias? (no sobre-restrictivas que rompan nada)
2. ¿`frame-ancestors 'none'` reemplaza correctamente a `X-Frame-Options: DENY`? (CSP es moderno, ambos pueden coexistir)
3. ¿`upgrade-insecure-requests` puede romper algo? (debería ser seguro porque el sitio es HTTPS)
4. ¿Google Fonts y los `/api/*` calls funcionarán con las directivas elegidas?

### General
1. ¿Riesgo de regresión?
2. ¿Quedó alguna referencia muerta?

## ⚠️ Validaciones obligatorias antes de cerrar

1. Los 11 greps listados arriba pasan
2. JSON y TOML válidos (sin errores de parseo)
3. Smoke E2E local 18/18 OK (reusar `/tmp/kilo/smoke.js` con `python3 -m http.server 8080`)
4. 0 console errors en el smoke

## 🤝 Al cerrar

1. Reportá con el formato INTEGRA estándar: archivos tocados, resultado de greps, smoke, self-review
2. **NO commitear, NO pushear, NO deployar a Vercel.** INTEGRA lo hace tras verificar.
3. Generá los 2 checkpoints.
4. **Sugerí** que INTEGRA invoque a **GEMINI** como segunda mano antes de commit.

## ⛔ Restricciones

- **NO modifiques otros archivos** fuera de `index.html`, `vercel.json`, `netlify.toml`.
- **NO commitear, NO pushear, NO deployar.** Espera OK del humano.
- **NO ejecutes `qodo` (está sunset).** Self-review manual únicamente.
- **NO cambies precios, copy público, ni HTML/CSS fuera del scope.**
- **NO uses dependencias externas** (sin DOMPurify, sin helmet, etc.).

Devuélveme un único mensaje final con el reporte completo de los 2 sprints.
