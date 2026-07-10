# SPEC-FRONTEND-006: Cache invalidation para reflejo en página pública

**ID:** ARCH-20260711-05  
**Fecha:** 2026-07-11  
**Estado:** Planificado  
**Autor:** INTEGRA  
**Delegado a:** SOFIA

---

## 1. Contexto

Actualmente cuando el admin modifica productos o servicios, los cambios NO se reflejan en la página pública hasta que el usuario recarga la página. Esto es porque:

1. La página pública se renderiza una sola vez al cargar (`renderPublicProducts()`)
2. No hay mecanismo para detectar cambios en el backend
3. El navegador cachea los datos en memoria (`state.inventory`, `state.services`)

**Objetivo:** Implementar cache invalidation para que los cambios del admin se reflejen en la página pública en <5 segundos sin necesidad de recargar.

## 2. Estrategia

### 2.1 Opción A: Polling (recomendada para simplicity)

- Cada 30 segundos, verificar si hay cambios en el backend
- Si hay cambios, recargar datos y re-renderizar
- Simple, funciona con cualquier infraestructura

### 2.2 Opción B: WebSocket (overkill para este caso)

- Conexión persistente con el backend
- Backend notifica cambios en tiempo real
- Más complejo, requiere soporte en backend

### 2.3 Opción C: Manual invalidation (elegida)

- Admin invalida cache explícitamente tras cada cambio
- Frontend detecta flag de invalidation y recarga
- Balance entre simplicidad y eficiencia

**Decisión:** Opción C (manual invalidation) + polling cada 60 segundos como fallback.

## 3. Implementación

### 3.1 Flag de invalidation en localStorage

```javascript
const CACHE_VERSION_KEY = 'dh_cache_version';

function invalidatePublicCache() {
  // Incrementar versión de cache
  const currentVersion = parseInt(localStorage.getItem(CACHE_VERSION_KEY) || '0');
  localStorage.setItem(CACHE_VERSION_KEY, String(currentVersion + 1));
  
  // Notificar a otras pestañas
  window.dispatchEvent(new CustomEvent('cache-invalidated', {
    detail: { version: currentVersion + 1 }
  }));
}
```

### 3.2 Detectar invalidation en página pública

```javascript
// Al cargar la página pública
function initPublicPage() {
  // Cargar datos iniciales
  loadPublicData();
  
  // Escuchar cambios de cache
  window.addEventListener('cache-invalidated', (e) => {
    console.log('Cache invalidado, recargando datos...');
    loadPublicData();
  });
  
  // Polling cada 60 segundos
  setInterval(() => {
    checkForUpdates();
  }, 60000);
  
  // Escuchar cambios de otras pestañas
  window.addEventListener('storage', (e) => {
    if (e.key === CACHE_VERSION_KEY) {
      console.log('Cache invalidado desde otra pestaña');
      loadPublicData();
    }
  });
}

async function checkForUpdates() {
  try {
    // Verificar si hay cambios comparando timestamps
    const lastUpdate = await api.request('/inventory/last-update');
    const currentLastUpdate = localStorage.getItem('dh_last_inventory_update');
    
    if (lastUpdate && lastUpdate !== currentLastUpdate) {
      console.log('Detectados cambios en inventario');
      localStorage.setItem('dh_last_inventory_update', lastUpdate);
      loadPublicData();
    }
  } catch (err) {
    console.error('Error al verificar actualizaciones:', err);
  }
}
```

### 3.3 Endpoint backend para last-update

Agregar al backend (`routes/inventory.js`):

```javascript
// GET /api/inventory/last-update — Timestamp de última actualización (público)
router.get('/last-update', async (req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT MAX(updated_at) as last_update FROM inventory'
    );
    res.json(rows[0].last_update);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
```

Similar para servicios:

```javascript
// GET /api/services/last-update
router.get('/last-update', async (req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT MAX(updated_at) as last_update FROM services'
    );
    res.json(rows[0].last_update);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
```

### 3.4 Recargar datos públicos

```javascript
async function loadPublicData() {
  try {
    // Cargar productos
    const products = await api.request('/inventory');
    state.inventory = products;
    
    // Cargar servicios
    const services = await api.request('/services');
    state.services = services;
    
    // Re-renderizar página pública
    renderPublicProducts('todos');
    renderServicesStrip();
    
    console.log('Datos públicos recargados');
  } catch (err) {
    console.error('Error al recargar datos públicos:', err);
    // Mantener datos existentes (fallback)
  }
}
```

### 3.5 Invalidar cache tras cambios del admin

Modificar las funciones de guardar/eliminar productos y servicios:

```javascript
// En SPEC-FRONTEND-003 (productos)
document.getElementById('saveProductBtn')?.addEventListener('click', async () => {
  // ... código existente ...
  
  if (result.ok) {
    // ... actualizar estado local ...
    
    // Invalidar cache
    invalidatePublicCache();
    
    showToast('Producto actualizado correctamente', 'success');
  }
});

document.getElementById('confirmDeleteBtn')?.addEventListener('click', async () => {
  // ... código existente ...
  
  if (result.ok) {
    // ... remover del estado local ...
    
    // Invalidar cache
    invalidatePublicCache();
    
    showToast('Producto eliminado correctamente', 'success');
  }
});

// En SPEC-FRONTEND-004 (servicios)
document.getElementById('saveServiceBtn')?.addEventListener('click', async () => {
  // ... código existente ...
  
  // Invalidar cache
  invalidatePublicCache();
});

document.getElementById('confirmDeleteServiceBtn')?.addEventListener('click', async () => {
  // ... código existente ...
  
  // Invalidar cache
  invalidatePublicCache();
});
```

## 4. Optimizaciones

### 4.1 Debounce de polling

```javascript
let pollingTimer = null;

function startPolling() {
  if (pollingTimer) clearInterval(pollingTimer);
  
  pollingTimer = setInterval(() => {
    checkForUpdates();
  }, 60000); // 60 segundos
}

function stopPolling() {
  if (pollingTimer) {
    clearInterval(pollingTimer);
    pollingTimer = null;
  }
}

// Detener polling cuando la pestaña no está visible
document.addEventListener('visibilitychange', () => {
  if (document.hidden) {
    stopPolling();
  } else {
    startPolling();
    checkForUpdates(); // Verificar inmediatamente al volver
  }
});
```

### 4.2 Cache de respuestas HTTP

```javascript
// En api.request, agregar cache para GET
const CACHE_DURATION = 30000; // 30 segundos
const cache = new Map();

async function apiRequest(path, options = {}) {
  const cacheKey = `${path}:${JSON.stringify(options)}`;
  
  // Solo cachear GET requests
  if (options.method === 'GET' || !options.method) {
    const cached = cache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < CACHE_DURATION) {
      return cached.data;
    }
  }
  
  // Hacer request
  const response = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(apiToken && { 'Authorization': `Bearer ${apiToken}` }),
      ...options.headers
    }
  });
  
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
  
  const data = await response.json();
  
  // Cachear respuesta
  if (options.method === 'GET' || !options.method) {
    cache.set(cacheKey, { data, timestamp: Date.now() });
  }
  
  return data;
}
```

### 4.3 Indicador visual de actualización

```javascript
function showUpdateIndicator() {
  const indicator = document.createElement('div');
  indicator.className = 'update-indicator';
  indicator.innerHTML = '<i data-lucide="refresh-cw"></i> Actualizando...';
  document.body.appendChild(indicator);
  lucide.createIcons();
  
  setTimeout(() => {
    indicator.classList.add('fade-out');
    setTimeout(() => indicator.remove(), 300);
  }, 1000);
}

// CSS
.update-indicator {
  position: fixed;
  top: 20px;
  right: 20px;
  background: var(--color-primary);
  color: white;
  padding: 12px 20px;
  border-radius: var(--border-radius-md);
  box-shadow: var(--shadow-md);
  display: flex;
  align-items: center;
  gap: 8px;
  z-index: 9999;
  animation: slideIn 0.3s ease;
}

.update-indicator.fade-out {
  animation: fadeOut 0.3s ease;
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

@keyframes fadeOut {
  from {
    opacity: 1;
  }
  to {
    opacity: 0;
  }
}
```

## 5. Criterios de aceptación

- [ ] CA-1: Cambios del admin se reflejan en página pública en <5 segundos
- [ ] CA-2: No es necesario recargar la página manualmente
- [ ] CA-3: Polling cada 60 segundos como fallback
- [ ] CA-4: Polling se detiene cuando la pestaña no está visible
- [ ] CA-5: Indicador visual cuando se recargan datos
- [ ] CA-6: Cache HTTP de 30 segundos para reducir carga al backend
- [ ] CA-7: Sincronización entre pestañas (localStorage events)
- [ ] CA-8: Fallback a datos existentes si falla la recarga
- [ ] CA-9: No rompe funcionalidad existente
- [ ] CA-10: Performance aceptable (no más de 1 request/minuto por usuario)

## 6. Validaciones

1. Abrir página pública en pestaña 1
2. Abrir admin en pestaña 2
3. Modificar un producto en admin
4. Guardar cambios
5. Verificar que en pestaña 1 el producto se actualiza automáticamente
6. Esperar 60 segundos
7. Verificar que el polling funciona (ver network tab)
8. Cambiar a otra pestaña del navegador
9. Esperar 2 minutos
10. Volver a la página pública
11. Verificar que el polling se reanuda
12. Modificar otro producto en admin
13. Verificar que se refleja en <5 segundos

## 7. Timeline

- **Día 1:** Implementar invalidation + endpoints backend
- **Día 2:** Polling + sincronización entre pestañas
- **Día 3:** Optimizaciones + testing

## 8. Riesgos

- **Riesgo bajo:** Polling puede generar carga adicional al backend
- **Mitigación:** Polling cada 60 segundos + cache HTTP de 30 segundos
- **Riesgo medio:** Sincronización entre pestañas puede ser compleja
- **Mitigación:** Usar localStorage events (nativo del navegador)

## 9. Dependencias

- SPEC-FRONTEND-003 (productos) — debe estar listo
- SPEC-FRONTEND-004 (servicios) — debe estar listo
- SPEC-BACKEND-001 (servicios) — debe estar listo

## 10. Rollback

Si hay problemas:
1. Desactivar polling (comentar `setInterval`)
2. Volver a comportamiento anterior (recarga manual)
