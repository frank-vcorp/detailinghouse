# Escenarios funcionales

## FLOW-20260907-01 — QR a WhatsApp

- Estado: confirmado por Frank el 2026-09-07.
1. La persona escanea el QR existente.
2. Abre `/citas` y se registra una visita.
3. Ve una pantalla de marca con el mensaje `Te estamos conectando con WhatsApp` y una cuenta breve.
4. Puede pulsar `Abrir WhatsApp ahora` sin esperar.
5. Al pulsar o terminar la cuenta se registra la salida y se abre WhatsApp con mensaje prellenado.

## SCN-20260907-01 — Redirección automática exitosa

- Dado que una persona abre `/citas`, cuando transcurren aproximadamente 3 segundos, entonces se abre el chat correcto de WhatsApp con el mensaje aprobado.

## SCN-20260907-02 — Redirección bloqueada o WhatsApp no abre

- Dado que el navegador no completa la redirección automática, entonces la pantalla conserva un botón claro y funcional para intentar abrir WhatsApp manualmente.
