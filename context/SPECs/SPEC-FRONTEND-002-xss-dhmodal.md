# SPEC-FRONTEND-002 — Sanitización XSS en `dhAdminModal`

**ID:** `FIX-20260710-07`
**Tipo:** Remediación de seguridad
**Prioridad:** Alta
**Estimación:** 1 hora
**Origen:** Auditoría `ARCH-20260710-01` §4.2 #9
**Cumplimiento INTEGRA:** ADR-20260710-05 (zero-deps security)

---

## 1. Contexto

`dhAdminModal` (función helper global) se usa para pedir input al admin (stock, status de cita, etc.). En `index.html:4379`, hace:

```js
overlay.querySelector('.admin-modal-body').innerHTML = opts.body || '';
```

Y los 2 callers pasan HTML construido con template literals que interpolan **datos del backend** sin escapar:

| Línea | Caller | Datos interpolados (origen) |
|---|---|---|
| 4885 | Editar stock | `item.name`, `item.sku`, `item.stock` (de `/api/inventory`) |
| 5003 | Actualizar cita | `appt.client`, `appt.service`, `appt.date`, `appt.time`, `appt.address` (de `/api/appointments`) |

**Vector de ataque:** si un admin (o un endpoint comprometido) crea un producto con `name = "<img src=x onerror=fetch('/api/...')>"`, o un cliente con `name = "<script>...</script>"`, el próximo admin que abra "Editar stock" o "Actualizar cita" ejecuta el XSS en su sesión autenticada. Robo de JWT (`dh_jwt` en localStorage), acciones no autorizadas en el panel, etc.

## 2. Estado actual (vulnerable)

```js
// index.html:4372-4390 (extracto relevante)
window.dhAdminModal = function(opts) {
  ...
  overlay.querySelector('.admin-modal-body').innerHTML = opts.body || '';  // ⚠️ XSS
  ...
};

// index.html:4885 (caller 1)
body: `<p><b>${item.name}</b> (${item.sku || ''})</p>
        <p>Stock actual: ${item.stock}</p>
        <label>Nuevo stock: <input type="number" min="0" step="1"
               value="${item.stock}" data-modal-input /></label>`

// index.html:5003 (caller 2)
body: `<p><b>${appt.client}</b> · ${appt.service}</b></p>
        <p>${appt.date} ${appt.time}</p>
        <p>${appt.address}</p>
        <label>Acción: <select data-modal-input>...</select></label>`
```

## 3. Decisión de implementación

**Helper `escapeHtml(s)` + uso obligatorio en valores interpolados.** Cero dependencias externas (vs `DOMPurify` que sumaría ~20KB).

Razones:
- 2 callers → overhead de aprender API DOMPurify no compensa
- El HTML del template es **fijo y de nuestra autoría** (no viene de usuario). Solo los valores interpolados son user-input
- Escape HTML cubre el vector XSS conocido (inyección de `<`, `>`, `&`, `"`, `'`)

**Trade-off conocido:** `script-src 'unsafe-inline'` sigue activo en CSP (FIX-20260710-03). El escape HTML protege contra XSS en valores, pero un atacante con control del bundle JS aún podría inyectar scripts. Esto se cubre en el sprint de CSP y se documenta como limitación.

## 4. Alcance

### In-scope

- Añadir `const escapeHtml = s => ...` (1 línea) en el IIFE del script principal (top, junto a `formatCurrency`, `finalPrice`, etc.)
- Reemplazar las **2 callers** (L4885, L5003) para usar `escapeHtml()` en cada valor interpolado
- Añadir tests manuales con payload malicioso para verificar que el escape funciona

### Out-of-scope

- `DOMPurify` (overhead no justificado para 2 callers)
- Refactor mayor de `dhAdminModal` (cambiar API a `HTMLElement`)
- Otros `innerHTML` del archivo (la mayoría son contenido fijo de nuestra autoría, no user-input)
- CSP (`script-src 'unsafe-inline'`) → FIX-20260710-03

## 5. Implementación

### 5.1 Helper

Añadir al top del IIFE principal (después de `formatCurrency`, `todayKey`, etc.):

```js
const escapeHtml = s => String(s == null ? '' : s)
  .replace(/[&<>"']/g, c => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;'
  }[c]));
```

### 5.2 Caller 1: Editar stock (L4883-4887)

```js
// ANTES (vulnerable):
const next = await window.dhAdminModal({
  title: 'Editar stock',
  body: `<p><b>${item.name}</b> (${item.sku || ''})</p>
         <p>Stock actual: ${item.stock}</p>
         <label>Nuevo stock: <input type="number" min="0" step="1"
                value="${item.stock}" data-modal-input /></label>`,
  okText: 'Guardar'
});

// DESPUÉS (seguro):
const next = await window.dhAdminModal({
  title: 'Editar stock',
  body: `<p><b>${escapeHtml(item.name)}</b> (${escapeHtml(item.sku || '')})</p>
         <p>Stock actual: ${escapeHtml(item.stock)}</p>
         <label>Nuevo stock: <input type="number" min="0" step="1"
                value="${escapeHtml(item.stock)}" data-modal-input /></label>`,
  okText: 'Guardar'
});
```

### 5.3 Caller 2: Actualizar cita (L5001-5005)

```js
// ANTES (vulnerable):
const action = await window.dhAdminModal({
  title: 'Actualizar cita',
  body: `<p><b>${appt.client}</b> · ${appt.service}</b></p>
         <p>${appt.date} ${appt.time}</p>
         <p>${appt.address}</p>
         <label>Acción: <select data-modal-input>
           <option value="completar">Completar</option>
           <option value="cancelar">Cancelar</option>
         </select></label>`,
  okText: 'Guardar'
});

// DESPUÉS (seguro):
const action = await window.dhAdminModal({
  title: 'Actualizar cita',
  body: `<p><b>${escapeHtml(appt.client)}</b> · ${escapeHtml(appt.service)}</b></p>
         <p>${escapeHtml(appt.date)} ${escapeHtml(appt.time)}</p>
         <p>${escapeHtml(appt.address)}</p>
         <label>Acción: <select data-modal-input>
           <option value="completar">Completar</option>
           <option value="cancelar">Cancelar</option>
         </select></label>`,
  okText: 'Guardar'
});
```

## 6. Criterios de aceptación

| ID | Criterio | Verificación |
|---|---|---|
| CA-1 | `escapeHtml` definido en el IIFE principal | `grep -c "const escapeHtml" index.html` → ≥ 1 |
| CA-2 | Caller 1 (L4883) usa `escapeHtml` en `item.name`, `item.sku`, `item.stock` (×2: en `<p>` y en `value=`) | `grep -A1 "Editar stock" index.html \| grep "escapeHtml"` → ≥ 4 matches |
| CA-3 | Caller 2 (L5001) usa `escapeHtml` en `appt.client`, `appt.service`, `appt.date`, `appt.time`, `appt.address` | `grep -A1 "Actualizar cita" index.html \| grep "escapeHtml"` → ≥ 5 matches |
| CA-4 | Ningún `${userData}` sin `escapeHtml()` en los 2 callers | `grep -E "body:.*\\\${(item|appt)\." index.html` → 0 ocurrencias sin escape |
| CA-5 | Test funcional: editar stock con nombre de producto `<img src=x onerror=alert(1)>` muestra literal en el modal, no ejecuta JS | Manual o Playwright |
| CA-6 | Test funcional: actualizar cita con client name `<script>alert(1)</script>` muestra literal en el modal, no ejecuta JS | Manual o Playwright |
| CA-7 | Funcionalidad previa intacta: editar stock y actualizar cita siguen funcionando con datos legítimos | Playwright E2E |
| CA-8 | No se introducen otros `innerHTML` nuevos | `git diff index.html \| grep "+.*innerHTML"` → 0 (excepto los 2 callers que se modifican) |
| CA-9 | Sin nuevos `console.error` / `pageerror` | Smoke E2E 0 errores |
| CA-10 | Líneas de `index.html` ≤ 5,100 (no debe crecer desproporcionado) | `wc -l index.html` |

## 7. Tests

### 7.1 Tests de seguridad (Playwright)

Crear script `/tmp/kilo/test-xss-fix.js`:

```js
// 1. Inyectar producto malicioso en /api/inventory (requiere sesión admin)
// 2. Login admin → ir a Inventario → click "Editar stock" del producto malicioso
// 3. Verificar que el modal muestra el texto literal "<img..." y NO ejecuta JS
// 4. Mismo para "Actualizar cita" con cliente malicioso
```

### 7.2 Tests de regresión (Playwright E2E)

Reusar `/tmp/kilo/smoke.js` existente, verificar que 18/18 checks siguen OK.

## 8. Riesgos

| Riesgo | Mitigación |
|---|---|
| Olvidar escapar un valor en un futuro caller | Comentario JSDoc en `dhAdminModal` que advierta: "el parámetro `body` se inyecta via innerHTML; escapen valores user-input con escapeHtml()" |
| `escapeHtml` no cubre todos los contextos (atributos, URLs, JS) | Para este sprint, solo se usa en texto/valores de inputs. URLs y JS contexts están out-of-scope (FIX futuro si surge la necesidad) |
| Romper formato visual de datos con caracteres especiales legítimos | `&` se escapa a `&amp;`, lo cual el browser renderiza correctamente. No debe haber cambio visual. |

## 9. Orden de ejecución para SOFIA

1. Backup: `cp index.html index.html.bak-pre-fix-20260710-07`
2. Añadir `const escapeHtml = ...` al IIFE principal (top, después de `formatCurrency`)
3. Modificar caller 1 (L4883-4887) para usar `escapeHtml`
4. Modificar caller 2 (L5001-5005) para usar `escapeHtml`
5. Verificar los 10 criterios de aceptación
6. Correr smoke E2E
7. Generar checkpoint `context/checkpoints/CHK_2026-07-10_HHMM_fix-xss.md`

## 10. Salida esperada

- 1 commit: `fix(security): escape HTML in dhAdminModal to prevent XSS (FIX-20260710-07)`
- ~3 líneas modificadas (helper) + 2 callers (~10 líneas modificadas)
- 0 vulnerabilidades XSS conocidas en los 2 callers auditados
- 12/12 criterios ✅ (revisar post-implementación)

---

**Aprobado por:** INTEGRA (basado en `ARCH-20260710-01`)
**Pendiente:** OK del humano para delegar a SOFIA (ya dado en esta sesión).
