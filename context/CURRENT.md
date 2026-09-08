# CURRENT — DetailingHouse

## WIP=1

- Incremento: QR `/citas` con transición y medición hacia WhatsApp.
- Modo: CONTRATO.
- Estado: **BLOCKED** (`FEATURE-20260907-01`) — GEMINI V3.
- Fuente funcional: `discovery/INDEX.md`.
- Evidencia: SPEC-20260907-01, ADR-20260907-01, IMPL-20260907-01; V1 backend PASS 7/7, V2 backend/frontend PASS, delta V1 12/12 PASS; producción funcional: backend `5d4033c` Railway + frontend `3b345de` Vercel + smoke PASS + migración aditiva aplicada.
- ADR/SPEC: `ARCH-20260907-01` / `SPEC-20260907-01`.
- Bloqueo: GEMINI V3 — sesión `ses_f819ef40fffee140g2VjilIXHZ` denegada tras 2 intentos con error: `Access to model denied. Please make sure you are eligible for using the model.`
- Próximo paso: reanudar la misma sesión GEMINI `ses_f819ef40fffee140g2VjilIXHZ` cuando el modelo esté habilitado; no repetir implementación ni V1/V2.
- Restricción: no modificar `admin.html` mediante copia desde `index.html`.
