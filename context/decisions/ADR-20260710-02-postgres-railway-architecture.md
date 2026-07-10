# ADR-20260710-02 — PostgreSQL + Railway (API) + Netlify (frontend)

**Estado:** Aceptado (migración v3.0 → v4.0 completada 2026-07-07)
**Fecha:** 2026-07-07 (migración) / 2026-07-10 (formalización INTEGRA)
**Decisores:** Andrés + Erika + INTEGRA

## Contexto

En v3.0 los datos vivían en `localStorage` del navegador donde se usaba el panel. Esto impedía:
- Sincronización entre 2-3 dispositivos (admin en celular + laptop)
- Respaldo automático
- Roles diferenciados con auth real
- Multi-empleado simultáneo

## Opciones consideradas

| Opción | Pros | Contras |
|---|---|---|
| **PostgreSQL + Railway + Netlify** (elegida) | Costo ~$5/mes, backups, multi-device, JWT estándar | Requiere backend desacoplado |
| Supabase + Netlify | BaaS rápido, realtime | Vendor lock-in, costos escalan |
| Firebase Firestore | Realtime out-of-the-box | NoSQL, esquema rígido, costos impredecibles |
| MongoDB Atlas | Flexible | NoSQL no encaja con dominio relacional (clientes↔ventas↔citas) |
| Qovery / Render / Fly.io | Alternativas a Railway | Menos maduros al momento |

## Decisión

**Frontend** en Netlify (CDN global, HTTPS gratis, deploy desde GitHub).
**Backend** Node.js + Express en Railway.
**DB** PostgreSQL managed por Railway.
**Auth** JWT con secreto compartido backend ↔ frontend, persistido en `localStorage('dh_jwt')`.

## Consecuencias

### Positivas
- ~$5/mes total, predecible.
- Datos en la nube con backups automáticos de Railway.
- Multi-dispositivo y multi-empleado real.
- CORS configurado para Netlify → backend aislado.

### Negativas (aceptadas)
- Backend en repo separado del frontend (no versionado junto).
- `API_BASE` hardcodeada en JS (cambio de entorno = redeploy).
- Si Railway se duerme por inactividad, primera petición tarda.
- Sin API Gateway, sin rate limiting distribuido.

## Plan de salida (trigger para reconsiderar)

- Si costos Railway >$30/mes → migrar a Supabase o self-hosted en VPS.
- Si latency CDN >300ms en LATAM → considerar Cloudflare Pages.
- Si la app requiere realtime → agregar WebSockets (Railway lo soporta).

## Revisión

Trimestral. Próxima: 2026-10-10.
