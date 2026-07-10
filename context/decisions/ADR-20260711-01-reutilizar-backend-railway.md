# ADR-20260711-01: Reutilizar backend Railway existente

**Fecha:** 2026-07-11  
**Estado:** Aceptado  
**Decisión:** Reutilizar el backend existente en Railway en lugar de construir uno nuevo

---

## Contexto

El proyecto DetailingHouse tiene actualmente:
- **Frontend:** Vercel (HTML/JS vanilla, `index.html`)
- **Backend:** Railway (Node.js + Express + PostgreSQL)
- **Repo backend:** `frank-vcorp/detailinghouse-api` (acceso completo)

## Problema

Se identificó la necesidad de:
1. CRUD completo para productos (editar nombre/precio/descripción)
2. CRUD completo para servicios
3. Reflejo de cambios en página pública
4. Rediseño del panel admin

## Opciones evaluadas

### Opción A: Backend propio (Vercel + Neon)
**Pros:**
- Mismo deploy que frontend
- Control total

**Contras:**
- Duplicar infraestructura
- Migrar datos existentes
- 2 semanas de trabajo

### Opción B: Reutilizar Railway existente ✅
**Pros:**
- Backend YA tiene endpoints CRUD para productos
- Base de datos PostgreSQL ya configurada
- Datos existentes (ventas, clientes, citas) preservados
- 3-4 días de trabajo
- Acceso completo al código (`frank-vcorp/detailinghouse-api`)

**Contras:**
- Dos repos separados (frontend + backend)
- Railway tiene costo mensual

## Decisión

**Reutilizar el backend Railway existente.**

### Justificación

1. **Endpoints ya existen:**
   - `PATCH /api/inventory/:sku` — actualizar TODOS los campos del producto
   - `POST /api/inventory` — crear producto
   - `DELETE /api/inventory/:sku` — soft delete
   - Solo falta agregar endpoints para servicios

2. **Base de datos ya tiene datos:**
   - 30 productos A1A cargados
   - Ventas, clientes, citas, caja
   - No hay que migrar nada

3. **Acceso completo:**
   - Repo: `frank-vcorp/detailinghouse-api`
   - Railway CLI autenticado
   - PostgreSQL accesible

4. **Timeline reducido:**
   - Backend: 1 día (agregar servicios)
   - Frontend: 2-3 días (UI + rediseño)
   - Total: 3-4 días vs 2 semanas

## Consecuencias

### Positivas
- Desarrollo rápido
- Sin migración de datos
- Infraestructura probada y estable
- Costo incremental mínimo

### Negativas
- Dos repos separados (aceptable para este proyecto)
- Railway tiene costo (~$5/mes actual)

## Implementación

1. Agregar tabla `services` al backend
2. Agregar endpoints CRUD para servicios
3. Agregar UI en frontend para editar productos y servicios
4. Implementar cache invalidation
5. Rediseñar panel admin

## Rollback

Si hay problemas, el backend actual sigue funcionando. Los cambios son incrementales y no rompen nada existente.
