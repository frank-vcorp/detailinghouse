# SPEC-FRONTEND-003: UI admin CRUD productos

**ID:** ARCH-20260711-03  
**Fecha:** 2026-07-11  
**Estado:** Planificado  
**Autor:** INTEGRA  
**Delegado a:** SOFIA

---

## 1. Contexto

Actualmente el admin solo puede:
- ✅ Crear producto nuevo (POST /api/inventory)
- ✅ Editar stock (PUT /api/inventory/:sku/stock)

No puede:
- ❌ Editar nombre
- ❌ Editar precio
- ❌ Editar descripción
- ❌ Editar categoría
- ❌ Editar presentación
- ❌ Eliminar producto

**Objetivo:** Agregar UI completa para editar TODOS los campos de un producto usando el endpoint `PATCH /api/inventory/:sku` que ya existe en el backend.

## 2. Requisitos funcionales

### 2.1 Lista de productos mejorada

**Tabla actual:**
| SKU | Nombre | Precio | Stock | Estado | Acciones |
|-----|--------|--------|-------|--------|----------|
| A1A-001 | VINIL PROTECT | $180 | 10 | Correcto | Editar stock |

**Tabla nueva:**
| SKU | Nombre | Categoría | Precio | Stock | Estado | Acciones |
|-----|--------|-----------|--------|-------|--------|----------|
| A1A-001 | VINIL PROTECT | INTERIORES | $180 | 10 | ✅ Activo | Editar | Eliminar |

**Mejoras:**
- Agregar columna "Categoría"
- Cambiar "Editar stock" por "Editar" (abre modal con todos los campos)
- Agregar botón "Eliminar" (soft delete)
- Mostrar estado visual (✅ Activo / ❌ Inactivo)

### 2.2 Modal de edición de producto

**Campos editables:**
- Nombre (text, requerido)
- Precio (number, requerido, >= 0)
- Stock (number, requerido, >= 0)
- Descripción (textarea, opcional)
- Categoría (select, requerido)
- Categoría label (text, requerido)
- Presentación (text, opcional)
- URL de imagen (text, opcional)

**Validaciones:**
- Nombre no vacío
- Precio >= 0
- Stock >= 0
- Categoría en lista predefinida

**Botones:**
- Cancelar (cierra modal sin guardar)
- Guardar cambios (envía PATCH /api/inventory/:sku)

### 2.3 Confirmación de eliminación

**Modal de confirmación:**
```
¿Estás seguro de que deseas eliminar este producto?

SKU: A1A-001
Nombre: VINIL PROTECT

Esta acción no se puede deshacer. El producto quedará inactivo pero no se borrará de la base de datos.

[Cancelar] [Eliminar]
```

**Comportamiento:**
- Click en "Eliminar" → DELETE /api/inventory/:sku
- Producto marcado como `active = false` en BD
- Producto desaparece de la lista (filtro WHERE active = true)
- Si se intenta vender, error "Producto no disponible"

## 3. Especificación de UI

### 3.1 Tabla de productos

```html
<table class="products-table">
  <thead>
    <tr>
      <th>SKU</th>
      <th>Nombre</th>
      <th>Categoría</th>
      <th>Precio</th>
      <th>Stock</th>
      <th>Estado</th>
      <th>Acciones</th>
    </tr>
  </thead>
  <tbody id="productsTableBody">
    <!-- Filas generadas dinámicamente -->
  </tbody>
</table>
```

**Fila de producto:**
```html
<tr data-sku="A1A-001">
  <td><code>A1A-001</code></td>
  <td><strong>VINIL PROTECT</strong></td>
  <td><span class="badge badge-category">INTERIORES</span></td>
  <td>$180.00</td>
  <td>
    <span class="stock-indicator stock-ok">10</span>
  </td>
  <td>
    <span class="status-badge status-active">✅ Activo</span>
  </td>
  <td class="actions">
    <button class="btn btn-sm btn-secondary" data-edit="A1A-001">
      <i data-lucide="edit"></i> Editar
    </button>
    <button class="btn btn-sm btn-danger" data-delete="A1A-001">
      <i data-lucide="trash-2"></i> Eliminar
    </button>
  </td>
</tr>
```

### 3.2 Modal de edición

```html
<div class="modal-overlay" id="editProductModal">
  <div class="modal">
    <div class="modal-header">
      <h3>Editar producto</h3>
      <button class="modal-close" data-close-modal>&times;</button>
    </div>
    <div class="modal-body">
      <form id="editProductForm">
        <input type="hidden" id="editProductSku" />
        
        <div class="form-group">
          <label for="editProductName">Nombre *</label>
          <input type="text" id="editProductName" required />
        </div>
        
        <div class="form-row">
          <div class="form-group">
            <label for="editProductPrice">Precio *</label>
            <input type="number" id="editProductPrice" min="0" step="0.01" required />
          </div>
          <div class="form-group">
            <label for="editProductStock">Stock *</label>
            <input type="number" id="editProductStock" min="0" step="1" required />
          </div>
        </div>
        
        <div class="form-group">
          <label for="editProductCategory">Categoría *</label>
          <select id="editProductCategory" required>
            <option value="interiores">INTERIORES</option>
            <option value="rines_llantas">RINES Y LLANTAS</option>
            <option value="shampoos">SHAMPOOS</option>
            <option value="ceramica">CERÁMICA</option>
            <option value="ceras">CERAS</option>
            <option value="molduras">MOLDURAS</option>
            <option value="especiales">ESPECIALES</option>
          </select>
        </div>
        
        <div class="form-group">
          <label for="editProductPresentation">Presentación</label>
          <input type="text" id="editProductPresentation" placeholder="600ml, 1L, etc." />
        </div>
        
        <div class="form-group">
          <label for="editProductDescription">Descripción</label>
          <textarea id="editProductDescription" rows="4"></textarea>
        </div>
        
        <div class="form-group">
          <label for="editProductImageUrl">URL de imagen</label>
          <input type="url" id="editProductImageUrl" placeholder="https://..." />
        </div>
      </form>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" data-close-modal>Cancelar</button>
      <button class="btn btn-primary" id="saveProductBtn">Guardar cambios</button>
    </div>
  </div>
</div>
```

### 3.3 Modal de confirmación de eliminación

```html
<div class="modal-overlay" id="deleteProductModal">
  <div class="modal modal-sm">
    <div class="modal-header">
      <h3>Confirmar eliminación</h3>
      <button class="modal-close" data-close-modal>&times;</button>
    </div>
    <div class="modal-body">
      <p>¿Estás seguro de que deseas eliminar este producto?</p>
      <div class="product-info">
        <strong id="deleteProductSku"></strong>
        <span id="deleteProductName"></span>
      </div>
      <p class="text-muted">Esta acción no se puede deshacer. El producto quedará inactivo pero no se borrará de la base de datos.</p>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" data-close-modal>Cancelar</button>
      <button class="btn btn-danger" id="confirmDeleteBtn">Eliminar</button>
    </div>
  </div>
</div>
```

## 4. JavaScript

### 4.1 Renderizar tabla de productos

```javascript
function renderProductsTable() {
  const tbody = document.getElementById('productsTableBody');
  if (!tbody) return;
  
  tbody.innerHTML = state.inventory.map(product => `
    <tr data-sku="${escapeHtml(product.sku)}">
      <td><code>${escapeHtml(product.sku)}</code></td>
      <td><strong>${escapeHtml(product.name)}</strong></td>
      <td><span class="badge badge-category">${escapeHtml(product.category_label || product.category)}</span></td>
      <td>${formatCurrency(product.price)}</td>
      <td>
        <span class="stock-indicator ${getStockClass(product.stock)}">${product.stock}</span>
      </td>
      <td>
        <span class="status-badge ${product.active !== false ? 'status-active' : 'status-inactive'}">
          ${product.active !== false ? '✅ Activo' : '❌ Inactivo'}
        </span>
      </td>
      <td class="actions">
        <button class="btn btn-sm btn-secondary" data-edit="${escapeHtml(product.sku)}">
          <i data-lucide="edit"></i> Editar
        </button>
        <button class="btn btn-sm btn-danger" data-delete="${escapeHtml(product.sku)}">
          <i data-lucide="trash-2"></i> Eliminar
        </button>
      </td>
    </tr>
  `).join('');
  
  lucide.createIcons();
}

function getStockClass(stock) {
  if (stock === 0) return 'stock-out';
  if (stock < 5) return 'stock-low';
  return 'stock-ok';
}
```

### 4.2 Abrir modal de edición

```javascript
document.getElementById('productsTableBody')?.addEventListener('click', async (e) => {
  const editBtn = e.target.closest('[data-edit]');
  if (!editBtn) return;
  
  const sku = editBtn.dataset.edit;
  const product = state.inventory.find(p => p.sku === sku);
  if (!product) return;
  
  // Llenar formulario
  document.getElementById('editProductSku').value = product.sku;
  document.getElementById('editProductName').value = product.name;
  document.getElementById('editProductPrice').value = product.price;
  document.getElementById('editProductStock').value = product.stock;
  document.getElementById('editProductCategory').value = product.category;
  document.getElementById('editProductPresentation').value = product.presentation || '';
  document.getElementById('editProductDescription').value = product.description || '';
  document.getElementById('editProductImageUrl').value = product.image_url || '';
  
  // Abrir modal
  document.getElementById('editProductModal').classList.add('open');
});
```

### 4.3 Guardar cambios

```javascript
document.getElementById('saveProductBtn')?.addEventListener('click', async () => {
  const sku = document.getElementById('editProductSku').value;
  const data = {
    name: document.getElementById('editProductName').value.trim(),
    price: parseFloat(document.getElementById('editProductPrice').value),
    stock: parseInt(document.getElementById('editProductStock').value),
    category: document.getElementById('editProductCategory').value,
    category_label: document.getElementById('editProductCategory').selectedOptions[0].textContent,
    presentation: document.getElementById('editProductPresentation').value.trim(),
    description: document.getElementById('editProductDescription').value.trim(),
    image_url: document.getElementById('editProductImageUrl').value.trim()
  };
  
  // Validaciones
  if (!data.name) {
    showToast('El nombre es requerido', 'error');
    return;
  }
  if (data.price < 0) {
    showToast('El precio no puede ser negativo', 'error');
    return;
  }
  if (data.stock < 0) {
    showToast('El stock no puede ser negativo', 'error');
    return;
  }
  
  try {
    const result = await api.request(`/inventory/${sku}`, {
      method: 'PATCH',
      body: JSON.stringify(data)
    });
    
    if (result.ok) {
      // Actualizar estado local
      const index = state.inventory.findIndex(p => p.sku === sku);
      if (index !== -1) {
        state.inventory[index] = { ...state.inventory[index], ...data };
      }
      
      // Cerrar modal
      document.getElementById('editProductModal').classList.remove('open');
      
      // Re-renderizar
      renderProductsTable();
      
      // Invalidar cache de página pública
      invalidatePublicCache();
      
      showToast('Producto actualizado correctamente', 'success');
    }
  } catch (err) {
    showToast('Error al actualizar: ' + err.message, 'error');
  }
});
```

### 4.4 Eliminar producto

```javascript
document.getElementById('productsTableBody')?.addEventListener('click', (e) => {
  const deleteBtn = e.target.closest('[data-delete]');
  if (!deleteBtn) return;
  
  const sku = deleteBtn.dataset.delete;
  const product = state.inventory.find(p => p.sku === sku);
  if (!product) return;
  
  // Mostrar modal de confirmación
  document.getElementById('deleteProductSku').textContent = product.sku;
  document.getElementById('deleteProductName').textContent = product.name;
  document.getElementById('deleteProductModal').classList.add('open');
});

document.getElementById('confirmDeleteBtn')?.addEventListener('click', async () => {
  const sku = document.getElementById('deleteProductSku').textContent;
  
  try {
    const result = await api.request(`/inventory/${sku}`, {
      method: 'DELETE'
    });
    
    if (result.ok) {
      // Remover del estado local
      state.inventory = state.inventory.filter(p => p.sku !== sku);
      
      // Cerrar modal
      document.getElementById('deleteProductModal').classList.remove('open');
      
      // Re-renderizar
      renderProductsTable();
      
      // Invalidar cache
      invalidatePublicCache();
      
      showToast('Producto eliminado correctamente', 'success');
    }
  } catch (err) {
    showToast('Error al eliminar: ' + err.message, 'error');
  }
});
```

### 4.5 Cerrar modales

```javascript
document.querySelectorAll('[data-close-modal]').forEach(btn => {
  btn.addEventListener('click', () => {
    btn.closest('.modal-overlay').classList.remove('open');
  });
});

// Cerrar modal al hacer click fuera
document.querySelectorAll('.modal-overlay').forEach(overlay => {
  overlay.addEventListener('click', (e) => {
    if (e.target === overlay) {
      overlay.classList.remove('open');
    }
  });
});
```

## 5. Estilos CSS

### 5.1 Tabla

```css
.products-table {
  width: 100%;
  background: var(--color-bg-secondary);
  border-radius: var(--border-radius-lg);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
}

.products-table th {
  background: var(--color-bg-primary);
  padding: var(--spacing-md);
  text-align: left;
  font-weight: 600;
  color: var(--color-text-primary);
  border-bottom: 2px solid var(--color-border);
}

.products-table td {
  padding: var(--spacing-md);
  border-bottom: 1px solid var(--color-border);
  color: var(--color-text-secondary);
}

.products-table tr:hover {
  background: var(--color-bg-primary);
}

.products-table .actions {
  display: flex;
  gap: var(--spacing-sm);
}
```

### 5.2 Badges

```css
.badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: var(--border-radius-sm);
  font-size: 12px;
  font-weight: 500;
}

.badge-category {
  background: #E1E4E8;
  color: #24292E;
}

.stock-indicator {
  display: inline-block;
  padding: 4px 8px;
  border-radius: var(--border-radius-sm);
  font-weight: 600;
}

.stock-ok {
  background: #D4EDDA;
  color: #155724;
}

.stock-low {
  background: #FFF3CD;
  color: #856404;
}

.stock-out {
  background: #F8D7DA;
  color: #721C24;
}

.status-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 4px 8px;
  border-radius: var(--border-radius-sm);
  font-size: 12px;
  font-weight: 500;
}

.status-active {
  background: #D4EDDA;
  color: #155724;
}

.status-inactive {
  background: #F8D7DA;
  color: #721C24;
}
```

### 5.3 Modales

```css
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.2s ease;
}

.modal-overlay.open {
  opacity: 1;
  pointer-events: auto;
}

.modal {
  background: var(--color-bg-secondary);
  border-radius: var(--border-radius-lg);
  max-width: 600px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: var(--shadow-lg);
}

.modal-sm {
  max-width: 400px;
}

.modal-header {
  padding: var(--spacing-lg);
  border-bottom: 1px solid var(--color-border);
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.modal-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
}

.modal-close {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: var(--color-text-secondary);
  padding: 0;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--border-radius-sm);
}

.modal-close:hover {
  background: var(--color-bg-primary);
}

.modal-body {
  padding: var(--spacing-lg);
}

.modal-footer {
  padding: var(--spacing-lg);
  border-top: 1px solid var(--color-border);
  display: flex;
  justify-content: flex-end;
  gap: var(--spacing-sm);
}
```

### 5.4 Formularios

```css
.form-group {
  margin-bottom: var(--spacing-md);
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--spacing-md);
}

.form-group label {
  display: block;
  margin-bottom: var(--spacing-xs);
  font-weight: 500;
  color: var(--color-text-primary);
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: var(--spacing-sm) var(--spacing-md);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius-md);
  font-size: 14px;
  color: var(--color-text-primary);
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(3, 102, 214, 0.1);
}

@media (max-width: 768px) {
  .form-row {
    grid-template-columns: 1fr;
  }
}
```

## 6. Criterios de aceptación

- [ ] CA-1: Tabla muestra SKU, nombre, categoría, precio, stock, estado, acciones
- [ ] CA-2: Botón "Editar" abre modal con todos los campos
- [ ] CA-3: Modal permite editar nombre, precio, stock, descripción, categoría, presentación, imagen
- [ ] CA-4: Guardar cambios envía PATCH /api/inventory/:sku
- [ ] CA-5: Cambios se reflejan inmediatamente en la tabla
- [ ] CA-6: Botón "Eliminar" muestra modal de confirmación
- [ ] CA-7: Confirmar eliminación envía DELETE /api/inventory/:sku
- [ ] CA-8: Producto eliminado desaparece de la lista
- [ ] CA-9: Validaciones funcionan (campos requeridos, valores >= 0)
- [ ] CA-10: Toast de éxito/error después de cada acción
- [ ] CA-11: Cache de página pública se invalida tras cambios
- [ ] CA-12: Responsive en mobile (modal full-screen, tabla en cards)

## 7. Validaciones

1. Login como admin
2. Ir a Inventario
3. Click en "Editar" de un producto
4. Cambiar nombre, precio, descripción
5. Click en "Guardar cambios"
6. Verificar que la tabla se actualiza
7. Click en "Eliminar" de otro producto
8. Confirmar eliminación
9. Verificar que el producto desaparece
10. Recargar página pública
11. Verificar que los cambios se reflejan

## 8. Timeline

- **Día 1:** Tabla mejorada + modal de edición
- **Día 2:** Modal de eliminación + cache invalidation
- **Día 3:** Responsive + testing

## 9. Riesgos

- **Riesgo bajo:** El backend ya tiene los endpoints, solo falta la UI
- **Riesgo medio:** Migrar el CSS puede romper estilos existentes
- **Mitigación:** Usar clases específicas del admin (prefijo `admin-`)

## 10. Dependencias

- SPEC-BACKEND-001 (servicios) — puede hacerse en paralelo
- SPEC-FRONTEND-005 (rediseño admin) — debe hacerse primero

## 11. Rollback

Si hay problemas:
1. Revertir commit
2. Volver a tabla anterior (solo stock editable)
