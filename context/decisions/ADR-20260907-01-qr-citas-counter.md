# ARCH-20260907-01 — Página QR con contadores agregados

- Estado: aceptada.
- Fecha: 2026-09-07.
- Origen: `DEC-20260907-01`, `DEC-20260907-02`, `BR-20260907-01`, `BR-20260907-02`.

## Contexto

El QR físico ya apunta a `/citas`, que hoy responde 404. El flujo aprobado requiere una transición de 3 segundos hacia WhatsApp y dos totales internos: visitas y aperturas.

## Decisión

1. Publicar `citas.html` y resolver `/citas` mediante un rewrite explícito anterior al catch-all.
2. Persistir únicamente contadores agregados en PostgreSQL, sin IP, user-agent, teléfono ni identificadores personales.
3. Exponer un endpoint público limitado a dos eventos permitidos (`visit`, `whatsapp_open`) y protegido por el rate limit global.
4. Exponer el resumen sólo con JWT de rol admin.
5. Mostrar los dos totales en el dashboard existente.
6. El fallo del contador nunca bloquea ni retrasa la salida a WhatsApp.

## Alternativas descartadas

- Sólo Vercel Analytics: no satisface la consulta aprobada dentro del panel admin.
- Registrar cada visita individual: añade datos y almacenamiento innecesarios para dos totales.
- Redirección HTTP inmediata: elimina la transición aprobada y no permite distinguir visita de apertura.

## Consecuencias y seguridad

- Se añade una tabla agregada y un contrato API pequeño.
- El contador representa interacciones, no personas únicas ni citas confirmadas.
- El endpoint público puede recibir tráfico automatizado; allowlist, validación y rate limiting limitan abuso, pero no lo convierten en una métrica antifraude.
- Rollback: retirar rewrite/página/UI/ruta; la tabla agregada puede conservarse sin impacto o eliminarse sólo con autorización destructiva separada.
