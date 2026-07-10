# INT-20260710-01 — Handoff a SOFIA: Deduplicación de scripts

**De:** INTEGRA
**Para:** SOFIA (`subagent_type='sofia'`)
**Fecha:** 2026-07-10
**Sprint:** `FIX-20260710-01`
**SPEC:** [`context/SPECs/SPEC-FRONTEND-001-script-deduplication.md`](../SPECs/SPEC-FRONTEND-001-script-deduplication.md)
**Estado:** Pendiente OK del humano para ejecutar

---

## 🎯 Objetivo

Fusionar los 2 bloques `<script>` paralelos de `index.html` en uno solo, eliminar las 10 funciones duplicadas, los 6 métodos `api.*` muertos y el DOM huérfano `cartItems`. Sin cambios funcionales. Cero regresiones.

## 📦 Alcance

- **Único archivo a tocar:** `index.html`
- **Líneas aproximadas actuales:** 5,333
- **Líneas objetivo:** ≤ 4,250 (reducción ≥ 20%)
- **Out of scope:** tests, CSP, features nuevas, migración a framework

## 📚 Contexto que necesitás

1. Lee la SPEC completa: `context/SPECs/SPEC-FRONTEND-001-script-deduplication.md`
2. Lee el ADR de roles: `context/decisions/ADR-20260710-03-roles-magic-strings.md` (criterio CA-5)
3. Lee el ADR de catálogo: `context/decisions/ADR-20260710-04-catalog-hardcoded-fallback.md` (criterio CA-6)
4. Inspecciona `index.html` para confirmar las 10 funciones duplicadas (§2 de la SPEC) y los 6 métodos `api.*` muertos (§3.1 de la SPEC).

## 🛠️ Orden de ejecución sugerido

1. **Backup de seguridad:**
   ```bash
   cp index.html index.html.bak-pre-fix-20260710
   ```

2. **Construir el nuevo `<script>` unificado** siguiendo la estructura de §5.1 de la SPEC.

3. **Diff visual** entre el backup y el nuevo:
   ```bash
   diff -u index.html.bak-pre-fix-20260710 index.html | less
   ```

4. **Smoke test público sin red:**
   ```bash
   python3 -m http.server 8080
   # Chrome DevTools → Network → Offline
   # Verificar: hero, 8 servicios, 30 productos, FAQ, footer
   ```

5. **Smoke test público con red:**
   - Misma sesión, recargar. Verificar carga desde API.

6. **Smoke test admin:**
   - Login con `DH2025` → 7 tabs visibles
   - POS: agregar 1 servicio + 1 producto al carrito → cobrar efectivo
   - Inventario: stock del producto vendido bajó
   - Dashboard: KPI Ventas hoy ≥ 1
   - Logout → login con `DH-STAFF` → 3 tabs visibles (POS, Clientes, Agenda)

7. **Verificación de los 12 criterios de aceptación** (CA-1 a CA-12 de la SPEC §6).

## ✅ Entregables del handoff

- [ ] `index.html` modificado (1 solo `<script>` principal)
- [ ] `index.html.bak-pre-fix-20260710` (backup, no commitear)
- [ ] Reporte de líneas: `wc -l index.html` antes y después
- [ ] Output de los greps de verificación de CA-1 a CA-12
- [ ] Captura o descripción del smoke test E2E
- [ ] Lista de cualquier desviación respecto a la SPEC

## ⚠️ Restricciones

- **No commitear, no pushear, no abrir PR.** Esperá OK del humano.
- **No modifiques otros archivos** fuera de `index.html`.
- **No cambies precios, copy público, ni estructura HTML/CSS.** Solo el `<script>` interno y la eliminación del DOM huérfano.
- **No elimines `OFFLINE_CATALOG_FALLBACK` (ex-`baseCatalog`)**; renombrarlo con JSDoc `@deprecated` (CA-6).

## 🔍 Validaciones obligatorias antes de cerrar

1. `wc -l index.html` → ≤ 4,250 líneas
2. `grep -c '<script>' index.html` → 1 (script principal; el bloque de config CSS-style inline cuenta aparte, aceptá 2 si es `<style>` y `<script>` con config no-CSS)
3. `grep -E 'function (finalPrice|formatCurrency|getOfflineInventoryFallback|mapInventory|renderInventory|renderPosCatalog|handleRegisterSale|renderCart|currentTotals)' index.html` → 1 ocurrencia por nombre
4. `grep -E 'api\.(updatePrice|patchProduct|updateClient|addPoints|getDashboard|getPayroll)' index.html` → 0
5. `grep 'id="cartItems"' index.html` → 0
6. `grep -E 'const (ROLES|ROLE_PERMISSIONS|OFFLINE_CATALOG_FALLBACK)' index.html` → ≥ 1 cada una
7. Carga manual `index.html` en navegador → 0 errores en console

**No ejecutes `qodo` (está sunset).** En su lugar, incluye en el reporte final un **self-review manual**:

- ¿El código refleja la SPEC al pie de la letra?
- ¿Hay code smells evidentes (mutaciones de `cart` desde 2 lados, race conditions en `loadState`)?
- ¿Los criterios CA-1 a CA-12 se cumplen todos?
- ¿Algún riesgo de regresión que detectes?
- ¿Quedó alguna referencia muerta a `state.cart` o a las funciones eliminadas?

## 🤝 Al cerrar

1. Reportá con el formato estándar INTEGRA (archivos tocados, resultado de greps, smoke test, riesgos).
2. **Sugerí** que INTEGRA invoque a **GEMINI** (`subagent_type='gemini'`) como segunda mano de validación antes de marcar la implementación como lista para commit.
3. Generá el checkpoint `context/checkpoints/CHK_2026-07-10_HHMM_fix-dedup.md` con el resultado.

---

**Aprobado por:** INTEGRA
**Pendiente:** OK del humano para invocar `task` con `subagent_type='sofia'`.
