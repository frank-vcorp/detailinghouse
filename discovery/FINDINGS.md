# Hallazgos

## FND-20260907-01 — `/citas` no está publicado

- Estado: confirmado por observación técnica.
- Evidencia: el 2026-09-07 una solicitud GET a `https://detailinghouse-tawny.vercel.app/citas` respondió HTTP 404.
- Impacto: el QR existente termina en una página sin destino útil.

## FND-20260907-02 — No hay analítica web integrada en el frontend actual

- Estado: confirmado por inspección del repositorio.
- Evidencia: `index.html` no incluye Vercel Analytics, Google Analytics, Plausible ni Umami; `vercel.json` sólo contiene rewrites, headers y proxy al API Railway.
- Impacto: una espera visual por sí sola no produce un contador persistente. Se requiere analítica o un evento persistido en backend.
