# SPEC-FRONTEND-004: UI admin CRUD servicios

**ID:** ARCH-20260711-04  
**Fecha:** 2026-07-11  
**Estado:** Planificado  
**Autor:** INTEGRA  
**Delegado a:** SOFIA

---

## 1. Contexto

Actualmente los 8 servicios del POS están hardcodeados en el frontend (`serviceCatalog` línea 3932). No hay forma de editarlos desde el admin.

**Objetivo:** Agregar sección "Servicios" en el admin con CRUD completo usando los nuevos endpoints del backend (SPEC-BACKEND-001).

## 2. Requisitos funcionales

### 2.1 Lista de servicios

**Tabla:**
| ID | Nombre | Precio | Categoría | Duración | Estado | Acciones |
|----|--------|--------|-----------|----------|--------|----------|
| SRV-001 | Paquete Elite | $2,200 | Principal | - | ✅ Activo | Editar | Eliminar |
| SRV-004 | Lavado de motor | $500 | Secundario | 60 min | ✅ Activo | Editar | Eliminar |

### 2.2 Crear servicio nuevo

**Formulario:**
- ID (text, requerido, formato SRV-XXX)
- Nombre (text, requerido)
- Precio (number, requerido, >= 0)
- Descripción (textarea, opcional)
- Emoji (text, 1 caracter)
- Categoría (select: principal/secundario)
- Duración (number, opcional, en minutos)

### 2.3 Editar servicio

**Modal con todos los campos editables:**
- Nombre
- Precio
- Descripción
- Emoji
- Categoría
- Duración

### 2.4 Eliminar servicio

**Modal de confirmación** (soft delete, marca `active = false`)

## 3. Especificación de UI

### 3.1 Nueva sección "Servicios" en sidebar

```html
<a href="#" class="nav-item" data-tab="services">
  <i data-lucide="concierge-bell"></i>
  <span>Servicios</span>
</a>
```

### 3.2 Layout de la sección

```html
<section id="section-services" class="admin-section">
  <div class="section-header">
    <h2>Servicios</h2>
    <button class="btn btn-primary" id="addServiceBtn">
      <i data-lucide="plus"></i>
      Agregar servicio
    </button>
  </div>
  
  <div class="section-content">
    <table class="services-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Emoji</th>
          <th>Nombre</th>
          <th>Precio</th>
          <th>Categoría</th>
          <th>Duración</th>
          <th>Estado</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody id="servicesTableBody">
        <!-- Filas generadas dinámicamente -->
      </tbody>
    </table>
  </div>
</section>
```

### 3.3 Modal de creación/edición

```html
<div class="modal-overlay" id="serviceModal">
  <div class="modal">
    <div class="modal-header">
      <h3 id="serviceModalTitle">Agregar servicio</h3>
      <button class="modal-close" data-close-modal>&times;</button>
    </div>
    <div class="modal-body">
      <form id="serviceForm">
        <input type="hidden" id="serviceId" />
        <input type="hidden" id="serviceMode" value="create" />
        
        <div class="form-group">
          <label for="serviceIdInput">ID *</label>
          <input type="text" id="serviceIdInput" placeholder="SRV-009" pattern="SRV-\d{3}" required />
          <small class="form-text">Formato: SRV-XXX (ejemplo: SRV-009)</small>
        </div>
        
        <div class="form-group">
          <label for="serviceName">Nombre *</label>
          <input type="text" id="serviceName" required />
        </div>
        
        <div class="form-row">
          <div class="form-group">
            <label for="servicePrice">Precio *</label>
            <input type="number" id="servicePrice" min="0" step="0.01" required />
          </div>
          <div class="form-group">
            <label for="serviceDuration">Duración (minutos)</label>
            <input type="number" id="serviceDuration" min="0" step="1" placeholder="60" />
          </div>
        </div>
        
        <div class="form-row">
          <div class="form-group">
            <label for="serviceEmoji">Emoji</label>
            <input type="text" id="serviceEmoji" maxlength="2" placeholder="🚗" />
          </div>
          <div class="form-group">
            <label for="serviceCategory">Categoría *</label>
            <select id="serviceCategory" required>
              <option value="principal">Principal</option>
              <option value="secundario">Secundario</option>
            </select>
          </div>
        </div>
        
        <div class="form-group">
          <label for="serviceDescription">Descripción</label>
          <textarea id="serviceDescription" rows="4"></textarea>
        </div>
      </form>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" data-close-modal>Cancelar</button>
      <button class="btn btn-primary" id="saveServiceBtn">Guardar</button>
    </div>
  </div>
</div>
```

### 3.4 Modal de confirmación de eliminación

```html
<div class="modal-overlay" id="deleteServiceModal">
  <div class="modal modal-sm">
    <div class="modal-header">
      <h3>Confirmar eliminación</h3>
      <button class="modal-close" data-close-modal>&times;</button>
    </div>
    <div class="modal-body">
      <p>¿Estás seguro de que deseas eliminar este servicio?</p>
      <div class="service-info">
        <strong id="deleteServiceId"></strong>
        <span id="deleteServiceName"></span>
      </div>
      <p class="text-muted">Esta acción no se puede deshacer. El servicio quedará inactivo pero no se borrará de la base de datos.</p>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" data-close-modal>Cancelar</button>
      <button class="btn btn-danger" id="confirmDeleteServiceBtn">Eliminar</button>
    </div>
  </div>
</div>
```

## 4. JavaScript

### 4.1 Estado global

Agregar a `state`:

```javascript
const state = {
  // ... estado existente
  services: [],  // Nuevo: lista de servicios desde backend
};
```

### 4.2 Cargar servicios al iniciar

```javascript
async function loadServices() {
  try {
    const services = await api.request('/services');
    state.services = services;
    renderServicesTable();
  } catch (err) {
    console.error('Error al cargar servicios:', err);
    // Fallback a serviceCatalog hardcodeado
    state.services = serviceCatalog.map(s => ({
      ...s,
      description: '',
      emoji: getEmojiForService(s.id),
      category: s.id.startsWith('SRV-00') && ['SRV-001','SRV-002','SRV-003'].includes(s.id) ? 'principal' : 'secundario',
      duration: null,
      active: true
    }));
    renderServicesTable();
  }
}

function getEmojiForService(id) {
  const emojis = {
    'SRV-001': '🚗',
    'SRV-002': '✨',
    'SRV-003': '🧼',
    'SRV-004': '⚙️',
    'SRV-005': '🛡️',
    'SRV-006': '💡',
    'SRV-007': '💺',
    'SRV-008': '🌬️'
  };
  return emojis[id] || '⭐';
}
```

### 4.3 Renderizar tabla

```javascript
function renderServicesTable() {
  const tbody = document.getElementById('servicesTableBody');
  if (!tbody) return;
  
  tbody.innerHTML = state.services.map(service => `
    <tr data-id="${escapeHtml(service.id)}">
      <td><code>${escapeHtml(service.id)}</code></td>
      <td class="emoji-cell">${escapeHtml(service.emoji || '⭐')}</td>
      <td><strong>${escapeHtml(service.name)}</strong></td>
      <td>${formatCurrency(service.price)}</td>
      <td>
        <span class="badge badge-${service.category}">
          ${service.category === 'principal' ? 'Principal' : 'Secundario'}
        </span>
      </td>
      <td>${service.duration ? service.duration + ' min' : '-'}</td>
      <td>
        <span class="status-badge ${service.active !== false ? 'status-active' : 'status-inactive'}">
          ${service.active !== false ? '✅ Activo' : '❌ Inactivo'}
        </span>
      </td>
      <td class="actions">
        <button class="btn btn-sm btn-secondary" data-edit-service="${escapeHtml(service.id)}">
          <i data-lucide="edit"></i> Editar
        </button>
        <button class="btn btn-sm btn-danger" data-delete-service="${escapeHtml(service.id)}">
          <i data-lucide="trash-2"></i> Eliminar
        </button>
      </td>
    </tr>
  `).join('');
  
  lucide.createIcons();
}
```

### 4.4 Abrir modal de creación

```javascript
document.getElementById('addServiceBtn')?.addEventListener('click', () => {
  // Reset formulario
  document.getElementById('serviceForm').reset();
  document.getElementById('serviceMode').value = 'create';
  document.getElementById('serviceModalTitle').textContent = 'Agregar servicio';
  document.getElementById('serviceIdInput').disabled = false;
  
  // Abrir modal
  document.getElementById('serviceModal').classList.add('open');
});
```

### 4.5 Abrir modal de edición

```javascript
document.getElementById('servicesTableBody')?.addEventListener('click', (e) => {
  const editBtn = e.target.closest('[data-edit-service]');
  if (!editBtn) return;
  
  const id = editBtn.dataset.editService;
  const service = state.services.find(s => s.id === id);
  if (!service) return;
  
  // Llenar formulario
  document.getElementById('serviceId').value = service.id;
  document.getElementById('serviceIdInput').value = service.id;
  document.getElementById('serviceIdInput').disabled = true;  // No permitir cambiar ID
  document.getElementById('serviceName').value = service.name;
  document.getElementById('servicePrice').value = service.price;
  document.getElementById('serviceDuration').value = service.duration || '';
  document.getElementById('serviceEmoji').value = service.emoji || '';
  document.getElementById('serviceCategory').value = service.category;
  document.getElementById('serviceDescription').value = service.description || '';
  document.getElementById('serviceMode').value = 'edit';
  document.getElementById('serviceModalTitle').textContent = 'Editar servicio';
  
  // Abrir modal
  document.getElementById('serviceModal').classList.add('open');
});
```

### 4.6 Guardar servicio

```javascript
document.getElementById('saveServiceBtn')?.addEventListener('click', async () => {
  const mode = document.getElementById('serviceMode').value;
  const id = document.getElementById('serviceIdInput').value.trim();
  
  const data = {
    name: document.getElementById('serviceName').value.trim(),
    price: parseFloat(document.getElementById('servicePrice').value),
    duration: document.getElementById('serviceDuration').value ? parseInt(document.getElementById('serviceDuration').value) : null,
    emoji: document.getElementById('serviceEmoji').value.trim(),
    category: document.getElementById('serviceCategory').value,
    description: document.getElementById('serviceDescription').value.trim()
  };
  
  // Validaciones
  if (!id || !/^SRV-\d{3}$/.test(id)) {
    showToast('ID inválido. Formato: SRV-XXX', 'error');
    return;
  }
  if (!data.name) {
    showToast('El nombre es requerido', 'error');
    return;
  }
  if (data.price < 0) {
    showToast('El precio no puede ser negativo', 'error');
    return;
  }
  
  try {
    let result;
    
    if (mode === 'create') {
      // POST /api/services
      result = await api.request('/services', {
        method: 'POST',
        body: JSON.stringify({ id, ...data })
      });
      
      if (result.ok || result.id) {
        state.services.push({ id, ...data, active: true });
        showToast('Servicio creado correctamente', 'success');
      }
    } else {
      // PATCH /api/services/:id
      result = await api.request(`/services/${id}`, {
        method: 'PATCH',
        body: JSON.stringify(data)
      });
      
      if (result.ok) {
        const index = state.services.findIndex(s => s.id === id);
        if (index !== -1) {
          state.services[index] = { ...state.services[index], ...data };
        }
        showToast('Servicio actualizado correctamente', 'success');
      }
    }
    
    // Cerrar modal
    document.getElementById('serviceModal').classList.remove('open');
    
    // Re-renderizar
    renderServicesTable();
    
    // Actualizar POS (serviceCatalog)
    updateServiceCatalog();
    
    // Invalidar cache
    invalidatePublicCache();
    
  } catch (err) {
    showToast('Error: ' + err.message, 'error');
  }
});
```

### 4.7 Eliminar servicio

```javascript
document.getElementById('servicesTableBody')?.addEventListener('click', (e) => {
  const deleteBtn = e.target.closest('[data-delete-service]');
  if (!deleteBtn) return;
  
  const id = deleteBtn.dataset.deleteService;
  const service = state.services.find(s => s.id === id);
  if (!service) return;
  
  document.getElementById('deleteServiceId').textContent = service.id;
  document.getElementById('deleteServiceName').textContent = service.name;
  document.getElementById('deleteServiceModal').classList.add('open');
});

document.getElementById('confirmDeleteServiceBtn')?.addEventListener('click', async () => {
  const id = document.getElementById('deleteServiceId').textContent;
  
  try {
    const result = await api.request(`/services/${id}`, {
      method: 'DELETE'
    });
    
    if (result.ok) {
      state.services = state.services.filter(s => s.id !== id);
      document.getElementById('deleteServiceModal').classList.remove('open');
      renderServicesTable();
      updateServiceCatalog();
      invalidatePublicCache();
      showToast('Servicio eliminado correctamente', 'success');
    }
  } catch (err) {
    showToast('Error: ' + err.message, 'error');
  }
});
```

### 4.8 Actualizar serviceCatalog (para POS)

```javascript
function updateServiceCatalog() {
  // Actualizar serviceCatalog desde state.services
  window.serviceCatalog = state.services
    .filter(s => s.active !== false)
    .map(s => ({
      id: s.id,
      name: s.name,
      price: s.price,
      type: 'service'
    }));
  
  // Re-renderizar POS si está activo
  if (document.getElementById('section-pos')?.classList.contains('active')) {
    renderServicesStrip();
  }
}
```

## 5. Estilos CSS

### 5.1 Tabla de servicios

```css
.services-table {
  width: 100%;
  background: var(--color-bg-secondary);
  border-radius: var(--border-radius-lg);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
}

.services-table th {
  background: var(--color-bg-primary);
  padding: var(--spacing-md);
  text-align: left;
  font-weight: 600;
  color: var(--color-text-primary);
  border-bottom: 2px solid var(--color-border);
}

.services-table td {
  padding: var(--spacing-md);
  border-bottom: 1px solid var(--color-border);
  color: var(--color-text-secondary);
}

.services-table tr:hover {
  background: var(--color-bg-primary);
}

.services-table .actions {
  display: flex;
  gap: var(--spacing-sm);
}

.emoji-cell {
  font-size: 24px;
  text-align: center;
}

.badge-principal {
  background: #D4EDDA;
  color: #155724;
}

.badge-secundario {
  background: #E1E4E8;
  color: #24292E;
}
```

### 5.2 Formulario de servicio

```css
.form-text {
  display: block;
  margin-top: var(--spacing-xs);
  font-size: 12px;
  color: var(--color-text-secondary);
}

.service-info {
  background: var(--color-bg-primary);
  padding: var(--spacing-md);
  border-radius: var(--border-radius-md);
  margin: var(--spacing-md) 0;
}

.service-info strong {
  display: block;
  font-size: 16px;
  margin-bottom: var(--spacing-xs);
}
```

## 6. Integración con POS

### 6.1 Modificar renderServicesStrip

```javascript
function renderServicesStrip() {
  const wrap = document.getElementById('posServicesGrid');
  if (!wrap) return;
  
  const tiles = state.services
    .filter(s => s.active !== false)
    .map(item => {
      const emoji = item.emoji || getEmojiForService(item.id);
      const isMain = item.category === 'principal';
      return `
        <button type="button" class="svc-tile${isMain ? '' : ' is-secondary'}" data-strip-svc="${item.id}" aria-label="${escapeHtml(item.name)}">
          <span class="svc-emoji">${emoji}</span>
          <span class="svc-name">${escapeHtml(item.name)}</span>
          <span class="svc-price">${formatCurrency(finalPrice(item.price))}</span>
          <span class="svc-tag">${isMain ? 'Principal' : 'Secundario'}</span>
        </button>
      `;
    }).join('');
  
  wrap.innerHTML = tiles;
}
```

## 7. Criterios de aceptación

- [ ] CA-1: Nueva sección "Servicios" en sidebar
- [ ] CA-2: Tabla muestra ID, emoji, nombre, precio, categoría, duración, estado, acciones
- [ ] CA-3: Botón "Agregar servicio" abre modal de creación
- [ ] CA-4: Modal permite crear servicio con todos los campos
- [ ] CA-5: Validación de formato ID (SRV-XXX)
- [ ] CA-6: Botón "Editar" abre modal con datos del servicio
- [ ] CA-7: Guardar cambios envía POST (crear) o PATCH (editar)
- [ ] CA-8: Botón "Eliminar" muestra modal de confirmación
- [ ] CA-9: Confirmar eliminación envía DELETE /api/services/:id
- [ ] CA-10: Cambios se reflejan inmediatamente en la tabla
- [ ] CA-11: POS se actualiza automáticamente tras cambios
- [ ] CA-12: Cache de página pública se invalida
- [ ] CA-13: Fallback a serviceCatalog hardcodeado si backend falla
- [ ] CA-14: Responsive en mobile

## 8. Validaciones

1. Login como admin
2. Click en "Servicios" en sidebar
3. Verificar que se cargan los 8 servicios
4. Click en "Agregar servicio"
5. Crear nuevo servicio (SRV-009, "Test", $100, secundario)
6. Verificar que aparece en la tabla
7. Click en "Editar" del nuevo servicio
8. Cambiar precio a $150
9. Guardar y verificar que se actualiza
10. Ir a POS
11. Verificar que el nuevo servicio aparece
12. Volver a Servicios
13. Click en "Eliminar" del nuevo servicio
14. Confirmar eliminación
15. Verificar que desaparece de la tabla y del POS

## 9. Timeline

- **Día 1:** Sección Servicios + tabla + modal de creación
- **Día 2:** Modal de edición + eliminación + integración con POS
- **Día 3:** Testing + responsive

## 10. Riesgos

- **Riesgo medio:** Integración con POS puede romper funcionalidad existente
- **Mitigación:** Mantener fallback a serviceCatalog hardcodeado
- **Riesgo bajo:** Los endpoints del backend deben estar listos antes

## 11. Dependencias

- SPEC-BACKEND-001 (servicios) — debe estar listo
- SPEC-FRONTEND-005 (rediseño admin) — debe hacerse primero
- SPEC-FRONTEND-003 (productos) — puede hacerse en paralelo

## 12. Rollback

Si hay problemas:
1. Revertir commit
2. Volver a serviceCatalog hardcodeado
