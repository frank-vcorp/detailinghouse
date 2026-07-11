# SPEC-FRONTEND-007: Servicios editables desde admin (características y precios por tamaño)

**ID:** ARCH-20260711-07
**Fecha:** 2026-07-11
**Estado:** En implementación (backend completo, frontend parcial)
**Autor:** INTEGRA
**ADR relacionado:** ADR-20260711-02, ADR-20260711-03
**Fase:** Micro-Sprint `ADMIN-PROFESIONAL-20260711` — extensión

---

## 1. Contexto

El usuario quiere poder modificar las **características y precios de los servicios desde el admin**, y que los cambios se reflejen automáticamente en la página pública.

### 1.1 Regla de negocio CRÍTICA

> **Los precios mostrados SIEMPRE deben incluir el +4% de comisión de terminal ya sumado.**
> **NUNCA debe aparecer el texto "comisión de terminal" ni desglose de la comisión.**
> El cliente solo ve el precio final. Internamente el admin puede saber que incluye IVA + comisión.

**Implicaciones:**
- El backend calcula precios finales (base × 1.036 × 1.16)
- La UI pública muestra SOLO el precio final, sin desglose
- El helper text del admin debe decir "Precio público (IVA incluido)" o similar — NUNCA "comisión terminal"
- La frase actual "IVA + comisión terminal incluidos" en página pública debe **eliminarse o reescribirse**

### 1.2 Estado previo

**Lo que YA funcionaba** (Fases 1-7 del micro-sprint anterior):
- Admin puede editar nombre, precio base, descripción, emoji, categoría, duración del servicio
- Tabla de servicios del admin muestra datos del backend
- POS del admin usa precios del backend (corregido en fix reciente)
- Cache invalidation implementado para productos (60s polling + cross-tab)

**Lo que NO funcionaba** (gap detectado):
- Página pública tiene **precios por tamaño de vehículo** (Compacto, Sedán, Pick-up, Luxury) hardcodeados en HTML estático
- No había forma de editar esos precios desde admin
- Cambios de precio en admin NO se reflejaban en página pública

### 1.2 Lo que el usuario pidió

> "me gustaria que se pudieran modificar los servicios caracteristicas y precios desde el admin"

Esto implica:
1. Precios por tamaño de vehículo editables (4 precios por paquete)
2. Características adicionales editables (badge, imagen)
3. Reflejo automático en página pública

---

## 2. Objetivos

1. Agregar campo `prices_json` (JSONB) a tabla `services` con 4 precios por tamaño de vehículo
2. Agregar campo `badge` (premium/popular/basic) a tabla `services`
3. Agregar campo `image_url` a tabla `services`
4. Actualizar endpoints backend para aceptar/retornar nuevos campos
5. Actualizar seed con precios actuales de la página pública
6. Ampliar modal de servicios en admin con nuevos campos
7. Crear `renderPublicServices()` que lea del backend y actualice la sección "Nuestros Servicios"
8. Integrar con cache invalidation existente

---

## 3. Cambios en Backend

### 3.1 Migración de tabla

```sql
ALTER TABLE services ADD COLUMN IF NOT EXISTS prices_json JSONB;
ALTER TABLE services ADD COLUMN IF NOT EXISTS badge VARCHAR(20);
ALTER TABLE services ADD COLUMN IF NOT EXISTS image_url TEXT;
```

### 3.2 Estructura de `prices_json`

```json
{
  "compacto": 2644,
  "sedan": 3245,
  "pickup": 3846,
  "luxury": null
}
```

- `null` en `luxury` = "Cotización" en página pública
- Valores numéricos en pesos mexicanos (ya con IVA + comisión incluidos)

### 3.3 Endpoints actualizados

| Método | Endpoint | Cambios |
|--------|----------|---------|
| GET | `/api/services` | Retorna `prices_json`, `badge`, `image_url` |
| GET | `/api/services/:id` | Retorna todos los campos |
| POST | `/api/services` | Acepta `prices_json`, `badge`, `image_url` |
| PATCH | `/api/services/:id` | Acepta `prices_json`, `badge`, `image_url` |

### 3.4 Seed actualizado

Precios actuales (IVA + comisión incluidos) para los 3 paquetes:

| Servicio | Compacto | Sedán | Pick-up | Luxury |
|----------|----------|-------|---------|--------|
| Paquete Elite | $2,644 | $3,245 | $3,846 | Cotización |
| Paquete Plus | $2,283 | $2,884 | $3,485 | Cotización |
| Paquete Esencial | $300 | $370 | $440 | Cotización |

Servicios individuales (precio único "Desde $X"):

| Servicio | Precio |
|----------|--------|
| Lavado de motor | $601 |
| Protección cristales | $961 |
| Pulido faros | $601 |
| Lavado asientos | $1,082 |
| Desinfección ductos | $361 |

Badges:
- SRV-001: `premium`
- SRV-002: `popular`
- SRV-003: `basic`
- SRV-004 a SRV-008: NULL

---

## 4. Cambios en Frontend Admin

### 4.1 Modal de servicio ampliado

**Campos nuevos en modal `#serviceModal`:**

```
[Badge (premium/popular/basic)]  [URL imagen]
─────────────────────────────────────────────────
Precios por tamaño de vehículo:
[Compacto $]  [Sedán / SUV Chica $]
[Pick-up / SUV Grande $]  [Premium / Luxury $]
   (vacío = "Cotización")
```

**Helper text:** "Estos precios se muestran en la página pública con IVA y comisión incluidos. Dejar vacío para 'Cotización'."

### 4.2 Handler `openServiceModal` actualizado

```javascript
// Nuevos campos a llenar al editar:
byId('serviceBadge').value = svc.badge || '';
byId('serviceImageUrl').value = svc.image_url || '';
const pj = svc.prices_json || {};
byId('servicePriceCompacto').value = pj.compacto != null ? pj.compacto : '';
byId('servicePriceSedan').value    = pj.sedan != null ? pj.sedan : '';
byId('servicePricePickup').value   = pj.pickup != null ? pj.pickup : '';
byId('servicePriceLuxury').value   = pj.luxury != null ? pj.luxury : '';
```

### 4.3 Handler `saveServiceBtn` actualizado

```javascript
const data = {
  name: ...,
  price: ...,
  // ... campos existentes
  badge: byId('serviceBadge').value || null,
  image_url: byId('serviceImageUrl').value.trim() || null,
  prices_json: {
    compacto: byId('servicePriceCompacto').value ? Number(byId('servicePriceCompacto').value) : null,
    sedan:    byId('servicePriceSedan').value    ? Number(byId('servicePriceSedan').value)    : null,
    pickup:   byId('servicePricePickup').value   ? Number(byId('servicePricePickup').value)   : null,
    luxury:   byId('servicePriceLuxury').value   ? Number(byId('servicePriceLuxury').value)   : null
  }
};
```

### 4.4 Tabla de servicios

**Estado actual:** muestra columnas ID, Emoji, Nombre, Precio, Categoría, Duración, Estado, Acciones

**Cambio:** agregar columna "Precios público" que muestre resumen de precios por tamaño:
```
Precios público: $2,644 · $3,245 · $3,846 · Cotización
```

---

## 5. Cambios en Frontend Público

### 5.1 Nueva función `renderPublicServices()`

Esta función reemplaza el contenido hardcodeado de la sección "Nuestros Servicios" con datos del backend.

**Estrategia híbrida (no invasiva):**
1. Reemplazar los `<div class="cards-3">` y `<div class="mini-grid">` con contenedores `<div id="publicServicesPackages">` y `<div id="publicServicesExtras">`
2. `renderPublicServices()` itera sobre `state.services` y genera HTML dinámicamente
3. Mantiene los textos descriptivos hardcodeados (exterior/interior lists, imágenes, WhatsApp links) como **templates** por `id` de servicio
4. Solo los precios y el badge se actualizan dinámicamente

### 5.2 Templates hardcodeados por servicio

Para mantener la estructura visual actual (descripciones detalladas exterior/interior), se crean templates JavaScript por servicio:

```javascript
const SERVICE_TEMPLATES = {
  'SRV-001': {
    image: 'assets/images/puesto_conductor_elite.jpg',
    badge: 'Premium',
    exterior: ['Descontaminación de pintura', 'Protección de cristales', ...],
    interior: ['Aspirado profundo', 'Lavado de textiles', ...],
    whatsapp: 'https://wa.me/524461153815?text=Hola...Paquete Elite...'
  },
  'SRV-002': { ... },
  'SRV-003': { ... }
};
```

Servicios individuales (SRV-004 a SRV-008) usan templates más simples con solo nombre, emoji y precio.

### 5.3 Integración con cache invalidation

`renderPublicServices()` se llama desde:
1. Carga inicial de la página (después de `state.services` cargado)
2. `loadPublicData()` cuando hay cache invalidation

```javascript
async function loadPublicData() {
  const products = await api.request('/inventory');
  state.inventory = products;
  const services = await api.request('/services');
  state.services = services;
  
  renderPublicProducts('todos');
  renderPublicServices();  // NUEVO
  renderServicesStrip();
}
```

---

## 6. Criterios de aceptación

- [ ] CA-1: Backend retorna `prices_json` y `badge` en GET /api/services
- [ ] CA-2: Modal admin muestra 4 inputs de precio por tamaño
- [ ] CA-3: Modal admin muestra selector de badge
- [ ] CA-4: Guardar servicio con precios por tamaño actualiza BD
- [ ] CA-5: Tabla admin muestra resumen de precios públicos
- [ ] CA-6: Página pública carga servicios desde backend
- [ ] CA-7: Cambiar precio en admin se refleja en página pública en <5 segundos
- [ ] CA-8: Badge de paquete (Premium/Popular/Basic) se aplica correctamente
- [ ] CA-9: Precio Luxury = null se muestra como "Cotización"
- [ ] CA-10: 0 errores en consola

---

## 7. Riesgos y mitigaciones

| Riesgo | Mitigación |
|--------|------------|
| Migración rompe servicios existentes | ALTER ADD COLUMN con IF NOT EXISTS, no afecta datos |
| Cambios en HTML público rompen diseño | Estrategia híbrida: templates hardcodeados + precios dinámicos |
| `prices_json` JSONB no soporta todos los browsers | Backend lo serializa, frontend solo lee JSON normal |
| UX confusa con 4 precios vs 1 precio base | Helper text + sección colapsable en modal |

---

## 8. Estado de implementación

### ✅ Backend (COMPLETO — commit `b48dcd3`)
- Migración ejecutada en producción ✅
- Seed ejecutado ✅
- Endpoints actualizados ✅
- GET /api/services retorna prices_json y badge ✅ (verificado con curl)

### 🟡 Frontend Admin (PARCIAL — sin commit)
- ✅ Modal HTML ampliado con nuevos campos
- ✅ Handler `openServiceModal` actualizado
- ❌ Handler `saveServiceBtn` (pendiente)
- ❌ Tabla con columna de precios (pendiente)

### ❌ Frontend Público (PENDIENTE)
- ❌ `renderPublicServices()` (pendiente)
- ❌ Templates hardcodeados (pendiente)
- ❌ Integración con cache invalidation (pendiente)

### ❌ Testing (PENDIENTE)
- ❌ Verificación E2E con Playwright

---

## 9. Próximos pasos

1. Crear `ADR-20260711-02` documentando decisión de estrategia híbrida
2. Delegar a SOFIA: completar frontend admin (saveServiceBtn + tabla) + frontend público
3. Verificar E2E con Playwright
4. Commit final + deploy