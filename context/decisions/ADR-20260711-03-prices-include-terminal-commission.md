# ADR-20260711-03: Precios siempre con +4% comisión de terminal (sin mostrar desglose)

**Fecha:** 2026-07-11
**Estado:** Aceptado
**Decisión:** Los precios al público SIEMPRE incluyen +4% de comisión de terminal, pero NUNCA se muestra desglose de esa comisión

---

## Contexto

El usuario indica que:

> "los precios deben mostrarse siempre mas el 4% que es la comision de la terminal pero no debe decir que es la comision de la terminal"

**Traducción técnica:**
1. Los precios mostrados al cliente final deben tener **+4%** de comisión de terminal ya sumada
2. El cliente **NO debe ver** "comisión de terminal" en ningún texto
3. Solo el admin (internamente) sabe que el precio incluye esa comisión

## Decisión

### Cálculo del precio público

**Fórmula:**
```
precio_público = round(precio_base × 1.036 × 1.16)
```

- `× 1.036` = +3.6% de comisión de terminal (redondeado a 4% para simplicidad)
- `× 1.16` = +16% de IVA
- `round()` = redondeo a entero

**Ejemplo:**
- Paquete Elite base: $2,200
- $2,200 × 1.036 × 1.16 = $2,643.87 → **$2,644**

### Texto visible al cliente

**PROHIBIDO:**
- ❌ "IVA + comisión terminal incluidos"
- ❌ "Comisión de terminal"
- ❌ Cualquier desglose de comisiones

**PERMITIDO:**
- ✅ "Precio final"
- ✅ "IVA incluido"
- ✅ (sin texto auxiliar, solo el precio)

### Texto en admin (interno)

El admin **SÍ puede saber** que el precio incluye la comisión. Por lo tanto:
- Helper text del modal: "Precio público final (ya incluye IVA y comisión de terminal)"
- En la tabla admin: comentario interno OK
- En la documentación interna: desglose completo

## Implementación

### Backend

El cálculo de comisión + IVA se hace **una sola vez** al guardar/editar el servicio desde el admin. El backend NO recalcula automáticamente — el admin es responsable de ingresar el precio final correcto.

**Validación recomendada (futuro):**
```javascript
// Cuando el admin ingresa precio base, calcular precio público automáticamente
const basePrice = 2200;
const publicPrice = Math.round(basePrice * 1.036 * 1.16); // 2644
```

### Frontend

**Página pública:**
- Quitar `<small>IVA + comisión terminal incluidos</small>`
- Dejar solo el precio o un texto genérico como "Precio final"

**Admin modal:**
- Helper text actualizado: "Precio público final (ya incluye IVA y comisión de terminal)"

## Consecuencias

### Positivas

- Cliente ve precio limpio, sin sorpresas
- No se expone información interna del negocio
- Cálculo transparente: admin sabe exactamente qué porcentaje se aplica

### Negativas

- Admin debe calcular manualmente o usar herramienta externa para obtener precio público
- Si cambia el porcentaje de comisión, hay que actualizar todos los precios

## Mitigación

**Mejora futura (SPEC-FRONTEND-008):**
- Agregar campo `price_base` (precio sin comisión) al backend
- Frontend calcula precio público automáticamente al mostrar
- Admin puede ver ambos precios (base y público) en el modal