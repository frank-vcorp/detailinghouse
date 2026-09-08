# SPEC-20260907-01 — QR `/citas` a WhatsApp con contador

- Estado: READY_FOR_SOFIA.
- Prioridad: P0 por QR físico actualmente roto.
- Arquitectura: `ARCH-20260907-01`.
- Origen funcional: `discovery/INDEX.md`.

## Resultado técnico esperado

`/citas` muestra una pantalla móvil de DetailingHouse durante 3 segundos, registra una visita y abre `https://wa.me/524461153815` con el mensaje aprobado. Un botón permite abrirlo inmediatamente. El dashboard admin muestra totales persistentes de visitas y aperturas.

## Alcance incluido

### Frontend `frank-vcorp/detailinghouse`

- Crear `citas.html` autocontenido, responsive y accesible, reutilizando activos locales existentes cuando convenga.
- Texto principal: `Te estamos conectando con WhatsApp`.
- Mostrar cuenta/progreso de 3 segundos y botón `Abrir WhatsApp ahora`.
- URL destino: `https://wa.me/524461153815?text=<mensaje codificado>`.
- Mensaje exacto: `Hola, escaneé el QR de DetailingHouse y quiero agendar un servicio. ¿Me ayudan con la disponibilidad?`
- Registrar `visit` al cargar y `whatsapp_open` una sola vez antes de la navegación, con `fetch(..., { keepalive: true })` y guardas en `sessionStorage` para evitar doble conteo por la misma pestaña.
- Si el POST falla, continuar de todos modos hacia WhatsApp.
- Añadir rewrite explícito `/citas` → `/citas.html` antes del catch-all en `vercel.json`.
- Añadir dos KPI al dashboard admin: `Visitas desde QR` y `Aperturas de WhatsApp`.
- Integrar cliente GET autenticado y render del resumen en `index.html` y `admin.html` mediante edición selectiva; prohibido copiar un archivo sobre el otro.

### Backend `frank-vcorp/detailinghouse-api`

- Tabla `qr_event_counters`: `event VARCHAR(32) PRIMARY KEY`, `total BIGINT NOT NULL DEFAULT 0`, `updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`, con restricción para `visit` y `whatsapp_open`.
- Incluir creación idempotente en `db/migrate.js` y en la auto-migración vigente de `server.js`.
- `POST /api/qr-events` público:
  - Body `{ "event": "visit" | "whatsapp_open" }`.
  - Evento inválido: HTTP 400.
  - Evento válido: incremento atómico mediante `INSERT ... ON CONFLICT ... DO UPDATE`; HTTP 202 con `{ "ok": true }`.
- `GET /api/qr-events/summary` protegido por `authMiddleware` y `adminOnly`:
  - HTTP 200 con `{ "visit": <entero>, "whatsapp_open": <entero> }`.
  - Debe devolver cero para eventos aún inexistentes.
- Montar la ruta en `server.js`.
- Sin dependencias nuevas y sin almacenar información personal.

## Fuera de alcance

- Crear citas automáticamente, calendario, formulario o captura de datos personales.
- Métrica de usuarios únicos, atribución por campaña o antifraude.
- Mostrar contadores en la página pública.
- Cambiar otros enlaces de WhatsApp del sitio.
- Commit, push, despliegue, migración en producción o eliminación de datos sin autorización explícita.

## Contratos protegidos

- `/admin` y `autoOpenAdmin` deben seguir funcionando.
- No modificar el número ni mensajes de otros CTA existentes.
- No romper CSP, proxy `/api`, login, dashboard de ventas ni roles.
- `index.html` y `admin.html` no se sincronizan mediante `cp`.

## Criterios verificables

1. `/citas` local sirve la nueva pantalla, no el home ni un 404.
2. La cuenta dura 3 segundos y el botón funciona desde el primer render.
3. Navegación automática y manual usan número y mensaje exactos.
4. Cada pestaña emite como máximo un `visit` y un `whatsapp_open`.
5. Un fallo de red del contador no impide abrir WhatsApp.
6. POST válido incrementa de forma atómica; POST inválido devuelve 400.
7. GET sin token devuelve 401; con token staff devuelve 403; con admin devuelve ambos enteros.
8. Dashboard admin muestra ambos totales sin alterar KPIs de ventas.
9. `/admin` conserva sidebar, contenido y `autoOpenAdmin`.
10. No hay errores de consola ni requests fallidos no controlados en el recorrido final.

## Archivos o módulos permitidos

- Frontend: `citas.html`, `vercel.json`, `index.html`, `admin.html` y pruebas existentes aplicables.
- Backend: `routes/qr-events.js`, `server.js`, `db/migrate.js` y pruebas aplicables.
- No tocar archivos modificados previamente por Frank fuera de los bloques estrictamente necesarios.

## Validación

- V1 frontend: JSON válido de `vercel.json`; prueba dirigida de carga, temporizador, botón y payloads.
- V1 backend: `node --check` en archivos modificados; prueba dirigida de validación/auth/SQL con entorno desechable o mock mínimo existente.
- V2 SOFIA: suite disponible de ambos repos una sola vez; si no existe, documentar N/A y ejecutar smoke local integrado.
- V3 GEMINI: Playwright final en entorno desplegado autorizado, verificando `/citas`, temporizador, fallback manual, dashboard, consola y red. Sin despliegue, estado VERIFYING.

## Riesgos, rollback y gates

- Riesgo medio: contrato API público más migración aditiva.
- La migración es idempotente y no altera tablas existentes.
- Gate final GEMINI obligatorio por API pública, persistencia y despliegue web.
- Push, deploy y ejecución en producción requieren autorización explícita de Frank.

## Prohibido inferir

- Que una visita equivale a una persona única o a una cita cerrada.
- Que el socio confirmó una cita sólo porque se abrió WhatsApp.
- Que existe permiso para publicar o migrar producción.
