# SPEC-FRONTEND-002 — Gate de payroll por rol (FIX-20260710-17)

**ID:** ARCH-20260710-17
**Origen:** Smoke E2E panel admin 2026-07-10 21:56 UTC. Login `DH-STAFF` → consola muestra 403 en `/api/cash/payroll?range=weekly`.
**Autor:** INTEGRA
**Estado:** Planificado
**Stack:** HTML/JS vanilla (index.html), IIFE sección "13. Auth + tabs"

---

## 1. Contexto

`renderPayroll()` (L4646) llama a `api.getPayroll(range)` cuando hay sesión. La guarda actual es solo `if (!apiToken)`. Pero:

- `api.login('staff', 'DH-STAFF')` setea `apiToken` correctamente.
- El backend Railway (otro workspace) configura permisos por rol y rechaza `/cash/payroll` con 403 si el rol no es admin.
- El frontend también oculta el tab `#tab-nomina` para staff via `syncRoleUI`, pero `renderPayroll` igual se dispara al cargar (probablemente desde un bind delegado o un evento residual).
- Resultado: 403 en consola cada vez que un staff abre el panel.

## 2. Síntoma observable

- Usuario: `DH-STAFF` → login OK → 3 tabs visibles (pos, clientes, agenda) ✅
- Consola: `[ERROR] Failed to load resource: 403 (/api/cash/payroll?range=weekly)`
- UX: el tab nómina está oculto para staff, así que el 403 no bloquea ninguna función visible. Pero ensucia la consola y genera "ruido" para detectar errores reales.

## 3. Causa raíz

`renderPayroll()` L4661:

```js
if (!apiToken) {
  renderWithBase(getRangeSales(range).reduce(...));
  return;
}
// Con sesión: intentar server primero
api.getPayroll(range).then(...).catch(...);
```

Falta la verificación de rol. El check correcto es: **solo llamar a la API si el rol es admin**.

## 4. Solución

### 4.1 Cambio mínimo (recomendado)

Reemplazar la guarda L4661 por:

```js
if (!apiToken || state.role !== ROLES.ADMIN) {
  renderWithBase(getRangeSales(range).reduce((sum, sale) => sum + sale.total, 0));
  return;
}
```

**Cambio total:** 1 línea.

### 4.2 Verificación adicional (defensa en profundidad)

Auditar si otros `render*` similares (`renderDashboard`, `renderInventory`, etc.) tienen el mismo patrón. Si lo tienen, aplicar el mismo gate.

## 5. Criterios de aceptación

- [ ] CA-1: Login `DH-STAFF` → 0 calls a `/api/cash/payroll` en network tab.
- [ ] CA-2: Consola tras login staff limpia del 403 de payroll (los 401 de `/auth/me` previos al login siguen siendo esperados).
- [ ] CA-3: Login `DH2025` (admin) sigue llamando a `/api/cash/payroll` con 200 OK.
- [ ] CA-4: El render visual de Nómina para admin no cambia.

## 6. Validaciones

1. `pnpm typecheck` (N/A — proyecto no usa TS)
2. Smoke E2E Playwright:
   - Login admin DH2025 → 7 tabs visibles → 1 call a `/cash/payroll` (200) → consola sin 403.
   - Logout → login staff DH-STAFF → 3 tabs visibles → 0 calls a `/cash/payroll` → consola sin 403.
3. Self-review manual:
   - ¿El código refleja la SPEC? Sí.
   - ¿Code smells? No.
   - ¿Regresión? No — el render local de fallback ya existía para `!apiToken`.
4. Invocar a GEMINI como segunda mano de validación (Qodo está sunset).

## 7. Riesgos

- **Riesgo bajo:** si el backend cambia los permisos de payroll, la guarda puede quedar obsoleta. Mitigación: leer `ROLE_PERMISSIONS` centralizado (cumple ADR-03).
- **Riesgo muy bajo:** alguien quiere ver nómina como staff. No es el caso — el tab está oculto, así que la UI no muestra nada. Si en el futuro staff necesita ver "su propio corte", eso requiere feature nueva + cambio de backend.

## 8. Out-of-scope

- Cambiar permisos del backend Railway (no tenemos acceso a ese workspace).
- Mostrar info de nómina a staff (sería feature nueva).
- Re-factor de `renderPayroll` (no es necesario, solo el gate).
