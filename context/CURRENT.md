# CURRENT — DetailingHouse

## WIP=1

- Incremento: QR `/citas` con transición y medición hacia WhatsApp.
- Modo: CONTRATO.
- Estado: **VERIFYING** (`FEATURE-20260907-01`).
- Fuente funcional: `discovery/INDEX.md`.
- Evidencia: SPEC-20260907-01, ADR-20260907-01, IMPL-20260907-01; V1 backend PASS 7/7, V2 backend/frontend PASS, delta V1 12/12 PASS. Código local en frontend y backend `/home/frank/repos/detailinghouse-api`.
- ADR/SPEC: `ARCH-20260907-01` / `SPEC-20260907-01`.
- Próximo paso: gate final GEMINI V3 en entorno publicado (staging o producción), previa autorización explícita de Frank para commit/push/deploy de ambos repos y migración aditiva.
- Restricción: no modificar `admin.html` mediante copia desde `index.html`.
