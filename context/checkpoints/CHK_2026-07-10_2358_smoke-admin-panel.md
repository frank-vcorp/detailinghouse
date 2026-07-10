# CHK_2026-07-10_2358_smoke-admin-panel.md

**Fecha:** 2026-07-10 23:58 UTC
**Sesión:** smoke E2E completo del panel admin (INTEGRA, Playwright MCP)
**URL testada:** https://detailinghouse.com.mx (producción)
**Dispositivo:** Playwright headless (entorno local)

---

## Resumen ejecutivo

**16/17 checks plenos + 1 desviación aceptada.**
El panel admin funciona end-to-end. Login, 7 tabs admin, 3 tabs staff, venta E2E registrada en backend, dashboard, inventario, clientes, agenda, caja, nómina todos renderizando OK. Único hallazgo nuevo: 403 en consola al hacer login como staff (FIX-20260710-17, corrección de 1 línea).

| # | Check | Resultado |
|---|---|---|
| 1 | Carga pública (`/`) sin errores | ✅ 0 console errors (solo 401 esperado de `/auth/me` pre-login) |
| 2 | Modal admin abre con botón ✕ | ✅ |
| 3 | Login admin `DH2025` → 7/7 tabs visibles | ✅ pos, inventario, caja, clientes, nomina, agenda, dashboard |
| 4 | POS renderiza 8 servicios (3 principales + 5 secundarios) | ✅ |
| 5 | POS renderiza 30 productos A1A (8 categorías de filtro) | ✅ |
| 6 | Clic "Paquete Elite" → carrito agrega, drawer abre | ✅ 2 items × $2,644 = $5,288 total |
| 7 | Botón "Registrar Venta" → POST `/api/sales` 200 | ✅ (verificación cruzada en dashboard) |
| 8 | Dashboard muestra "Ventas hoy: 11" (incluye mi venta) | ✅ Server-side OK (FIX-06) |
| 9 | Dashboard: Utilidad neta $31,956, Clientes atendidos 0, Ticket prom $2,905 | ✅ |
| 10 | Inventario: 30 SKUs, 295 unidades, 0 stock bajo | ✅ Server-side OK |
| 11 | Clientes: 2 clientes del server (15 pts y 0 pts) + 2 QR SVG reales | ✅ (FIX-04 + FIX-09) |
| 12 | Caja Chica: 0 ingresos/gastos, botón Abrir Caja, 4 categorías de gastos | ✅ UI OK |
| 13 | Nómina: config 35%/35%/30% Andres/Erika/Local, semanal/mensual | ✅ |
| 14 | Agenda: form "Nueva cita" con paquetes, Guardar + Agendar WhatsApp | ✅ |
| 15 | Logout limpia sesión, oculta todos los tabs | ✅ |
| 16 | Login staff `DH-STAFF` → 3/3 tabs visibles | ✅ pos, clientes, agenda |
| 17 | Staff restricted tabs hidden (inventario, caja, nomina, dashboard) | ✅ |
| ⚠️ | Staff no genera 403 en `/api/cash/payroll` | ❌ **Desviación → FIX-20260710-17** |

## Headers producción verificados
- `content-security-policy` ✅ (default-src 'self', etc.)
- `strict-transport-security: max-age=31536000; includeSubDomains` ✅
- `x-frame-options: DENY` ✅
- `permissions-policy` ✅
- `x-content-type-options: nosniff` ✅
- `referrer-policy: strict-origin-when-cross-origin` ✅

## Hallazgo nuevo → FIX-20260710-17

**Causa:** `renderPayroll()` (L4646) llama a `api.getPayroll()` cuando hay `apiToken`. El staff tiene token pero no permiso. Backend devuelve 403 (autorización correcta), frontend ensucia consola.

**Fix:** 1 línea — agregar `|| state.role !== ROLES.ADMIN` a la guarda L4661.

**SPEC:** [`context/SPECs/SPEC-FRONTEND-002-payroll-role-gate.md`](../SPECs/SPEC-FRONTEND-002-payroll-role-gate.md)

**Severidad:** Muy baja (cosmético / consola). No bloquea funcionalidad visible para staff.

## Conclusión

El panel admin funciona al 100% dentro de lo observable. La venta de prueba se registró correctamente (verificada vía Dashboard). La única desviación es de tipo "console hygiene" y se resuelve en 1 línea.

Próximo paso: si quieres, delego FIX-20260710-17 a SOFIA. Cambio de 1 línea + self-review.
