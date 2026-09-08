# Decisiones funcionales

## DEC-20260907-01 — Conservar `/citas` como enlace intermedio

- Estado: confirmada.
- Fecha: 2026-09-07.
- Decisión: conservar la URL codificada en el QR y usarla como paso intermedio antes de abrir WhatsApp.
- Razón: evita reimprimir el QR y permite medir su uso.
- Relacionado: `BR-20260907-01`, `FLOW-20260907-01`.

## DEC-20260907-02 — Aprobar transición y medición doble

- Estado: confirmada por Frank el 2026-09-07.
- Decisión: mostrar una pantalla de 3 segundos con botón inmediato, abrir WhatsApp con mensaje prellenado y medir por separado visitas a `/citas` y aperturas de WhatsApp.
- Consulta: ambos totales se mostrarán internamente en el dashboard admin.
- Mensaje aprobado: `Hola, escaneé el QR de DetailingHouse y quiero agendar un servicio. ¿Me ayudan con la disponibilidad?`
