# ADR-20260710-03 — Roles con magic strings hardcodeados en frontend

**Estado:** Aceptado (técnico), con plan de remediación
**Fecha:** 2026-06-28 (v3.0) / 2026-07-10 (formalización)
**Decisores:** Andrés + Erika + INTEGRA

## Contexto

El negocio tiene 2 roles: `admin` (Andrés/Erika) y `staff` (empleados de detalle). En v3.0 se decidió usar dos contraseñas maestras como mecanismo de auth por simplicidad. El backend valida con JWT igualmente; el mapeo en frontend es solo UX.

## Estado actual

```js
// index.html L5162
const username = pass === 'DH2025' ? 'admin' : pass === 'DH-STAFF' ? 'staff' : null;
```

```js
// index.html L4504
const refreshAuth = () => { ... }
```

```html
<!-- index.html L3592-3598 -->
<button data-tab="pos"         data-roles="admin,staff">POS</button>
<button data-tab="inventario"  data-roles="admin">INVENTARIO</button>
<button data-tab="caja"        data-roles="admin">CAJA CHICA</button>
<button data-tab="clientes"    data-roles="admin,staff">CLIENTES</button>
<button data-tab="nomina"      data-roles="admin">NÓMINA</button>
<button data-tab="agenda"      data-roles="admin,staff">AGENDA</button>
<button data-tab="dashboard"   data-roles="admin">DASHBOARD</button>
```

## Opciones consideradas

| Opción | Pros | Contras |
|---|---|---|
| **Magic strings + mapeo local** (vigente) | Cero acoplamiento, frontend decide UX | Nuevos roles = cambio de código |
| Backend devuelve lista de permisos por usuario | SOT real | Más round-trips, requiere backend |
| Permisos por endpoint en el backend | Más seguro | Frontend no sabe qué mostrar |

## Decisión

**Mantener mapeo en frontend** con la siguiente **regla de remediación**:

1. **Corto plazo (FIX-20260710-01):** extraer el mapeo a una constante `ROLES` y a una constante `ROLE_PERMISSIONS` en el top del script, documentadas.
2. **Mediano plazo:** el backend debe devolver `user.permissions: string[]` en `/auth/login` y `/auth/me`. Frontend solo consume, no decide.

## Consecuencias

### Positivas
- Simple, sin red para decidir permisos UX.
- Socios pueden ajustar permisos sin tocar backend.

### Negativas
- Si backend añade un rol, frontend no lo conoce hasta redeploy.
- No auditable: la lógica de permisos vive en HTML.

## Plan de salida (trigger para reconsiderar)

- Si el equipo crece a >5 empleados → migrar a `user.permissions` desde backend.
- Si se añaden más de 2 roles → refactor obligatorio.

## Revisión

Semestral. Próxima: 2027-01-10.
