# ADR-20260710-05 — Sanitización XSS vía `escapeHtml` (sin DOMPurify)

**Estado:** Aceptado
**Fecha:** 2026-07-10
**Decisores:** INTEGRA
**Aplicabilidad:** sprints `FIX-20260710-07` y futuros helpers que acepten user-input

## Contexto

El frontend tiene varios lugares donde se inyecta HTML con datos del backend (API responses). El más crítico es `dhAdminModal` que hace `innerHTML` del `body`, donde 2 callers (`L4885` editar stock, `L5003` actualizar cita) interpolan datos user-input sin escapar.

## Opciones consideradas

| Opción | Pros | Contras |
|---|---|---|
| **`escapeHtml` helper inline** (elegida) | Cero dependencias, 1 línea, cubre el caso | Solo escapa 5 chars (`&<>"'`), no cubre URLs/JS contexts |
| `DOMPurify` library | Robusto, sanitiza todo (URLs, attrs, JS) | +~20KB, +1 dependencia externa, sobreingeniería para 2 callers |
| Refactor a `HTMLElement` API | Sin strings HTML, imposible XSS | Cambio mayor, afecta a todos los callers existentes |
| `textContent` para todo | Imposible XSS | Rompe el template HTML legítimo (inputs, selects) |

## Decisión

**Helper `escapeHtml(s)` inline en el IIFE del script principal**, aplicado en los 2 callers de `dhAdminModal` que interpolan user-input. Se documenta la obligación de usarlo en futuros callers.

```js
const escapeHtml = s => String(s == null ? '' : s)
  .replace(/[&<>"']/g, c => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  }[c]));
```

## Consecuencias

### Positivas
- Cero dependencias externas → cero CVEs adicionales
- Cambio mínimo (3 líneas helper + ~10 líneas en callers)
- Cubre el vector XSS conocido (inyección de HTML en valores)

### Negativas (aceptadas)
- `escapeHtml` solo cubre 5 caracteres. **No** sanitiza URLs (`javascript:`), atributos `on*` complejos, ni contextos JS.
- Cobertura limitada a los 2 callers auditados. Si en el futuro se añade un nuevo caller a `dhAdminModal` con user-input, hay que acordarse de usar `escapeHtml`.
- `script-src 'unsafe-inline'` sigue habilitado (FIX-20260710-03 separa esta preocupación).

## Plan de salida (trigger para reconsiderar)

- Si en el futuro hay > 5 callers de `dhAdminModal` con user-input → migrar a DOMPurify
- Si se necesita sanitizar URLs/JS contexts → migrar a DOMPurify
- Si el equipo crece a > 2 devs → considerar framework con sanitización automática (React, Vue)

## Revisión

Trimestral. Próxima: 2026-10-10.

---

**Relacionado:** `SPEC-FRONTEND-002` (implementación)
