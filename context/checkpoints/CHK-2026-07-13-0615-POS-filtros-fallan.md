# CHK-2026-07-13-0615-POS-filtros-fallan.md

**Fecha:** 2026-07-13 06:15 UTC  
**Severidad:** Media (funcionalidad de filtrado del POS no operativa)  
**Síntoma reportado:** "el botón no cambia y los filtros fallan"  
**Estado:** DIAGNOSTICADO, pendiente FIX

---

## 🔴 BUGS ENCONTRADOS

### Bug 1: Filtros de chips no funcionan
- **Síntoma:** Al clickear "Interiores", "Rines", etc., el catálogo de productos NO filtra
- **Causa:** `posCatalogState` se LEE pero nunca se ESCRIBE
- **Causa raíz:** No hay event listeners en `posCatalogChips` ni en `posCatalogSearch`
- **Falta en `bindPublicInteractions()`:**
  - Handler para `byId('posCatalogChips')?.addEventListener('click', ...)` que actualice `posCatalogState.cat`
  - Handler para `byId('posCatalogSearch')?.addEventListener('input', ...)` que actualice `posCatalogState.query`
  - Llamada a `renderPosCatalog()` después de cada cambio

### Bug 2: Search no funciona
- **Síntoma:** Al escribir en el input de búsqueda, el catálogo NO filtra
- **Causa raíz:** Misma que Bug 1 — sin event listener

### Bug 3: El botón "+ Añadir" no cambia
- **Síntoma:** El usuario reporta que el botón "no cambia"
- **Realidad:** El botón NO debería cambiar su texto. El cart count es lo que se actualiza
- **Causa:** Malinterpretación del usuario — el cart count SÍ se actualiza (probado: 0 → 1 → 2 → 3)
- **Acción:** Ninguna. Es comportamiento correcto.

---

## 🔍 DIAGNÓSTICO (ejecutar para confirmar)

```js
// En consola del navegador, estando en /admin y logueado:
const cat = window.posCatalogState;
console.log('posCatalogState:', cat);
// ESPERADO: { query: '...', cat: '...' }
// ACTUAL: undefined (state nunca se inicializa)

const chips = document.querySelectorAll('.pos-chip');
chips.forEach(c => {
  c.addEventListener('click', () => {
    console.log('Click en:', c.textContent.trim());
    // No se ejecuta nada porque no hay handler
  });
});

const search = document.getElementById('posCatalogSearch');
console.log('Search listener:', search?.oninput);
// null (no hay listener)
```

---

## 🔧 FIX (a aplicar)

### En `bindPublicInteractions()`, agregar:

```js
// Estado de filtros del POS
if (!window.posCatalogState) {
  window.posCatalogState = { query: '', cat: 'todos' };
}

// Filtros de chips (categorías de productos)
byId('posCatalogChips')?.addEventListener('click', e => {
  const chip = e.target.closest('.pos-chip');
  if (!chip) return;
  document.querySelectorAll('.pos-chip').forEach(c => c.classList.remove('active'));
  chip.classList.add('active');
  window.posCatalogState.cat = chip.dataset.cat || 'todos';
  renderPosCatalog();
});

// Búsqueda por nombre o SKU
byId('posCatalogSearch')?.addEventListener('input', e => {
  window.posCatalogState.query = e.target.value || '';
  renderPosCatalog();
});
```

### Ubicación en el código
- `bindPublicInteractions()` en `/home/frank/repos/detailinghouse/index.html` línea 4832
- Agregar después del handler de `productFilters` (línea 4860)

### También en admin.html
- Mismo cambio en `bindAdminInteractions()` o donde corresponda en admin

---

## 📊 ESTADO ACTUAL DEL POS

| Elemento | Estado | Detalle |
|----------|--------|---------|
| 8 servicios en strip | ✅ Funciona | `posServicesGrid` con `data-strip-svc` |
| 70 productos en catálogo | ✅ Funciona | `posCatalog` con `data-add-product` |
| Botón "+ Añadir" | ✅ Funciona | Llama a `addItemToCart` |
| Cart count | ✅ Funciona | Se incrementa (0 → 1 → 2 → 3) |
| Cart drawer | ✅ Funciona | Se abre con `toggleFloatingCart(true)` |
| Cart remove/inc/dec | ✅ Funciona | Handler en `posCartDrawer` |
| **Filtro de chips** | ❌ **Falla** | Sin handler de click |
| **Búsqueda** | ❌ **Falla** | Sin handler de input |
| Cliente search | ❓ No probado | Probablemente también falla |
| Cliente select | ❓ No probado | |

---

## 🎯 ACCIÓN REQUERIDA

1. Aplicar el fix de los chips y search en `bindPublicInteractions()`
2. Probar el flujo completo:
   - Click chip "Interiores" → solo productos Interiores
   - Click chip "Rines" → solo Rines
   - Escribir en search → filtra por nombre
   - Combinar chip + search → ambos filtros
   - Verificar que agregar al carrito sigue funcionando
   - Verificar que cambiar cantidad funciona
   - Verificar que eliminar del carrito funciona
3. Sincronizar admin.html con el fix
4. Commit y push

---

## 📝 NOTAS

- El usuario ve "el botón no cambia" probablemente porque esperaba feedback visual (ej: cambiar a "✓ Añadido" o algo así). Esto es UX, no bug.
- Los filtros de chips y search son funcionalidad estándar esperada en un POS.
- El cart count se actualiza correctamente, por lo que el backend/store está bien.

**Prioridad:** Media-Alta (afecta la usabilidad del POS)
