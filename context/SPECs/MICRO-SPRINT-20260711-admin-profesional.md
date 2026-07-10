# MICRO-SPRINT: Sistema Admin Profesional Completo

**Fecha:** 2026-07-11  
**Duración estimada:** 4-5 días  
**ID:** ARCH-20260711-MASTER

---

## 🎯 Objetivo

Transformar el panel admin de DetailingHouse en un sistema profesional, autogestionable y moderno con:
- CRUD completo para productos y servicios
- Diseño moderno, claro y responsive
- Reflejo de cambios en página pública en tiempo real
- Preparado para PWA futura

---

## 📋 Especificaciones generadas

### Backend (Railway)
1. **SPEC-BACKEND-001** — Tabla y endpoints para servicios
   - Crear tabla `services` en PostgreSQL
   - Endpoints CRUD completos
   - Migrar 8 servicios hardcodeados a BD
   - **Timeline:** 1 día

### Frontend (Vercel)
2. **SPEC-FRONTEND-003** — UI admin CRUD productos
   - Tabla mejorada con todos los campos
   - Modal de edición completo
   - Modal de eliminación (soft delete)
   - **Timeline:** 2 días

3. **SPEC-FRONTEND-004** — UI admin CRUD servicios
   - Nueva sección "Servicios" en sidebar
   - CRUD completo (crear, editar, eliminar)
   - Integración con POS
   - **Timeline:** 2 días

4. **SPEC-FRONTEND-005** — Rediseño completo del panel admin
   - Colores claros y profesionales
   - Layout con sidebar fija
   - Responsive (desktop, tablet, mobile)
   - Iconos Lucide
   - **Timeline:** 2 días

5. **SPEC-FRONTEND-006** — Cache invalidation
   - Reflejo de cambios en <5 segundos
   - Polling cada 60 segundos
   - Sincronización entre pestañas
   - **Timeline:** 1 día

### Arquitectura
6. **ADR-20260711-01** — Reutilizar backend Railway existente
   - No construir backend nuevo
   - Aprovechar endpoints existentes
   - **Decisión:** Aceptado

---

## 🎨 Diseño del nuevo panel admin

### Paleta de colores
- **Fondo principal:** `#F8F9FA` (gris muy claro)
- **Fondo secundario:** `#FFFFFF` (blanco)
- **Color primario:** `#0366D6` (azul profesional)
- **Texto principal:** `#24292E` (gris oscuro)
- **Bordes:** `#E1E4E8` (gris suave)

### Layout
```
┌─────────────────────────────────────────────────────────┐
│  Sidebar (240px)          │  Main Content               │
│  ┌─────────────────────┐  │  ┌─────────────────────────┐│
│  │ 🏠 DetailingHouse   │  │  │ Header                  ││
│  │                     │  │  │ [Hamburger] Dashboard   ││
│  │ 📊 Dashboard        │  │  │                  Admin  ││
│  │ 🛒 POS              │  │  └─────────────────────────┘│
│  │ 📦 Inventario       │  │  ┌─────────────────────────┐│
│  │ 🛍️ Servicios        │  │  │                         ││
│  │ 👥 Clientes         │  │  │  Contenido de la        ││
│  │ 📅 Agenda           │  │  │  sección activa         ││
│  │ 💰 Caja Chica       │  │  │                         ││
│  │ 💼 Nómina           │  │  │                         ││
│  │                     │  │  │                         ││
│  │ ─────────────────── │  │  │                         ││
│  │ ⚙️ Configuración    │  │  │                         ││
│  │ 🚪 Cerrar sesión    │  │  │                         ││
│  └─────────────────────┘  │  └─────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

### Responsive
- **Desktop (>1024px):** Sidebar fija, contenido ocupa el resto
- **Tablet (768-1024px):** Sidebar colapsada (solo iconos)
- **Mobile (<768px):** Sidebar oculta, hamburger menu

---

## 📊 Estado actual vs objetivo

### Productos
| Funcionalidad | Actual | Objetivo |
|---------------|--------|----------|
| Crear producto | ✅ | ✅ |
| Editar stock | ✅ | ✅ |
| Editar nombre | ❌ | ✅ |
| Editar precio | ❌ | ✅ |
| Editar descripción | ❌ | ✅ |
| Editar categoría | ❌ | ✅ |
| Eliminar producto | ❌ | ✅ (soft delete) |
| Reflejo en página pública | ❌ | ✅ (<5 seg) |

### Servicios
| Funcionalidad | Actual | Objetivo |
|---------------|--------|----------|
| Ver servicios | ✅ (hardcodeado) | ✅ (desde BD) |
| Crear servicio | ❌ | ✅ |
| Editar servicio | ❌ | ✅ |
| Eliminar servicio | ❌ | ✅ (soft delete) |
| Reflejo en página pública | ❌ | ✅ (<5 seg) |

### UI/UX
| Aspecto | Actual | Objetivo |
|---------|--------|----------|
| Colores | Oscuros | Claros y profesionales |
| Layout | Tabs horizontales | Sidebar + contenido |
| Responsive | ❌ | ✅ (mobile-first) |
| Iconos | Emojis | Lucide Icons |
| Modales | Básicos | Profesionales |
| PWA-ready | ❌ | ✅ |

---

## 🚀 Plan de implementación

### Fase 1: Backend (Día 1)
**Responsable:** SOFIA  
**Entregable:** Endpoints de servicios funcionando

1. Crear tabla `services` en PostgreSQL
2. Agregar endpoints CRUD en `routes/services.js`
3. Crear script `db/seed_services.js`
4. Ejecutar migración y seed
5. Deploy a Railway
6. Testing con curl/Postman

**Criterios de éxito:**
- ✅ GET `/api/services` devuelve 8 servicios
- ✅ POST `/api/services` crea nuevo servicio
- ✅ PATCH `/api/services/:id` actualiza servicio
- ✅ DELETE `/api/services/:id` desactiva servicio

### Fase 2: Rediseño admin (Días 2-3)
**Responsable:** SOFIA  
**Entregable:** Panel admin con nuevo diseño

1. Crear CSS completo con variables
2. Implementar layout con sidebar
3. Migrar secciones existentes (Dashboard, POS, Inventario, Clientes, Agenda, Caja, Nómina)
4. Agregar iconos Lucide
5. Implementar responsive
6. Testing en 3 breakpoints

**Criterios de éxito:**
- ✅ Sidebar con 8 secciones
- ✅ Colores claros que no cansan
- ✅ Responsive en desktop/tablet/mobile
- ✅ No rompe funcionalidad existente

### Fase 3: CRUD productos (Días 3-4)
**Responsable:** SOFIA  
**Entregable:** Edición completa de productos

1. Mejorar tabla de productos (agregar categoría, estado)
2. Crear modal de edición con todos los campos
3. Crear modal de eliminación
4. Implementar handlers (PATCH, DELETE)
5. Testing E2E

**Criterios de éxito:**
- ✅ Editar todos los campos de un producto
- ✅ Eliminar producto (soft delete)
- ✅ Validaciones funcionan
- ✅ Toast de éxito/error

### Fase 4: CRUD servicios (Días 4-5)
**Responsable:** SOFIA  
**Entregable:** Sección Servicios completa

1. Crear sección "Servicios" en sidebar
2. Implementar tabla de servicios
3. Crear modal de creación/edición
4. Crear modal de eliminación
5. Integrar con POS (actualizar serviceCatalog)
6. Testing E2E

**Criterios de éxito:**
- ✅ CRUD completo de servicios
- ✅ POS se actualiza automáticamente
- ✅ Fallback a serviceCatalog si backend falla

### Fase 5: Cache invalidation (Día 5)
**Responsable:** SOFIA  
**Entregable:** Reflejo en tiempo real

1. Agregar endpoint `/api/inventory/last-update`
2. Implementar `invalidatePublicCache()`
3. Implementar polling cada 60 segundos
4. Implementar sincronización entre pestañas
5. Agregar indicador visual
6. Testing

**Criterios de éxito:**
- ✅ Cambios se reflejan en <5 segundos
- ✅ No es necesario recargar
- ✅ Polling funciona correctamente
- ✅ Indicador visual aparece

---

## ✅ Criterios de aceptación globales

- [ ] CA-1: Admin puede editar TODOS los campos de productos
- [ ] CA-2: Admin puede crear/editar/eliminar servicios
- [ ] CA-3: Cambios se reflejan en página pública en <5 segundos
- [ ] CA-4: Panel admin tiene diseño moderno y profesional
- [ ] CA-5: Panel admin es responsive (desktop, tablet, mobile)
- [ ] CA-6: Colores claros que no cansan la vista
- [ ] CA-7: Layout ocupa 100% del viewport
- [ ] CA-8: Iconos Lucide cargados correctamente
- [ ] CA-9: No rompe funcionalidad existente (ventas, clientes, citas, etc.)
- [ ] CA-10: Performance aceptable (<2s carga inicial)
- [ ] CA-11: Accesible (contraste WCAG AA, focus visible)
- [ ] CA-12: Preparado para PWA futura

---

## 🧪 Plan de testing

### Testing manual
1. **Login admin** → verificar 8 secciones en sidebar
2. **Dashboard** → verificar métricas
3. **POS** → verificar servicios y productos
4. **Inventario** → editar producto, verificar cambios
5. **Servicios** → crear/editar/eliminar servicio
6. **Clientes** → verificar lista
7. **Agenda** → verificar citas
8. **Caja** → verificar movimientos
9. **Nómina** → verificar cortes
10. **Página pública** → verificar que cambios se reflejan

### Testing responsive
1. **Desktop (1440px)** → sidebar fija, contenido completo
2. **Tablet (1024px)** → sidebar colapsada
3. **Mobile (375px)** → hamburger menu, modales full-screen

### Testing de performance
1. **Carga inicial** → <2 segundos
2. **Navegación entre secciones** → <500ms
3. **Edición de producto** → <1 segundo
4. **Reflejo en página pública** → <5 segundos

---

## 📦 Entregables

### Código
- [ ] Backend: `routes/services.js`, `db/seed_services.js`
- [ ] Frontend: CSS completo, HTML rediseñado, JavaScript CRUD
- [ ] Tests: Smoke E2E con Playwright

### Documentación
- [ ] ADR-20260711-01 (reutilizar backend)
- [ ] SPEC-BACKEND-001 (servicios)
- [ ] SPEC-FRONTEND-003 (productos CRUD)
- [ ] SPEC-FRONTEND-004 (servicios CRUD)
- [ ] SPEC-FRONTEND-005 (rediseño admin)
- [ ] SPEC-FRONTEND-006 (cache invalidation)
- [ ] Checkpoint final

### Deploy
- [ ] Backend deploy a Railway
- [ ] Frontend deploy a Vercel
- [ ] Verificación en producción

---

## ⚠️ Riesgos y mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Backend falla | Baja | Alto | Fallback a datos hardcodeados |
| CSS rompe funcionalidad | Media | Medio | Hacer cambios incrementales |
| Polling genera carga | Baja | Bajo | Polling cada 60s + cache HTTP |
| POS se rompe | Media | Alto | Mantener serviceCatalog como fallback |
| Timeline se extiende | Media | Medio | Priorizar fases críticas |

---

## 🔄 Rollback plan

Si hay problemas críticos:
1. Revertir último commit
2. Volver a versión anterior (backup en `index.html.bak-pre-fix-20260710`)
3. Backend sigue funcionando (cambios son incrementales)

---

## 📅 Timeline detallado

| Día | Mañana (4h) | Tarde (4h) |
|-----|-------------|------------|
| **Día 1** | Fase 1: Backend servicios | Fase 1: Testing + deploy |
| **Día 2** | Fase 2: CSS + layout | Fase 2: Migrar secciones |
| **Día 3** | Fase 2: Responsive | Fase 3: Tabla productos |
| **Día 4** | Fase 3: Modales productos | Fase 4: Sección servicios |
| **Día 5** | Fase 4: Integración POS | Fase 5: Cache invalidation |

**Total:** 5 días (40 horas)

---

## 🎯 Próximos pasos

1. **Confirmar specs** → Revisar con el usuario
2. **Delegar a SOFIA** → Empezar con Fase 1 (backend)
3. **Testing incremental** → Verificar cada fase
4. **Deploy final** → Producción
5. **Documentación** → Checkpoint + actualizar PROYECTO.md

---

## 💡 Notas adicionales

### PWA futura
El rediseño está preparado para PWA:
- Responsive mobile-first
- Iconos Lucide (SVG, escalables)
- Layout adaptable
- Cache invalidation eficiente

### Multi-idioma
El diseño usa variables CSS, facilitando futura internacionalización.

### Accesibilidad
- Contraste WCAG AA
- Focus visible en todos los elementos interactivos
- ARIA labels en iconos
- Navegación por teclado

---

## 📞 Contacto

**Arquitecto:** INTEGRA  
**Implementador:** SOFIA  
**Auditor:** GEMINI  
**Fecha de inicio:** 2026-07-11  
**Fecha estimada de finalización:** 2026-07-15
