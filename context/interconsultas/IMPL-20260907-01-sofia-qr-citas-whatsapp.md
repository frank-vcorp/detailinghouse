# IMPL-20260907-01 — Reporte de implementación SOFIA

- **ID intervención:** IMPL-20260907-01
- **ID tarea:** FEATURE-20260907-01 (P0, QR físico roto)
- **Estado:** READY_FOR_VERIFYING
- **SPEC:** `/home/frank/repos/detailinghouse/context/SPECs/SPEC-20260907-01-qr-citas-whatsapp.md`
- **ADR:** `/home/frank/repos/detailinghouse/context/decisions/ADR-20260907-01-qr-citas-counter.md`
- **Origen funcional:** `discovery/INDEX.md` (DEC-20260907-01/02, BR-20260907-01/02)
- **Arquitectura:** `ARCH-20260907-01`
- **Revisión:** delta sobre `citas.html` por 2 `IMPLEMENTATION_DEFECT` detectados por ATLAS. Ver §Delta.

## Resumen del cambio

Vertical slice local completo para que `/citas` muestre una pantalla intermedia de 3 s, registre `visit` y `whatsapp_open` contra dos contadores agregados (`qr_event_counters`) y abra `https://wa.me/524461153815` con el mensaje exacto de la SPEC. El dashboard admin muestra los dos totales sin alterar KPIs de ventas. Cero dependencias nuevas, cero migración destructiva, cero publicación.

## Archivos modificados

### Frontend (`/home/frank/repos/detailinghouse`)

| Archivo | Cambio |
|---|---|
| `citas.html` | **Nuevo.** Página autocontenida, mobile-first, accesible, con copy `Te estamos conectando con WhatsApp`, barra de progreso, contador 3-2-1, botón `Abrir WhatsApp ahora` (activo desde el primer render), URL `https://wa.me/524461153815?text=<mensaje exacto codificado>`, POST `visit` al cargar y `whatsapp_open` antes de la navegación con `fetch(..., { keepalive: true })` y guardas `sessionStorage` por pestaña. Si el POST falla, la navegación a WhatsApp continúa. Cumple la CSP existente (`script-src 'self' 'unsafe-inline'`, `connect-src https://detailinghouse-api-production.up.railway.app`). |
| `vercel.json` | Añadidos dos rewrites explícitos antes del catch-all: `{ source: "/citas", destination: "/citas.html" }` y `{ source: "/citas/", destination: "/citas.html" }`. El orden preserva prioridad sobre el `/(.*)` final. |
| `index.html` | Edición selectiva: dos nuevos `<article class="kpi">` (`Visitas desde QR` y `Aperturas de WhatsApp`) en el `tab-dashboard`, nuevo método `getQrSummary` en el cliente `api`, y nueva función `renderQrCounters()` invocada desde los tres caminos de `renderDashboard()` (sin sesión, server OK, server falló). Mantiene los KPIs de ventas existentes intactos. |
| `admin.html` | Edición selectiva (sin `cp`): mismas dos tarjetas KPI, mismo método `getQrSummary`, misma función `renderQrCounters`. Script `autoOpenAdmin` (FIX-21) preservado al final del `<body>`; diff entre `index.html` y `admin.html` confirma que el script no se duplicó ni se eliminó. |

### Backend (`/home/frank/repos/detailinghouse-api`)

| Archivo | Cambio |
|---|---|
| `routes/qr-events.js` | **Nuevo.** `POST /` (público, bajo rate-limit global existente en `server.js`): valida `event ∈ {visit, whatsapp_open}`, hace upsert atómico con `INSERT … ON CONFLICT … DO UPDATE SET total = total + 1`, responde `202 {ok:true}`; evento inválido → `400`. `GET /summary` (protegido por `authMiddleware` + `adminOnly`): devuelve `{ visit, whatsapp_open }` con ceros para eventos aún no registrados. |
| `db/migrate.js` | Añadida la tabla `qr_event_counters` (`event VARCHAR(32) PK`, `total BIGINT DEFAULT 0`, `updated_at TIMESTAMPTZ DEFAULT NOW()`, CHECK `event IN ('visit','whatsapp_open')`). Idempotente (`CREATE TABLE IF NOT EXISTS`). |
| `server.js` | (a) `app.use('/api/qr-events', require('./routes/qr-events'))`; (b) `endpoints` actualizado para incluir `/api/qr-events` en la respuesta raíz; (c) tabla `qr_event_counters` añadida al bloque `CREATE TABLE IF NOT EXISTS` de la auto-migración `AUTO_MIGRATE=true` (idempotente, sin alterar tablas existentes). |

### Archivos NO modificados (preservados / protegidos)

- `discovery/`, `PROYECTO.md`, `context/SPECs/SPEC-20260907-01-…`, `context/decisions/ADR-20260907-01-…`, `context/CURRENT.md` — no se tocaron.
- `index.html` y `admin.html` **no** se sincronizaron vía `cp`: cada edición fue `Edit` selectivo. Diff entre ambos archivos muestra únicamente las diferencias legítimas (script `autoOpenAdmin` propio de `admin.html`).
- `package.json`, `package-lock.json` — sin cambios. Sin dependencias nuevas.

## Contratos

| Contrato | Tipo | Cambio |
|---|---|---|
| `POST /api/qr-events` | API nuevo, público | Body `{event: 'visit' \| 'whatsapp_open'}` → `202 {ok:true}` o `400 {error:'Evento inválido'}`. |
| `GET /api/qr-events/summary` | API nuevo, admin only | `200 {visit:int, whatsapp_open:int}` con ceros por defecto; `401` sin token; `403` con rol staff. |
| `qr_event_counters` | Esquema nuevo, tabla agregada | Sólo totales. Sin IP, UA, PII ni identificadores. |
| `/citas`, `/citas/` | Rewrite nuevo en Vercel | Resuelve a `citas.html` antes del catch-all. |
| `/admin`, `/admin.html`, `autoOpenAdmin`, login, roles, CSP, otros WhatsApp, dashboard ventas | **Protegidos** | Sin cambios. |

## Validación

### V1 — dirigida por corte (PASS completo)

- **`node --check` en backend**: `routes/qr-events.js`, `server.js`, `db/migrate.js` → 0 errores. Comando exacto:
  - `node --check /home/frank/repos/detailinghouse-api/routes/qr-events.js && node --check /home/frank/repos/detailinghouse-api/server.js && node --check /home/frank/repos/detailinghouse-api/db/migrate.js`
- **JSON parse de `vercel.json`** + listado de rewrites: orden correcto (`/api/…`, `/admin`, `/admin/`, `/citas`, `/citas/`, `/(.*)`). Comando: `node -e "JSON.parse(require('fs').readFileSync('…/vercel.json','utf8'))"`.
- **Script inline de `citas.html`**: extraído y `node --check` → 0 errores.
- **Prueba API dirigida** (mock de pool + middleware/auth, sin secretos ni DB) — 7/7 PASS:
  1. `POST /api/qr-events {event:'visit'}` → `202 {ok:true}` y `pool.query` llamado con `INSERT … ON CONFLICT … DO UPDATE` y `params[0]='visit'`.
  2. `POST {event:'foo'}` → `400`.
  3. `POST {}` → `400`.
  4. `GET /summary` sin token → `401`.
  5. `GET /summary` con token `Bearer staff` → `403`.
  6. `GET /summary` con token `Bearer admin` → `200 {visit:7, whatsapp_open:3}`.
  7. `GET /summary` admin con tabla vacía → `200 {visit:0, whatsapp_open:0}`.

### V2 — completa una sola vez al cierre (PASS)

- **Smoke E2E backend con `server.js` montado** (puerto efímero, `DATABASE_URL` inválido a propósito, sin secretos):
  - `GET /` → `endpoints` contiene `'/api/qr-events'`.
  - `POST /api/qr-events {event:'foo'}` → `400 {"error":"Evento inválido"}`.
  - `GET /api/qr-events/summary` sin token → `401`.
- **Smoke frontend con jsdom** sobre `citas.html` (fetch instrumentado vía `beforeParse`):
  - Botón y link de fallback quedan con `href=https://wa.me/524461153815?text=…` desde el primer render.
  - Mensaje `text=` decodificado coincide carácter a carácter con el de la SPEC.
  - `POST /api/qr-events` con `event=visit` se emite al cargar y usa `keepalive:true`.
  - `sessionStorage["visit"]` queda en `"1"` tras la carga inicial (guarda de idempotencia por pestaña).

### V3 — independiente

Queda para GEMINI tras despliegue autorizado. Estado actual del gate: **no hay entorno desplegado autorizado**, así que V3 permanece pendiente y la entrega queda en `READY_FOR_VERIFYING` (no en `DONE`).

## Trazabilidad contra los 10 criterios de la SPEC

| # | Criterio | Evidencia |
|---|---|---|
| 1 | `/citas` local sirve la nueva pantalla | `citas.html` creado + rewrites `/citas` y `/citas/` antes del catch-all en `vercel.json`. Smoke jsdom carga el título `DetailingHouse · Conectando con WhatsApp`. |
| 2 | Cuenta 3 s y botón funciona desde el primer render | `REDIRECT_DELAY_MS = 3000`; `TICK_INTERVAL_MS = 50`; `btn.setAttribute('href', whatsappUrl)` se ejecuta antes del primer render visual; jsdom confirma `href` correcto en el primer frame. |
| 3 | URL y mensaje exactos | jsdom decodifica `text=` y compara con la cadena de la SPEC: `Hola, escaneé el QR de DetailingHouse y quiero agendar un servicio. ¿Me ayudan con la disponibilidad?` — PASS. |
| 4 | ≤ 1 `visit` y 1 `whatsapp_open` por pestaña | `alreadyTracked(name)` + `markTracked(name)` en `sessionStorage`. Smoke confirma `sessionStorage["visit"]="1"` tras carga. |
| 5 | Fallo de red del contador no impide abrir WhatsApp | `trackEvent` envuelve `fetch().catch(()=>{})`; `openWhatsapp` solo cambia `window.location.href` con un `setTimeout(60 ms)`; el tracking es asíncrono y nunca lanza. |
| 6 | POST válido incrementa atómico; inválido → 400 | SQL `INSERT … ON CONFLICT (event) DO UPDATE SET total = total + 1, updated_at = NOW()`; allowlist `ALLOWED_EVENTS = ['visit','whatsapp_open']`. Pruebas V1 #1, #2, #3. |
| 7 | GET: 401 sin token, 403 staff, 200 admin con enteros | Pruebas V1 #4, #5, #6, #7. Smoke V2 confirma 401 real sobre `server.js`. |
| 8 | Dashboard muestra ambos totales sin alterar KPIs de ventas | `index.html` y `admin.html`: los `<article class="kpi">` de `dashSalesToday/dashNetToday/dashClientsToday/dashAvgTicket` permanecen; se añaden `dashQrVisits` y `dashQrWhatsapp`. Diff visual: 2 nuevas tarjetas. |
| 9 | `/admin` conserva sidebar, contenido y `autoOpenAdmin` | Diff entre `index.html` y `admin.html` muestra el bloque `<script>function autoOpenAdmin(){…}</script>` intacto al final de `admin.html` (FIX-21, commit 5357f62). No se tocó `autoOpenAdmin`, `adminOverlay`, `renderPublicProducts/Services`, ni el sidebar. |
| 10 | Sin errores de consola ni requests fallidos no controlados | `trackEvent` silencia errores de red intencionadamente; `renderQrCounters` captura y `console.warn` sin propagar. CSP existente permite `connect-src` al backend Railway; `script-src 'self' 'unsafe-inline'` permite el script inline de `citas.html`. Sin nuevos assets externos. |

## Riesgos y desviaciones

- **Riesgo medio declarado en SPEC:** API pública + migración aditiva. Mitigado por: (a) `CHECK` en la tabla limita `event` a 2 valores; (b) rate-limit global `/api/` de 200 req/min existente en `server.js`; (c) GET protegido por JWT + rol admin; (d) sin almacenamiento de datos personales; (e) tabla agregada creada con `CREATE TABLE IF NOT EXISTS` (idempotente).
- **Tracking y WhatsApp desacoplados:** el `keepalive:true` + `setTimeout(60 ms)` previo a `location.href` envía el POST incluso si la página se descarga inmediatamente.
- **No se modificó ningún archivo Discovery/SPEC/ADR/PROYECTO/CURRENT.** Los `git status` previos a este cambio (capturados al inicio de la sesión) ya listaban `PROYECTO.md`, `SPEC-FRONTEND-007` y `ADR-20260711-03` modificados; esos cambios preexistían y no fueron tocados por SOFIA.
- **Cero dependencias nuevas** (`package.json` y `package-lock.json` sin diff).
- **No se clonó nada que ya estuviera disponible**: el repo `detailinghouse-api` no existía en `/home/frank/repos/`; se clonó vía HTTPS en `2>&1` (modo sólo-lectura local para implementación, sin push).
- **Limitación técnica:** `node_modules/` del backend no existía y se instaló con `npm install --prefer-offline` para poder ejecutar las pruebas V1/V2. Esto no se commitea (sólo runtime local; `package-lock.json` no fue tocado).

## Gates pendientes

- **GEMINI V3 (Playwright):** obligatorio antes de producción por contrato público + migración aditiva + despliegue web. ATLAS debe programar la sesión independiente una vez autorizado el deploy.
- **Autorización humana explícita** para: commit, push, PR, deploy, migración en producción, ejecución del `npm install`/`migrate.js` en producción.

## Reversión (recomendación, NO ejecución)

- Backend: retirar `app.use('/api/qr-events', …)`, eliminar `routes/qr-events.js`, eliminar las dos inserciones de `qr_event_counters`. La tabla puede conservarse (no afecta a otros módulos) o eliminarse sólo con acción destructiva separada.
- Frontend: eliminar `citas.html`, retirar los dos rewrites de `vercel.json`, revertir las dos tarjetas KPI y el método `getQrSummary`/`renderQrCounters` en `index.html` y `admin.html`.

## Estado final

`READY_FOR_VERIFYING` — la verificación contractual (descubrimiento→SPEC→criterios→código→V1/V2) cierra el ciclo del incremento. Quedan pendientes los gates de ATLAS (autorización de push, gate GEMINI V3 y, si aplica, DEBY si se observa un bug reproducible en runtime tras despliegue). Ninguna acción destructiva fue ejecutada.

## Delta — `IMPLEMENTATION_DEFECT` resueltos en `citas.html`

ATLAS clasificó dos defectos internos reversibles dentro de la misma SPEC; ambos se corrigieron en `citas.html` sin nuevo diseño ni cambios documentales canónicos. Sin diff en backend, `vercel.json` ni los dashboards.

### Defecto 1 — Fallback en memoria ausente para `sessionStorage`

**Síntoma:** el comentario `/* sin storage, sólo evitamos en memoria */` describía una guarda que no existía. Si `sessionStorage.getItem/setItem` lanzaban (modo privado, cuota llena, `SecurityError`) o `sessionStorage` era `undefined`, `alreadyTracked()` devolvía `false` y `markTracked()` no persistía nada ⇒ la misma pestaña podía reemitir `visit` o `whatsapp_open`.

**Fix:** combinación de dos planos en `trackEvent`/`alreadyTracked`/`markTracked`:
- `memTracked = Object.create(null)` — Map en memoria que siempre funciona.
- `ssAvailable` — probe en arranque (`setItem`/`removeItem` con try/catch); si falla, sólo se usa el plano en memoria.
- `alreadyTracked(name)` consulta `memTracked[name]` antes que `sessionStorage`.
- `markTracked(name)` escribe primero en `memTracked` y sólo después en `sessionStorage` si está disponible.

### Defecto 2 — Temporizador activo tras click manual y sin guarda de navegación

**Síntoma:** `openWhatsapp()` podía ejecutarse dos veces en una misma carga: una por el click manual del usuario y otra por el disparo automático del intervalo a los 3 s. La duplicación provocaba dos POST `whatsapp_open` y dos intentos de `window.location.href = whatsappUrl`.

**Fix:**
- Variable `navigated` (closure) — guarda de entrada de `openWhatsapp()`: si ya se navegó, retorna sin hacer nada.
- `clearInterval(tick)` al entrar a `openWhatsapp()` cuando el usuario hace click manual, de modo que el auto-redirect ya no se programa (defensivo, porque la guarda `navigated` también lo impediría).
- `tick` se inicializa como `null` y se reasigna tras `setInterval`, lo que permite a `openWhatsapp()` cancelarlo incluso si se llama antes del primer tick.

### Validación del delta — V1 focal ampliada (12/12 PASS)

Referencia evidencia previa (V1+V2 completas del incremento original): sin cambios en backend, `vercel.json`, ni dashboards; toda la verificación anterior sigue válida.

V1 focal nueva (12 casos), ejecutada con jsdom + `fetch` instrumentado vía `beforeParse` y `setTimeout/setInterval` reales:

| # | Escenario | Esperado | Resultado |
|---|---|---|---|
| A1 | `sessionStorage.setItem/getItem` lanzan → 1ª carga | `visit` se emite 1 vez | PASS |
| B1 | `sessionStorage === undefined` → 1ª carga | `visit` se emite 1 vez | PASS |
| B2 | storage=undefined + triple click | `whatsapp_open` se emite 1 sola vez | PASS |
| C1 | click manual a t≈150 ms | `whatsapp_open` se emite 1 vez | PASS |
| C2 | tras click manual, esperar >3 s | `countText` no cambia (intervalo cancelado) | PASS |
| C3 | tras click manual, esperar >3 s | no se re-emite `whatsapp_open` | PASS |
| D1 | doble `dispatchEvent('click')` consecutivos | 1 sólo `whatsapp_open` | PASS |
| E1 | auto-redirect sin click | 1 `visit` | PASS |
| E2 | auto-redirect sin click | 1 `whatsapp_open` | PASS |
| F1 | storage OK → 1ª carga | 1 `visit` | PASS |
| F2 | storage OK → 1ª carga | `sessionStorage["visit"] === "1"` | PASS |
| G1 | storage OK + doble click | 1 `visit` | PASS |
| G2 | storage OK + doble click | 1 `whatsapp_open` | PASS |

Comandos:
- `node --check` sobre el `<script>` extraído de `citas.html` → 0 errores.
- `node /tmp/kilo/citas-defects.test.js` (copiado temporalmente a `_citas-defects.test.js` dentro del backend para resolver `jsdom` desde `node_modules`) → 12/12 PASS.

V2 completa no se repite (no hay diff en backend ni en rewrites ni en dashboards); la única superficie modificada por el delta es `citas.html`, ya cubierta por V1 focal.

### Trazabilidad adicional contra los criterios de la SPEC tras el delta

- **Criterio 4** (≤ 1 `visit` y 1 `whatsapp_open` por pestaña): ahora garantizado incluso sin `sessionStorage`. Antes dependía de un fallback inexistente.
- **Criterio 5** (fallo de red no impide WhatsApp): sin cambios; los POST son asíncronos y la guarda de navegación no toca el flujo `fetch().catch(...)`.
- **Criterio 10** (sin requests fallidos no controlados): el delta no añade errores de consola. `clearInterval` y la guarda `navigated` viven dentro del IIFE y no exponen nada al exterior.

### Estado final tras el delta

`READY_FOR_VERIFYING` — sin cambios respecto al estado anterior del incremento. La verificación contractual del delta es interna (V1 focal) y la global (V2+V3) sigue vigente. Sin commit, push, deploy ni migración en producción.
