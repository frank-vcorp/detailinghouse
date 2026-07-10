# INT-20260710-03 — Handoff a SOFIA: FIX-15 (XSS restantes) + FIX-08 (retry backoff)

**De:** INTEGRA
**Para:** SOFIA (`subagent_type='sofia'`)
**Fecha:** 2026-07-10
**Sprints:** `FIX-20260710-15` + `FIX-20260710-08`
**SPECs:** [`SPEC-FRONTEND-003`](../SPECs/SPEC-FRONTEND-003-xss-remaining.md) + [`SPEC-FRONTEND-004`](../SPECs/SPEC-FRONTEND-004-retry-backoff.md)
**Estado:** Pendiente de delegación

---

## 🎯 Objetivo

2 sprints:
1. **FIX-15** (~20 min) — Escapar 4 innerHTML adicionales con user-data en `index.html`
2. **FIX-08** (~1h) — Añadir reintentos con backoff exponencial en `api.request` (solo GETs)

Total: ~1.2h. Ambos son cambios surgicales en `index.html`.

## 📚 Documentación obligatoria

1. **SPECs:**
   - `/home/frank/repos/detailinghouse/context/SPECs/SPEC-FRONTEND-003-xss-remaining.md` (FIX-15)
   - `/home/frank/repos/detailinghouse/context/SPECs/SPEC-FRONTEND-004-retry-backoff.md` (FIX-08)

2. **ADR relevante:**
   - `/home/frank/repos/detailinghouse/context/decisions/ADR-20260710-05-escape-html-no-dompurify.md`

3. **Handoff INTEGRA:**
   - `/home/frank/repos/detailinghouse/context/interconsultas/INT-20260710-03-sofia-xss-retry.md` (este archivo)

4. **PROYECTO.md** — backlog

## 📦 Alcance concreto

### FIX-15 — Solo `index.html`

5 ediciones para escapar user-data en:
- **L4396** (`renderPosClientOptions`): escapar `c.name` y `c.phone`
- **L4415** (`renderSelectedClientInfo`): escapar `client.name`, `client.phone`, `client.points`, `visits`, `reward`
- **L4544** (`renderClients`): escapar `client.name`, `client.phone`, `client.carType`, `client.points`
- **L4686** (`renderDashboard` stockAlerts): escapar `item.name`, `item.stock`
- **L4688** (`renderDashboard` recentSalesBody): escapar `i.name`, `i.qty`, `sale.paymentMethod`

El helper `escapeHtml` YA EXISTE en L4035 (de FIX-07). Solo aplicarlo.

### FIX-08 — Solo `index.html` (función `api.request` en L3946)

Refactor de `api.request` para añadir:
- Reintentos solo para GETs
- Máximo 3 intentos (1 original + 2 reintentos)
- Backoff exponencial: 1s, 2s
- Solo reintentar en network errors y HTTP 5xx/429
- NO reintentar en 4xx (excepto 429) ni en JSON parse errors
- Log con `console.warn('[API] ...')` cada reintento

**NO uses librerías externas** (sin p-retry, sin axios, etc.). Implementación manual con `setTimeout`.

## 🛠️ Orden de ejecución

1. **Backup:**
   ```bash
   cd /home/frank/repos/detailinghouse
   cp index.html index.html.bak-pre-fix-20260710-15
   cp index.html index.html.bak-pre-fix-20260710-08
   ```

2. **FIX-15 primero** (orden importa: limpiamos XSS antes de tocar la API)
   - Lee `SPEC-FRONTEND-003` completa
   - Aplica `escapeHtml(...)` en los 5 innerHTML según §2 de la SPEC
   - Verifica CA-1 a CA-7 con greps

3. **FIX-08 segundo**
   - Lee `SPEC-FRONTEND-004` completa
   - Refactoriza `api.request` según §5 de la SPEC
   - Verifica CA-1 a CA-6 con greps

4. **Validaciones automatizables:**
   ```bash
   cd /home/frank/repos/detailinghouse

   # FIX-15
   echo "=== CA-1 escapeHtml en renderPosClientOptions (esperado ≥2) ==="
   sed -n '4393,4397p' index.html | grep -oE "escapeHtml" | wc -l

   echo "=== CA-2 escapeHtml en renderSelectedClientInfo (esperado ≥5) ==="
   sed -n '4408,4416p' index.html | grep -oE "escapeHtml" | wc -l

   echo "=== CA-3 escapeHtml en renderClients (esperado ≥4) ==="
   sed -n '4542,4544p' index.html | grep -oE "escapeHtml" | wc -l

   echo "=== CA-4 escapeHtml en stockAlerts (esperado ≥2) ==="
   sed -n '4684,4686p' index.html | grep -oE "escapeHtml" | wc -l

   echo "=== CA-5 escapeHtml en recentSalesBody (esperado ≥3) ==="
   sed -n '4687,4688p' index.html | grep -oE "escapeHtml" | wc -l

   echo "=== CA-6 Total escapeHtml (esperado ≥25) ==="
   grep -c "escapeHtml" index.html

   # FIX-08
   echo "=== CA-1 maxAttempts definido ==="
   grep -c "maxAttempts" index.html

   echo "=== CA-2 backoffMs definido ==="
   grep -c "backoffMs" index.html

   echo "=== CA-3 solo GETs se reintentan ==="
   grep -c "method === 'GET'" index.html

   echo "=== CA-4 4xx no se reintentan ==="
   grep -c "resp.status >= 400" index.html

   echo "=== CA-5 Network errors detectados ==="
   grep -c "isNetworkError" index.html

   echo "=== CA-6 Log [API] Reintento ==="
   grep -c "\[API\] Reintento" index.html
   ```

5. **Tests funcionales:**
   - NO hagas push ni deploy (lo hace INTEGRA tras OK)
   - NO hay test automatizable para retry; validación visual en el smoke
   - Si puedes, verifica con `node --check` que no hay errores de sintaxis

## ✅ Entregables del reporte final

- Archivos modificados (debe ser 1: `index.html`)
- Output de los 11 greps de validación
- Self-review manual (ver bloque siguiente)
- 2 checkpoints generados:
  - `context/checkpoints/CHK_2026-07-10_HHMM_fix-xss-remaining.md`
  - `context/checkpoints/CHK_2026-07-10_HHMM_fix-retry.md`
- **NO commitear, NO pushear, NO deployar.** INTEGRA lo hace tras OK.

## 🔍 Self-review manual (obligatorio en lugar de Qodo)

### FIX-15
1. ¿`escapeHtml` se aplica a TODOS los valores user-input en los 5 innerHTML?
2. ¿Quedó algún `${userData}` sin escapar en estos 5 innerHTML?
3. ¿Algún valor legítimo ahora se ve raro (por el escape)?

### FIX-08
1. ¿Los reintentos solo se aplican a GETs? (POST/PUT/DELETE no se reintentan, ¿correcto?)
2. ¿Los 4xx (excepto 429) NO se reintentan? (crítico para no duplicar ventas)
3. ¿El backoff es 1s + 2s = 3s total? (verificar `backoffMs = [0, 1000, 2000]`)
4. ¿El log es claro y útil para debugging?
5. ¿Comportamiento intacto para errores 4xx y network agotado?

### General
1. ¿Riesgo de regresión?
2. ¿Referencias muertas?

## ⚠️ Validaciones obligatorias antes de cerrar

1. Los 11 greps pasan
2. `node --check index.html` sin errores de sintaxis
3. 0 nuevos console.warn o console.error en flujo normal

## 🤝 Al cerrar

1. Reportá con el formato INTEGRA estándar
2. **NO commitear, NO pushear, NO deployar.** Espera OK del humano.
3. Generá los 2 checkpoints.
4. **Sugerí** GEMINI como segunda mano antes de commit.

## ⛔ Restricciones

- **NO modifiques otros archivos** fuera de `index.html`.
- **NO uses dependencias externas** (sin librerías de retry).
- **NO cambies comportamiento de POST/PUT/DELETE** (el retry solo en GETs).
- **NO ejecutes `qodo` (está sunset).** Self-review manual.

Devuélveme un único mensaje final con el reporte completo.
