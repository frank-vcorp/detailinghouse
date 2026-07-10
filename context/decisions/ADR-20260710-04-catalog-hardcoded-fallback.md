# ADR-20260710-04 — Catálogo `baseCatalog` hardcodeado en frontend

**Estado:** Aceptado (legacy), con plan de remediación
**Fecha:** 2026-06-27 (v2.0) / 2026-07-10 (formalización)
**Decisores:** INTEGRA

## Contexto

En v2.0 se incorporaron 30 productos A1A con descripciones reales. Para que el sitio público renderizara **inmediatamente** sin esperar la API, se hardcodeó el array `baseCatalog` en el JS del frontend. La API existe (`getInventory`) y la versión admin ya la consume, pero la página pública aún usa el hardcode como fallback.

## Estado actual

```js
// index.html L3940-3971
const baseCatalog = [ /* 30 productos con sku, name, price, category, etc. */ ];
```

```js
// index.html L3995-3999
function syncInventory() {
  return baseCatalog.map(item => ({ ...item, stock: 10, type: 'product' }));
}
```

```js
// index.html L4715-4718
} catch(e) {
  console.warn('[API] Inventario no disponible, usando baseCatalog:', e.message);
  state.inventory = baseCatalog.map(p => ({ ...p, stock: 10, type: 'product' }));
}
```

## Problema detectado

Si el admin edita un precio en la DB, la **página pública puede mostrar precios desactualizados** durante la primera carga (hasta que la API responda) y también si la API está caída (fallback silencioso sin notificar al usuario).

## Decisión

**Mantener como fallback offline-first**, **pero con remediación**:

1. **Corto plazo (FIX-20260710-01):**
   - Renombrar `baseCatalog` → `OFFLINE_CATALOG_FALLBACK` (intencional).
   - Documentar con JSDoc que es solo fallback.
   - Loggear `[WARN]` solo en dev, en prod silencioso.
2. **Mediano plazo:**
   - El admin debe poder marcar productos como "visibles en público" vs "solo inventario interno".
   - La página pública debe mostrar un toast/banner si está sirviendo precios de fallback.

## Consecuencias

### Positivas (del estado actual)
- Página pública nunca está "vacía": si la API muere, los 30 productos siguen visibles.
- Time-to-first-paint óptimo (no espera red).

### Negativas
- **Riesgo comercial:** precio público desactualizado si admin cambia DB.
- **Riesgo de inconsistencia:** SKU eliminado en DB sigue apareciendo público.
- **Doble fuente de verdad** para el inventario.

## Plan de salida (trigger para reconsiderar)

- Cuando el catálogo supere 50 productos.
- Cuando se añadan "ofertas flash" o precios dinámicos.
- Cuando la API tenga SLA >99.5%.

## Revisión

Trimestral. Próxima: 2026-10-10.
