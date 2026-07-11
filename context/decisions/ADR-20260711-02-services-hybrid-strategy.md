# ADR-20260711-02: Estrategia híbrida para servicios editables

**Fecha:** 2026-07-11
**Estado:** Aceptado
**Decisión:** Estrategia híbrida (templates hardcodeados + precios dinámicos) en lugar de renderizado 100% dinámico

---

## Contexto

El usuario quiere poder editar las **características y precios de los servicios desde el admin**, con reflejo automático en la página pública. La página pública tiene una sección "Nuestros Servicios" con HTML estático que incluye:

1. **3 paquetes** (Elite, Plus, Esencial) con:
   - Imagen única por paquete
   - Badge (Premium/Popular/Basic)
   - Descripción exterior (lista de 7-9 items)
   - Descripción interior (lista de 3-4 items)
   - 4 precios por tamaño de vehículo
   - Links a WhatsApp y Google Calendar

2. **5 servicios individuales** (motor, cristales, faros, asientos, ductos) con:
   - Imagen (solo 2 tienen)
   - Icono SVG
   - Precio "Desde $X"

## Opciones evaluadas

### Opción A: Renderizado 100% dinámico desde backend

**Pros:**
- Consistente: todo el contenido viene del backend
- Editar todo desde admin

**Contras:**
- Requiere migrar TODO el contenido a la BD (descripciones largas de exterior/interior, imágenes, links de WhatsApp)
- Admin form se vuelve gigantesco (listas dinámicas de items)
- UX compleja: editar descripciones largas en modal pequeño
- Mayor superficie de bugs (validación de listas, orden, etc.)
- Cambios disruptivos: riesgo de romper el diseño actual

### Opción B: Solo precios dinámicos (precios por tamaño)

**Pros:**
- Cambio mínimo y de bajo riesgo
- Solo edita lo que el usuario pidió (precios)
- Mantiene diseño actual intacto

**Contras:**
- No cubre "características" completas (solo precios)
- HTML sigue siendo semi-estático

### Opción C: Estrategia híbrida (templates hardcodeados + precios dinámicos) ✅

**Pros:**
- Edita precios Y badge Y imagen (las características más importantes)
- Mantiene descripciones detalladas (exterior/interior lists, WhatsApp links) como templates
- Bajo riesgo: solo cambia lo dinámico, lo demás queda intacto
- UX clara: el admin edita precios/badge, el template provee el resto

**Contras:**
- Las descripciones detalladas siguen en código (no editables desde admin)
- Si el usuario quiere editar descripciones largas, requiere nueva spec

## Decisión

**Estrategia híbrida (Opción C).**

### Justificación

1. **Alcance controlado:** El usuario pidió "características y precios". Las "características" más visibles para el cliente son:
   - Precios (4 por tamaño) ← editable
   - Badge (Premium/Popular/Basic) ← editable
   - Imagen ← editable
   - Descripción corta ← ya era editable
   - Descripción detallada (exterior/interior) ← NO editable (en código)

2. **Riesgo bajo:** El HTML estático tiene imágenes, iconos SVG, descripciones largas y links de WhatsApp. Mover TODO a la BD sería un cambio masivo con alta probabilidad de romper el diseño.

3. **Pragmatismo:** Los precios y el badge son lo que más cambia frecuentemente. Las descripciones detalladas rara vez cambian.

4. **Reversibilidad:** Si el usuario quiere editar descripciones después, se puede extender la SPEC.

## Consecuencias

### Positivas

- Implementación rápida (1-2 horas de frontend)
- Bajo riesgo de regresión visual
- Cumple el 80% del valor con 20% del esfuerzo
- Tests E2E sencillos

### Negativas

- Descripciones detalladas siguen en código (deuda técnica documentada)
- Si el usuario pide más adelante editar descripciones, requiere nueva iteración

## Alternativa futura

Si en el futuro el usuario quiere editar descripciones detalladas desde admin, se puede:
1. Agregar campos `includes_exterior` (TEXT[]) y `includes_interior` (TEXT[]) al backend
2. Migrar el contenido actual de los templates a la BD (script de seed)
3. Hacer que `renderPublicServices()` genere las listas dinámicamente
4. Mantener imágenes y WhatsApp links como templates (no cambian frecuentemente)

Esta sería una **SPEC-FRONTEND-008** futura, no parte de este cambio.