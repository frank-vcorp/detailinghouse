# ADR-20260710-01 — Vanilla JS, sin framework (React/Vue/Svelte)

**Estado:** Aceptado
**Fecha:** 2026-06-25 (decisión original) / 2026-07-10 (formalización INTEGRA)
**Decisores:** Andrés (socio) + Erika (socia) + INTEGRA

## Contexto

DetailingHouse es un sitio público de marketing + panel admin para un negocio de detallado automotriz de 2-3 personas. Los socios editan el HTML directamente y no tienen experiencia con frameworks JS.

## Opciones consideradas

| Opción | Pros | Contras |
|---|---|---|
| **Vanilla JS + HTML estático** (elegida) | Cero build, deploy = upload, socios editan directo | Código escala peor, sin tipos |
| React + Vite | Componentes, ecosistema | Build complejo, requiere Node, curva de aprendizaje |
| Next.js | SSR/SEO | Overkill, hosting distinto, vendor lock-in |
| Astro | Híbrido estático+islas | Introduce tooling nuevo |

## Decisión

**Mantener Vanilla JS, sin framework, sin build, sin CDN.**

## Consecuencias

### Positivas
- Deploy = subir `index.html` a Netlify. Cero configuración.
- Socios pueden editar precios, productos y secciones sin conocer React.
- Time-to-first-byte óptimo (HTML + JS inline, sin bundling).
- Cero dependencias externas = cero CVEs por ahora.

### Negativas (aceptadas)
- El código se vuelve monolítico (5,333 líneas en un solo archivo).
- Refactors manuales son riesgosos (ver `FIX-20260710-01`).
- Sin tipos = errores en runtime.

## Plan de salida (trigger para reconsiderar)

Migrar a framework **solo si**:
- El negocio supera 5 módulos admin con estado compartido complejo
- Se necesita SSR para SEO avanzado (multi-idioma, multi-sucursal)
- Se necesita una app móvil nativa que comparta lógica
- El equipo de desarrollo crece a >2 personas full-time

## Revisión

Re-evaluar en v6.0 (estimado 2027-Q2).
