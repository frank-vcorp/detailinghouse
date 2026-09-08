# Baseline funcional

## Incremento: QR de citas a WhatsApp

El QR ya distribuido apunta a `https://detailinghouse-tawny.vercel.app/citas`. Esa URL debe conservarse para no reimprimir el QR.

La persona que escanea debe pasar por una pantalla breve de DetailingHouse y terminar en una conversación de WhatsApp atendida por el socio, quien realizará la agenda manualmente.

El paso intermedio debe permitir medir el uso del QR sin convertirlo en un formulario de citas ni exigir datos personales.

## Alcance inicial

- Resolver `/citas` como una página funcional.
- Mostrar una transición breve y clara hacia WhatsApp.
- Registrar la llegada desde el QR y, preferentemente, también la salida a WhatsApp.
- Redirección automática con alternativa manual si el navegador la bloquea.

## Fuera de alcance actual

- Reserva automática de horarios.
- Sincronización con Google Calendar.
- Captura de nombre, teléfono, vehículo o dirección en la página intermedia.
- Reimpresión o sustitución del QR existente.
