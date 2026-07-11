# CHK_2026-07-11_1805_deudas-tecnicas-corregidas.md

**Fecha:** 2026-07-11 18:05 UTC  
**Sesión:** Corrección de deudas técnicas pendientes  
**Implementado por:** SOFIA (delegación de INTEGRA)  
**Verificado por:** INTEGRA (Playwright E2E)

---

## Resumen

Se corrigieron las 2 deudas técnicas pendientes del sistema admin profesional:
1. ✅ Endpoint `/api/inventory/last-update` implementado en backend
2. ✅ Bug FIX-20260710-17 (payroll 403 para staff) corregido en frontend

---

## Deuda 1: Endpoint `/api/inventory/last-update`

### Problema
El frontend estaba haciendo polling cada 60 segundos a `/api/inventory/last-update` para detectar cambios en el inventario y recargar datos automáticamente (Fase 5 - cache invalidation). Sin embargo, este endpoint no existía en el backend, causando errores 404 en consola.

### Solución
Se implementó el endpoint en el backend (Railway):

**Archivo:** `/tmp/detailinghouse-api/routes/inventory.js`

```javascript
// GET /api/inventory/last-update — Timestamp de última actualización (público)
router.get('/last-update', async (req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT MAX(updated_at) as last_update FROM inventory'
    );
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
```

**Características:**
- Endpoint público (sin autenticación)
- Devuelve `{ last_update: timestamp }` o `{ last_update: null }` si no hay datos
- Se coloca antes del endpoint `/:sku` para evitar conflictos de rutas

**Commit:** `94ed704` en `frank-vcorp/detailinghouse-api`

### Verificación
```bash
curl https://detailinghouse-api-production.up.railway.app/api/inventory/last-update
# Respuesta: {"last_update":"2026-07-10T22:07:37.611Z"}
```

---

## Deuda 2: Bug FIX-20260710-17 (payroll 403 para staff)

### Problema
Cuando un usuario con rol `staff` iniciaba sesión, el frontend llamaba a `/api/cash/payroll?range=weekly` para obtener los cortes de nómina. Sin embargo, el backend rechaza esta petición con 403 porque el staff no tiene permiso para acceder a payroll. Esto causaba errores 403 en consola.

**Causa raíz:** La función `renderPayroll()` (línea 5185) verificaba si había `apiToken` antes de llamar a la API, pero no verificaba el rol del usuario. El staff tiene token pero no tiene permiso para payroll.

### Solución
Se agregó verificación de rol antes de llamar a la API:

**Archivo:** `/home/frank/repos/detailinghouse/index.html` (línea 5200)

**Antes:**
```javascript
// Sin sesión activa: usar local (evita 401 en consola)
if (!apiToken) {
  renderWithBase(getRangeSales(range).reduce((sum, sale) => sum + sale.total, 0));
  return;
}
```

**Después:**
```javascript
// Sin sesión activa o sin rol admin: usar local (evita 401/403 en consola)
if (!apiToken || state.role !== 'admin') {
  renderWithBase(getRangeSales(range).reduce((sum, sale) => sum + sale.total, 0));
  return;
}
```

**Comportamiento:**
- **Admin:** Llama a `/api/cash/payroll` y usa datos del servidor
- **Staff:** Usa cálculo local directamente (sin llamar a la API)
- **Sin sesión:** Usa cálculo local directamente

**Commit:** `c6d13f4` en `frank-vcorp/detailinghouse`

---

## Verificación con Playwright

### Test 1: Página pública sin sesión
- ✅ 0 errores en consola
- ✅ No hay errores 404 de `/api/inventory/last-update`
- ✅ Polling funciona correctamente (localStorage tiene timestamp)

### Test 2: Login como admin
- ✅ Login exitoso (roleBadge: "ADMIN")
- ✅ 0 errores en consola
- ✅ Navegación a Nómina funciona sin errores
- ✅ Endpoint `/api/cash/payroll` se llama correctamente (admin tiene permiso)

### Test 3: Login como staff
- ✅ Login exitoso (roleBadge: "STAFF")
- ✅ 0 errores en consola
- ✅ No hay errores 403 de `/api/cash/payroll`
- ✅ Staff usa cálculo local para nómina

### Test 4: Página pública después de login
- ✅ 0 errores en consola
- ✅ Cache invalidation funcionando (polling activo)

---

## Commits realizados

### Backend (Railway)
- **`94ed704`** - feat: agregar endpoint /api/inventory/last-update
  - Devuelve timestamp de última actualización del inventario
  - Endpoint público para polling de cache invalidation

### Frontend (Vercel)
- **`c6d13f4`** - fix: corregir bug FIX-20260710-17 (payroll 403 para staff)
  - Verificación de rol admin antes de llamar a /api/cash/payroll
  - Staff usa cálculo local directamente

---

## Estado final

### Deudas técnicas
- ✅ **Resueltas:** 2 de 2
- ⚠️ **Pendientes:** 0

### Errores en consola
- ✅ **Admin:** 0 errores
- ✅ **Staff:** 0 errores
- ✅ **Página pública:** 0 errores

### Funcionalidad
- ✅ Cache invalidation funcionando (polling cada 60s)
- ✅ Nómina funciona correctamente para admin (datos del servidor)
- ✅ Nómina funciona correctamente para staff (cálculo local)
- ✅ Sin errores 404 ni 403 en consola

---

## Deploy status

- ✅ Backend: Railway (commit `94ed704` desplegado)
- ✅ Frontend: Vercel (commit `c6d13f4` desplegado)
- ✅ Producción: https://detailinghouse.com.mx actualizada
- ✅ API: https://detailinghouse-api-production.up.railway.app funcional

---

## Conclusión

**Todas las deudas técnicas están corregidas y verificadas.** El sistema admin profesional está completamente funcional, sin errores en consola, y listo para uso en producción.

### Próximos pasos (opcionales)
- Monitorear el polling de cache invalidation en producción
- Considerar agregar métricas de performance para el polling
- Documentar el comportamiento de nómina para admin vs staff en el README
