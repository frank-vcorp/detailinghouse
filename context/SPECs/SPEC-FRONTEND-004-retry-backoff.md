# SPEC-FRONTEND-004 — Reintentos con backoff exponencial en `api.request`

**ID:** `FIX-20260710-08`
**Tipo:** Robustez de red
**Prioridad:** Media
**Estimación:** 1 hora
**Origen:** `ARCH-20260710-01` §4.3 #12

---

## 1. Contexto

`api.request` (L3946) hace un único `fetch` sin reintentos. Si la API está temporalmente caída (Railway cold start, intermitencia de red, rate limit), el usuario ve un error inmediato.

**Casos donde reintentar ayuda:**
- Railway free plan: la API "duerme" tras inactividad. El primer fetch tras dormir tarda ~30s y a veces falla con 5xx/timeout
- Intermitencia de red (WiFi inestable)
- Rate limit transitorio (429)

**Casos donde NO se debe reintentar:**
- 4xx (errores del cliente: 400, 401, 403, 404) — son definitivos
- 401 (sesión expirada) — el código ya borra el JWT, no tiene sentido reintentar
- Errores de sintaxis en la respuesta (JSON parse error) — bug nuestro, no transitorio

## 2. Estado actual

```js
// L3946-3967
async request(path, options = {}) {
  const headers = { 'Content-Type': 'application/json', ...(options.headers || {}) };
  if (apiToken) headers['Authorization'] = `Bearer ${apiToken}`;
  try {
    const resp = await fetch(`${API_BASE}${path}`, { ...options, headers });
    if (resp.status === 401) {
      apiToken = null; apiUser = null; localStorage.removeItem('dh_jwt');
      throw new Error('Sesión expirada');
    }
    if (!resp.ok) {
      const err = await resp.json().catch(() => ({}));
      throw new Error(err.error || `HTTP ${resp.status}`);
    }
    const text = await resp.text();
    return text ? JSON.parse(text) : null;
  } catch (e) {
    if (e.message === 'Failed to fetch' || e.message === 'NetworkError') {
      console.warn('[API] Sin conexión, usando datos locales');
    }
    throw e;
  }
},
```

## 3. Decisión de implementación

**Reintentos solo para errores transitorios:**
- `TypeError: Failed to fetch` (network error)
- `TypeError: NetworkError` (legacy)
- HTTP 5xx (502, 503, 504, 500)
- HTTP 429 (Too Many Requests)

**NO reintentar para:**
- 4xx excepto 429 (400, 401, 403, 404) — errores del cliente, definitivos
- Errores de parsing (bug nuestro)
- Timeouts (fetch no tiene timeout built-in; el browser puede tardar minutos)

**Configuración:**
- Máximo **3 intentos totales** (1 original + 2 reintentos)
- Backoff exponencial: **1s, 2s** (antes del 2do y 3er intento)
- Solo en GETs (no en POST/PUT/DELETE — reintentar un POST puede crear duplicados)
- Log con `console.warn` cada reintento

## 4. Alcance

### In-scope

- Refactor de `api.request` para añadir reintentos
- Solo se reintenta en GETs
- 2 reintentos máximo (3 intentos totales)
- Backoff 1s, 2s
- Log con prefijo `[API]` para consistencia con warnings existentes

### Out-of-scope

- Reintento en POSTs (puede crear duplicados — feature separada)
- Reintento en PUTs/DELETEs (mismo motivo)
- Circuit breaker pattern (overkill para este caso)
- Cancelación de request (AbortController) — feature separada
- Cache local de respuestas — feature separada

## 5. Implementación

```js
async request(path, options = {}) {
  const headers = { 'Content-Type': 'application/json', ...(options.headers || {}) };
  if (apiToken) headers['Authorization'] = `Bearer ${apiToken}`;
  
  // Solo GETs se reintentan (POST/PUT/DELETE pueden crear duplicados)
  const method = (options.method || 'GET').toUpperCase();
  const isRetryable = method === 'GET';
  const maxAttempts = isRetryable ? 3 : 1;
  const backoffMs = [0, 1000, 2000]; // ms antes de cada intento (intento 1 = 0ms)
  
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    if (backoffMs[attempt - 1] > 0) {
      await new Promise(r => setTimeout(r, backoffMs[attempt - 1]));
      console.warn(`[API] Reintento ${attempt}/${maxAttempts} para ${method} ${path} tras ${backoffMs[attempt-1]}ms`);
    }
    
    try {
      const resp = await fetch(`${API_BASE}${path}`, { ...options, headers });
      
      if (resp.status === 401) {
        apiToken = null; apiUser = null; localStorage.removeItem('dh_jwt');
        throw new Error('Sesión expirada');
      }
      
      if (!resp.ok) {
        // No reintentar 4xx (errores del cliente, definitivos)
        if (resp.status >= 400 && resp.status < 500 && resp.status !== 429) {
          const err = await resp.json().catch(() => ({}));
          throw new Error(err.error || `HTTP ${resp.status}`);
        }
        // 5xx y 429: reintentar si quedan intentos
        if (attempt < maxAttempts) continue;
        const err = await resp.json().catch(() => ({}));
        throw new Error(err.error || `HTTP ${resp.status}`);
      }
      
      const text = await resp.text();
      return text ? JSON.parse(text) : null;
    } catch (e) {
      // Network errors: reintentar si quedan intentos
      const isNetworkError = e.message === 'Failed to fetch' || 
                             e.message === 'NetworkError' ||
                             e.message.includes('fetch');
      if (isNetworkError && attempt < maxAttempts) {
        console.warn(`[API] Network error en ${method} ${path}: ${e.message}`);
        continue;
      }
      // Agotados los reintentos o error no reintentable: propagar
      if (isNetworkError) {
        console.warn(`[API] Sin conexión tras ${maxAttempts} intentos, usando datos locales`);
      }
      throw e;
    }
  }
}
```

## 6. Criterios de aceptación

| ID | Criterio | Verificación |
|---|---|---|
| CA-1 | `api.request` tiene lógica de reintentos con `maxAttempts = 3` para GETs | `grep "maxAttempts" index.html` ≥ 1 |
| CA-2 | Backoff exponencial 1s, 2s implementado con `setTimeout` | `grep "backoffMs\|setTimeout" index.html` |
| CA-3 | Solo GETs se reintentan (`method === 'GET'`) | `grep "isRetryable\|method === 'GET'" index.html` |
| CA-4 | 4xx (excepto 429) NO se reintentan | `grep "resp.status >= 400" index.html` |
| CA-5 | Network errors (`Failed to fetch`) se reintentan | `grep "isNetworkError\|Failed to fetch" index.html` |
| CA-6 | Log con prefijo `[API]` para reintentos | `grep "\[API\] Reintento" index.html` ≥ 1 |
| CA-7 | Comportamiento actual intacto para POST/PUT/DELETE | Tests manuales: venta, actualizar stock, etc. siguen funcionando sin reintentos |
| CA-8 | Smoke E2E producción 18/18 OK | Playwright |
| CA-9 | Sin nuevos console errors en flujo normal | Playwright |
| CA-10 | Test de reintento: simular 503 transitorio y verificar que retry funciona | Manual o simulado con mock |

## 7. Tests

### 7.1 Test de regresión (Playwright)
Reusar `/tmp/kilo/smoke.js` o `smoke-prod.js`. Verificar 18/18 OK.

### 7.2 Test de retry (simulado)
No automatizable en Playwright fácilmente (requiere interceptar network). Alternativas:
- Verificar con `console.warn` listener que aparece el log `[API] Reintento` cuando hay fallos
- Para esta sesión, validación manual: el smoke en producción pasa, lo que prueba que el flujo normal funciona

### 7.3 Test manual de "API down"
Desconectar internet del cliente, intentar `/api/inventory`:
- Antes: error inmediato
- Después: 3 intentos con 1s + 2s de espera, luego error (total ~3s)

## 8. Riesgos

| Riesgo | Mitigación |
|---|---|
| Reintentar un GET que no es idempotente (ej. `?ts=...`) | Por convención, todos los GETs del API son idempotentes |
| Esperar 3s en producción molesta al usuario | Solo se reintenta en errores. En éxito: respuesta inmediata |
| Reentrenar al usuario a esperar | El toast "Reintentando..." puede agregarse después. Sprint futuro. |
| Backoff demasiado largo | 1s + 2s = 3s máximo de espera, aceptable |

## 9. Salida esperada

- 1 commit: `feat(api): add retry with exponential backoff for GETs (FIX-20260710-08)`
- ~30 líneas modificadas en `api.request` (L3946-3967)
- Smoke E2E 18/18 OK
- 0 regresiones

---

**Aprobado por:** INTEGRA
