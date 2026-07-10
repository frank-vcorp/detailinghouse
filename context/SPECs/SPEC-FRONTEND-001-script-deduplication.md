# SPEC-FRONTEND-001 — Deduplicación de scripts + eliminación de código muerto

**ID:** `FIX-20260710-01`
**Tipo:** Remediación técnica (no funcional)
**Prioridad:** Alta
**Estimación:** 2-3 horas
**Sprint:** Micro-Sprint INTEGRA 2026-07-10
**Origen:** Auditoría `ARCH-20260710-01`

---

## 1. Contexto

La auditoría `ARCH-20260710-01` detectó que `index.html` contiene **dos bloques `<script>` paralelos** (`L3876-4628` y `L4629-5329`) con código duplicado resultado de olas de refactor incompletas entre v3.0 y v4.0. Además, **5 métodos del cliente `api.*` están declarados pero nunca invocados**, lo que sugiere funcionalidad planeada que nunca se cableó o que se silenció.

Esta duplicación es la **principal deuda técnica** del proyecto y debe atacarse antes de añadir features nuevos.

## 2. Estado actual (duplicaciones detectadas)

| # | Función script 1 (líneas) | Función script 2 (líneas) | Notas |
|---|---|---|---|
| 1 | `finalPrice(base)` (L3987) | `fp(base)` (L4651) | Idénticas |
| 2 | `formatCurrency(value)` (L3989) | `money(value)` (L4652) | Idénticas |
| 3 | `syncInventory()` (L3997) | `mapInventory(inv)` (L4698) | Roles distintos (fallback vs mapper) |
| 4 | `renderInventory()` (L4360) | `renderInventory()` (L4891) | Distinta implementación |
| 5 | `renderPosCatalog()` (L4260) | `renderPosCatalog()` (L4833) | Distinta implementación |
| 6 | `registerSale()` (L4432) | `registerSaleV2()` (L5052) | La v1 nunca se llama |
| 7 | `renderCart()` (L4086) | `renderCart()` (L4856) | Distinta implementación |
| 8 | `getTotals()` (L4079) | `currentTotals()` (L4849) | Idéntica lógica |
| 9 | `serviceCatalog` (L3973) | Re-importada por closure | OK (mismo array compartido) |
| 10 | `let inventory = syncInventory()` (L4001) | `state.inventory` (L4633) | Doble fuente de verdad |

## 3. Código muerto detectado

### 3.1 Métodos `api.*` declarados nunca invocados

| Método | Línea | Endpoint |
|---|---|---|
| `api.updatePrice` | L3912 | `PUT /inventory/:sku/price` |
| `api.patchProduct` | L3913 | `PATCH /inventory/:sku` |
| `api.updateClient` | L3918 | `PUT /clients/:id` |
| `api.addPoints` | L3919 | `POST /clients/:id/points` |
| `api.getDashboard` | L3922 | `GET /sales/dashboard` |
| `api.getPayroll` | L3934 | `GET /cash/payroll?range=...` |

### 3.2 DOM huérfano

- `<div id="cartItems" class="pos-old-sidecart" aria-hidden="true">` (L3671) — re-cloneado en `bindAdminInteractions()` (L5156).
- Listener `cartItems` referenciado en el CHANGELOG v4.0 como "legacy silenciado" — sigue vivo en el código.

### 3.3 Console.warns silenciosos

3 `console.warn` que notifican errores al desarrollador pero **no al usuario** (L3896, L4716, L4753). Si la API muere, la UI pública sirve `baseCatalog` sin avisar al cliente que el precio puede estar desactualizado.

## 4. Alcance del sprint

### 4.1 In-scope

- **Fusionar los 2 bloques `<script>` en uno solo**, ejecutado como IIFE o top-level, conservando el orden: API client → constantes → SOT state → render → bind → init.
- **Eliminar las funciones duplicadas** listadas en §2. Mantener **una sola versión** de cada una.
- **Eliminar el DOM huérfano `cartItems`** y sus handlers asociados.
- **Eliminar los métodos `api.*` muertos** listados en §3.1 (o documentarlos explícitamente como "disponibles para futuro uso" con JSDoc `@deprecated`).
- **Reemplazar 1 de los 2 set de variables globales** (`inventory`, `sales`, `cart` en script 1) por el `state` del script 2.
- **Unificar el patrón de precio** (`fp`/`finalPrice` → un solo `applyPriceFinal` o `finalPrice`).
- **Unificar el patrón de moneda** (`money`/`formatCurrency` → un solo `formatCurrency`).
- **Centralizar roles** en una constante `ROLES` y `ROLE_PERMISSIONS` (cumple ADR-20260710-03 §4 paso 1).
- **Renombrar `baseCatalog` → `OFFLINE_CATALOG_FALLBACK`** con JSDoc (cumple ADR-20260710-04 §4 paso 1).
- **Convertir 1 console.warn en toast** para el caso de fallback de inventario público (cumple §3.3).

### 4.2 Out-of-scope (queda para sprints futuros)

- Implementar los endpoints muertos como features nuevas.
- Migrar a React/Astro (no es trigger todavía, ver ADR-01).
- Añadir tests automatizados (backlog `FIX-20260710-02`).
- Añadir CSP.
- Reemplazar el QR SVG decorativo por uno real (backlog `FEAT-20260710-NN`).

## 5. Diseño de la fusión

### 5.1 Estructura final del `<script>` único

```js
(() => {
  // ── 1. Constantes globales ──
  const WHATSAPP_BASE = 'https://wa.me/524461153815';
  const API_BASE = '...';
  const TERMINAL_RATE = 1.036;
  const IVA_RATE = 1.16;

  // ── 2. Catálogo fallback (ADR-04) ──
  /** @deprecated Solo fallback offline-first. NO es SOT. Ver ADR-20260710-04. */
  const OFFLINE_CATALOG_FALLBACK = [ /* 30 productos */ ];

  // ── 3. Catálogo de servicios (constante, no DB) ──
  const SERVICE_CATALOG = [ /* 8 servicios */ ];

  // ── 4. API client ──
  let apiToken = null;
  let apiUser = null;
  const api = { /* solo métodos usados */ };

  // ── 5. Estado único (SOT) ──
  const state = {
    inventory: [], sales: [], clients: [], appointments: [],
    cashSessions: [], payrollCuts: [],
    cart: [],
    role: '', currentMonth: new Date(...),
    selectedClientId: '', lastSale: null,
    payrollCfg: { Andres: 35, Erika: 35, Local: 30 }
  };

  // ── 6. Roles y permisos (ADR-03) ──
  const ROLES = { ADMIN: 'admin', STAFF: 'staff' };
  const ROLE_PERMISSIONS = {
    [ROLES.ADMIN]:  ['pos', 'inventario', 'caja', 'clientes', 'nomina', 'agenda', 'dashboard'],
    [ROLES.STAFF]:  ['pos', 'clientes', 'agenda']
  };

  // ── 7. Helpers puros ──
  const finalPrice = base => Math.round(Number(base) * TERMINAL_RATE * IVA_RATE);
  const formatCurrency = value => new Intl.NumberFormat('es-MX', {...}).format(value || 0);
  const todayKey = (date = new Date()) => new Date(date).toISOString().slice(0, 10);
  const isToday = ts => todayKey(ts) === todayKey();
  const uid = prefix => `${prefix}-${Math.random().toString(36).slice(2, 9)}`;

  // ── 8. Capa de datos ──
  async function loadPublicInventory() { ... }
  async function loadPrivateData() { ... }
  async function loadActiveCash() { ... }

  // ── 9. Render público ──
  function renderPublicCatalog() { ... }
  function bindPublicInteractions() { ... }

  // ── 10. UI admin helpers ──
  window.dhAdminToast = function(...) { ... };
  window.dhAdminModal = function(...) { ... };

  // ── 11. Render admin ──
  function renderPosCatalog() { ... }
  function renderCart() { ... }
  function renderInventory() { ... }
  function renderClients() { ... }
  function renderPayroll() { ... }
  function renderAgenda() { ... }
  function renderDashboard() { ... }
  function drawChart() { ... }
  function exportCsv() { ... }

  // ── 12. Handlers admin ──
  function handleRegisterSale() { ... }
  function handleAddClient() { ... }
  function handleAddProduct() { ... }
  function handleOpenCash() { ... }
  function handleCloseCash() { ... }
  function handleAddExpense() { ... }
  function handleGenerateCut() { ... }
  function handleSaveAppt() { ... }
  function handleUpdateAppt() { ... }

  // ── 13. Auth + tabs ──
  async function handleLogin() { ... }
  function handleLogout() { ... }
  function syncRoleUI() { ... }
  function activateTab(tab) { ... }

  // ── 14. Init ──
  async function init() { ... }
  init();
})();
```

### 5.2 Criterios para elegir qué versión conservar

| Función | Versión a conservar | Justificación |
|---|---|---|
| `finalPrice` / `fp` | Unificar como `finalPrice` (nombre más legible) | Ambas idénticas |
| `formatCurrency` / `money` | `formatCurrency` (consistente con JSDoc estándar) | Ambas idénticas |
| `syncInventory` | Renombrar a `getOfflineInventoryFallback` | Solo se usa como fallback |
| `mapInventory` | Conservar como `mapInventory` (mapper real de API) | Necesario |
| `renderInventory` | Versión script 2 (L4891) | Lee de `state.inventory` que es la SOT real |
| `renderPosCatalog` | Versión script 2 (L4833) | Tiene búsqueda + chips, es la funcional |
| `registerSale` | Versión `registerSaleV2` (L5052) | La que llama a `api.registerSale` |
| `renderCart` | Versión script 2 (L4856) | Usa `state.cart` (SOT) |
| `getTotals` / `currentTotals` | Unificar como `currentTotals` | Idéntica lógica |

## 6. Criterios de aceptación

| ID | Criterio | Verificación |
|---|---|---|
| CA-1 | Un solo bloque `<script>` (no dos) en `index.html` | `grep -c '<script>' index.html` retorna 1 (excluyendo config) |
| CA-2 | Las 10 funciones duplicadas de §2 ya no existen por duplicado | `grep -E 'function (finalPrice\|formatCurrency\|syncInventory\|mapInventory\|renderInventory\|renderPosCatalog\|registerSale\|renderCart\|getTotals\|currentTotals)' index.html` retorna 1 ocurrencia por nombre (o 0 si la renombramos) |
| CA-3 | Los 6 métodos `api.*` muertos ya no existen en el código | `grep -E 'api\.(updatePrice\|patchProduct\|updateClient\|addPoints\|getDashboard\|getPayroll)' index.html` retorna 0 |
| CA-4 | El DOM huérfano `cartItems` ya no existe | `grep 'id="cartItems"' index.html` retorna 0 |
| CA-5 | Constante `ROLES` y `ROLE_PERMISSIONS` existen al top del script | `grep -E 'const (ROLES\|ROLE_PERMISSIONS)' index.html` retorna ≥1 |
| CA-6 | Constante `OFFLINE_CATALOG_FALLBACK` con JSDoc `@deprecated` | `grep -E 'OFFLINE_CATALOG_FALLBACK' index.html` retorna ≥1 con JSDoc |
| CA-7 | La página pública sigue renderizando 30 productos sin API | Cortar internet local, abrir `index.html` por `file://` o servidor local → debe mostrar 30 productos |
| CA-8 | El panel admin sigue funcionando: login → POS → 1 venta → inventario actualizado → dashboard refleja la venta | Flujo manual end-to-end con backend activo |
| CA-9 | Reducción de líneas de código ≥ 20% | `wc -l index.html` antes y después; documentar en checkpoint |
| CA-10 | Sin nuevos `console.error` o warnings en consola al cargar la página | DevTools console limpia |
| CA-11 | El sitio sigue siendo servible por `python3 -m http.server` y por Netlify | Smoke test en ambos |
| CA-12 | `git diff` muestra solo cambios en `index.html` (sin nuevos archivos) | Inspección de `git status` |

## 7. Plan de pruebas manual (no automatizadas)

1. **Build OK:** `cd detailinghouse && echo "build"` (no hay build real).
2. **Servir local:** `python3 -m http.server 8080`.
3. **Smoke público (sin red):**
   - `chrome://flags` → activar offline después de cargar.
   - Verificar hero, 8 servicios, 30 productos, FAQ, footer.
4. **Smoke público (con red):**
   - Recargar con red. Verificar que la API responde y stock/precios cargados desde DB.
5. **Smoke admin (login admin):**
   - Login con `DH2025`. Verificar 7 tabs visibles.
   - POS: agregar 1 servicio + 1 producto al carrito. Cobrar con efectivo.
   - Verificar mensaje "Venta registrada en la base de datos ✅".
   - Inventario: stock del producto vendido debe haber bajado.
   - Dashboard: KPI "Ventas hoy" debe ser ≥1, "Utilidad neta" > 0.
6. **Smoke admin (login staff):**
   - Login con `DH-STAFF`. Verificar que solo POS, Clientes, Agenda son visibles.
7. **Verificación grep** de los 12 criterios.

## 8. Riesgos

| Riesgo | Mitigación |
|---|---|
| Romper flujo público al fusionar | Conservar versión de script 1 para funciones públicas; verificar render manual |
| Romper flujo admin al fusionar | Conservar versión de script 2 para admin; verificar login + 1 venta E2E |
| Pérdida de feature que parecía muerto pero se usaba | Antes de eliminar, hacer `grep` agresivo del nombre en todo el repo |
| `state` referencia `cart` antes de que script 1 lo defina | Usar IIFE con hoisting de `const state` al top del bloque fusionado |
| Cambios en precio al unificar `finalPrice` vs `fp` | Confirmar que `TERMINAL_RATE` y `IVA_RATE` son idénticas en ambos (verificado L3985-3986 vs L4649-4650) |
| El cambio rompe el caché de Netlify | Forzar purge en Netlify dashboard después del deploy |

## 9. Orden de ejecución sugerido para SOFIA

1. **Backup:** `cp index.html index.html.bak-pre-fix-20260710`
2. **Extraer funciones duplicadas** a un mapa de "qué conservar de cada script"
3. **Construir el nuevo `<script>` unificado** en un archivo temporal `index.html.new`
4. **Diff visual** entre `index.html.bak-pre-fix-20260710` y `index.html.new`
5. **Reemplazar atómicamente**: `mv index.html.new index.html`
6. **Smoke test público** (con y sin red)
7. **Smoke test admin** (login + venta E2E)
8. **Verificación de los 12 criterios de aceptación**
9. **Generar checkpoint** `context/checkpoints/CHK_2026-07-10_HHMM_fix-dedup.md`
10. **Sugerir revisión a GEMINI** como segunda mano

## 10. Salida esperada

- 1 commit: `fix(frontend): dedup scripts + dead code (FIX-20260710-01)`
- `index.html` reducido en ≥20% de líneas
- 0 funciones duplicadas
- 0 métodos `api.*` muertos
- 0 DOM huérfano
- 12/12 criterios de aceptación ✅
- 1 checkpoint de cierre

---

**Aprobado por:** INTEGRA (`ARCH-20260710-01` → `FIX-20260710-01`)
**Pendiente:** OK del humano para delegar a SOFIA.
