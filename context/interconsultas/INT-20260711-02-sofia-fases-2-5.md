# INT-20260711-02: Implementación completa Fases 2-5

**De:** INTEGRA  
**Para:** SOFIA  
**Fecha:** 2026-07-11  
**Prioridad:** Alta

---

## Contexto

Fase 1 completada (backend servicios). Ahora necesitamos implementar las Fases 2-5 del sistema admin profesional.

**SPECs de referencia:**
- SPEC-FRONTEND-005: Rediseño completo del panel admin
- SPEC-FRONTEND-003: CRUD productos
- SPEC-FRONTEND-004: CRUD servicios
- SPEC-FRONTEND-006: Cache invalidation

**Archivo a modificar:** `/home/frank/repos/detailinghouse/index.html`

---

## FASE 2: Rediseño completo del panel admin

### 2.1 Colores y variables CSS

Agregar al inicio del `<style>` (después de las variables existentes):

```css
:root {
  /* Colores admin profesional */
  --admin-bg-primary: #F8F9FA;
  --admin-bg-secondary: #FFFFFF;
  --admin-border: #E1E4E8;
  --admin-text-primary: #24292E;
  --admin-text-secondary: #586069;
  
  --admin-primary: #0366D6;
  --admin-primary-hover: #0056B3;
  --admin-success: #28A745;
  --admin-warning: #FFC107;
  --admin-error: #DC3545;
  --admin-info: #17A2B8;
  
  /* Espaciado */
  --admin-spacing-xs: 4px;
  --admin-spacing-sm: 8px;
  --admin-spacing-md: 16px;
  --admin-spacing-lg: 24px;
  --admin-spacing-xl: 32px;
  
  /* Bordes */
  --admin-border-radius-sm: 4px;
  --admin-border-radius-md: 6px;
  --admin-border-radius-lg: 8px;
  
  /* Sombras */
  --admin-shadow-sm: 0 1px 3px rgba(0,0,0,0.05);
  --admin-shadow-md: 0 4px 12px rgba(0,0,0,0.1);
  --admin-shadow-lg: 0 10px 40px rgba(0,0,0,0.2);
  
  /* Sidebar */
  --admin-sidebar-width: 240px;
  --admin-sidebar-collapsed: 60px;
}
```

### 2.2 Reemplazar estructura HTML del admin

**BUSCAR:** La sección `<div id="adminOverlay" class="admin-overlay">` (línea ~3560)

**REEMPLAZAR CON:**

```html
<!-- Admin Overlay con nuevo diseño -->
<div id="adminOverlay" class="admin-overlay">
  <div class="admin-layout">
    <!-- Sidebar -->
    <aside class="admin-sidebar">
      <div class="sidebar-header">
        <h1>🏠 DetailingHouse</h1>
      </div>
      <nav class="sidebar-nav">
        <a href="#" class="nav-item active" data-tab="dashboard">
          <span class="nav-icon">📊</span>
          <span class="nav-text">Dashboard</span>
        </a>
        <a href="#" class="nav-item" data-tab="pos">
          <span class="nav-icon">🛒</span>
          <span class="nav-text">POS</span>
        </a>
        <a href="#" class="nav-item" data-tab="inventario">
          <span class="nav-icon">📦</span>
          <span class="nav-text">Inventario</span>
        </a>
        <a href="#" class="nav-item" data-tab="servicios">
          <span class="nav-icon">🛍️</span>
          <span class="nav-text">Servicios</span>
        </a>
        <a href="#" class="nav-item" data-tab="clientes">
          <span class="nav-icon">👥</span>
          <span class="nav-text">Clientes</span>
        </a>
        <a href="#" class="nav-item" data-tab="agenda">
          <span class="nav-icon">📅</span>
          <span class="nav-text">Agenda</span>
        </a>
        <a href="#" class="nav-item" data-tab="caja">
          <span class="nav-icon">💰</span>
          <span class="nav-text">Caja Chica</span>
        </a>
        <a href="#" class="nav-item" data-tab="nomina">
          <span class="nav-icon">💼</span>
          <span class="nav-text">Nómina</span>
        </a>
      </nav>
      <div class="sidebar-footer">
        <div class="user-info">
          <span id="roleBadge" class="role-badge">Sin sesión</span>
        </div>
        <button class="nav-item logout-btn" id="adminLogoutBtn">
          <span class="nav-icon">🚪</span>
          <span class="nav-text">Cerrar sesión</span>
        </button>
      </div>
    </aside>

    <!-- Main Content -->
    <main class="admin-main">
      <header class="main-header">
        <button class="hamburger-btn" id="hamburgerBtn">☰</button>
        <h2 id="pageTitle" class="page-title">Dashboard</h2>
      </header>
      
      <div class="main-content">
        <!-- Login Box (se muestra cuando no hay sesión) -->
        <div id="adminLoginBox" class="admin-login-box">
          <h3>Acceso privado</h3>
          <p>Entra como administrador o empleado según el nivel de acceso que necesites.</p>
          <div class="form-group">
            <label for="adminPassword">Contraseña</label>
            <input id="adminPassword" type="password" placeholder="DH2025 o DH-STAFF" />
          </div>
          <div class="form-error" id="adminError"></div>
          <button class="btn btn-primary" id="adminLoginBtn">Entrar al panel</button>
          <div class="login-hints">
            <span class="hint-pill">ADMIN · DH2025</span>
            <span class="hint-pill">EMPLEADO · DH-STAFF</span>
          </div>
        </div>

        <!-- Admin Panel (se muestra cuando hay sesión) -->
        <div id="adminPanelApp" class="admin-panel-app">
          <!-- Dashboard -->
          <section class="admin-section active" id="tab-dashboard">
            <!-- Contenido existente del dashboard -->
          </section>

          <!-- POS -->
          <section class="admin-section" id="tab-pos">
            <!-- Contenido existente del POS -->
          </section>

          <!-- Inventario -->
          <section class="admin-section" id="tab-inventario">
            <!-- Contenido existente del inventario -->
          </section>

          <!-- Servicios (NUEVO) -->
          <section class="admin-section" id="tab-servicios">
            <div class="section-header">
              <h2>Servicios</h2>
              <button class="btn btn-primary" id="addServiceBtn">
                <span>+</span> Agregar servicio
              </button>
            </div>
            <div class="section-content">
              <table class="admin-table services-table">
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

          <!-- Clientes -->
          <section class="admin-section" id="tab-clientes">
            <!-- Contenido existente de clientes -->
          </section>

          <!-- Agenda -->
          <section class="admin-section" id="tab-agenda">
            <!-- Contenido existente de agenda -->
          </section>

          <!-- Caja -->
          <section class="admin-section" id="tab-caja">
            <!-- Contenido existente de caja -->
          </section>

          <!-- Nómina -->
          <section class="admin-section" id="tab-nomina">
            <!-- Contenido existente de nómina -->
          </section>
        </div>
      </div>
    </main>
  </div>
</div>
```

### 2.3 CSS completo del admin

Agregar al final del `<style>` (antes de `</style>`):

```css
/* ═══════════════════════════════════════════════════════════════
   ADMIN PANEL PROFESIONAL - REDESIGN
   ═══════════════════════════════════════════════════════════════ */

.admin-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: var(--admin-bg-primary);
  z-index: 9999;
  display: none;
}

.admin-overlay.open {
  display: block;
}

.admin-layout {
  display: flex;
  height: 100vh;
  background: var(--admin-bg-primary);
}

/* Sidebar */
.admin-sidebar {
  width: var(--admin-sidebar-width);
  background: var(--admin-bg-secondary);
  border-right: 1px solid var(--admin-border);
  display: flex;
  flex-direction: column;
  position: fixed;
  height: 100vh;
  overflow-y: auto;
  transition: transform 0.3s ease;
  z-index: 1000;
}

.sidebar-header {
  padding: var(--admin-spacing-lg);
  border-bottom: 1px solid var(--admin-border);
}

.sidebar-header h1 {
  font-size: 18px;
  font-weight: 600;
  color: var(--admin-text-primary);
  margin: 0;
}

.sidebar-nav {
  flex: 1;
  padding: var(--admin-spacing-md) 0;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: var(--admin-spacing-md);
  padding: var(--admin-spacing-md) var(--admin-spacing-lg);
  color: var(--admin-text-secondary);
  text-decoration: none;
  transition: all 0.2s ease;
  border-left: 3px solid transparent;
  cursor: pointer;
  background: none;
  border: none;
  width: 100%;
  text-align: left;
  font-size: 14px;
}

.nav-item:hover {
  background: var(--admin-bg-primary);
  color: var(--admin-primary);
}

.nav-item.active {
  background: var(--admin-bg-primary);
  color: var(--admin-primary);
  border-left-color: var(--admin-primary);
  font-weight: 500;
}

.nav-icon {
  font-size: 20px;
  width: 20px;
  text-align: center;
}

.sidebar-footer {
  border-top: 1px solid var(--admin-border);
  padding: var(--admin-spacing-md) 0;
}

.user-info {
  padding: var(--admin-spacing-md) var(--admin-spacing-lg);
  border-bottom: 1px solid var(--admin-border);
}

.role-badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: var(--admin-border-radius-sm);
  font-size: 12px;
  font-weight: 600;
  background: var(--admin-primary);
  color: white;
}

.logout-btn {
  color: var(--admin-error);
}

.logout-btn:hover {
  background: #FFF5F5;
  color: var(--admin-error);
}

/* Main Content */
.admin-main {
  flex: 1;
  margin-left: var(--admin-sidebar-width);
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.main-header {
  background: var(--admin-bg-secondary);
  border-bottom: 1px solid var(--admin-border);
  padding: var(--admin-spacing-md) var(--admin-spacing-xl);
  display: flex;
  align-items: center;
  gap: var(--admin-spacing-md);
  position: sticky;
  top: 0;
  z-index: 100;
}

.hamburger-btn {
  display: none;
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: var(--admin-text-primary);
  padding: var(--admin-spacing-sm);
}

.page-title {
  font-size: 20px;
  font-weight: 600;
  color: var(--admin-text-primary);
  margin: 0;
}

.main-content {
  padding: var(--admin-spacing-xl);
  flex: 1;
}

/* Login Box */
.admin-login-box {
  max-width: 400px;
  margin: 80px auto;
  background: var(--admin-bg-secondary);
  padding: var(--admin-spacing-xl);
  border-radius: var(--admin-border-radius-lg);
  box-shadow: var(--admin-shadow-md);
}

.admin-login-box h3 {
  font-size: 24px;
  font-weight: 600;
  color: var(--admin-text-primary);
  margin: 0 0 var(--admin-spacing-md) 0;
}

.admin-login-box p {
  color: var(--admin-text-secondary);
  margin: 0 0 var(--admin-spacing-lg) 0;
}

.form-group {
  margin-bottom: var(--admin-spacing-md);
}

.form-group label {
  display: block;
  margin-bottom: var(--admin-spacing-xs);
  font-weight: 500;
  color: var(--admin-text-primary);
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: var(--admin-spacing-sm) var(--admin-spacing-md);
  border: 1px solid var(--admin-border);
  border-radius: var(--admin-border-radius-md);
  font-size: 14px;
  color: var(--admin-text-primary);
  background: var(--admin-bg-secondary);
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: var(--admin-primary);
  box-shadow: 0 0 0 3px rgba(3, 102, 214, 0.1);
}

.form-error {
  color: var(--admin-error);
  font-size: 14px;
  margin-bottom: var(--admin-spacing-md);
  min-height: 20px;
}

.btn {
  padding: var(--admin-spacing-sm) var(--admin-spacing-md);
  border-radius: var(--admin-border-radius-md);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  border: none;
  display: inline-flex;
  align-items: center;
  gap: var(--admin-spacing-sm);
}

.btn-primary {
  background: var(--admin-primary);
  color: white;
}

.btn-primary:hover {
  background: var(--admin-primary-hover);
}

.btn-secondary {
  background: var(--admin-bg-secondary);
  color: var(--admin-text-primary);
  border: 1px solid var(--admin-border);
}

.btn-secondary:hover {
  background: var(--admin-bg-primary);
  border-color: #D1D5DA;
}

.btn-danger {
  background: var(--admin-error);
  color: white;
}

.btn-danger:hover {
  background: #C82333;
}

.btn-sm {
  padding: 6px 12px;
  font-size: 12px;
}

.login-hints {
  margin-top: var(--admin-spacing-lg);
  display: flex;
  gap: var(--admin-spacing-sm);
  flex-wrap: wrap;
}

.hint-pill {
  padding: 4px 12px;
  background: var(--admin-bg-primary);
  border-radius: var(--admin-border-radius-sm);
  font-size: 12px;
  color: var(--admin-text-secondary);
}

/* Admin Panel App */
.admin-panel-app {
  display: none;
}

.admin-panel-app.active {
  display: block;
}

.admin-section {
  display: none;
}

.admin-section.active {
  display: block;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: var(--admin-spacing-lg);
}

.section-header h2 {
  font-size: 24px;
  font-weight: 600;
  color: var(--admin-text-primary);
  margin: 0;
}

.section-content {
  background: var(--admin-bg-secondary);
  border-radius: var(--admin-border-radius-lg);
  padding: var(--admin-spacing-lg);
  box-shadow: var(--admin-shadow-sm);
}

/* Tables */
.admin-table {
  width: 100%;
  border-collapse: collapse;
  background: var(--admin-bg-secondary);
}

.admin-table th {
  background: var(--admin-bg-primary);
  padding: var(--admin-spacing-md);
  text-align: left;
  font-weight: 600;
  color: var(--admin-text-primary);
  border-bottom: 2px solid var(--admin-border);
  font-size: 14px;
}

.admin-table td {
  padding: var(--admin-spacing-md);
  border-bottom: 1px solid var(--admin-border);
  color: var(--admin-text-secondary);
  font-size: 14px;
}

.admin-table tr:hover {
  background: var(--admin-bg-primary);
}

.admin-table .actions {
  display: flex;
  gap: var(--admin-spacing-sm);
}

/* Status badges */
.status-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 4px 8px;
  border-radius: var(--admin-border-radius-sm);
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

/* Stock indicators */
.stock-indicator {
  display: inline-block;
  padding: 4px 8px;
  border-radius: var(--admin-border-radius-sm);
  font-weight: 600;
  font-size: 12px;
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

/* Category badges */
.badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: var(--admin-border-radius-sm);
  font-size: 12px;
  font-weight: 500;
}

.badge-principal {
  background: #D4EDDA;
  color: #155724;
}

.badge-secundario {
  background: #E1E4E8;
  color: #24292E;
}

/* Modals */
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
  z-index: 10000;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.2s ease;
}

.modal-overlay.open {
  opacity: 1;
  pointer-events: auto;
}

.modal {
  background: var(--admin-bg-secondary);
  border-radius: var(--admin-border-radius-lg);
  max-width: 600px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: var(--admin-shadow-lg);
}

.modal-sm {
  max-width: 400px;
}

.modal-header {
  padding: var(--admin-spacing-lg);
  border-bottom: 1px solid var(--admin-border);
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.modal-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: var(--admin-text-primary);
}

.modal-close {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: var(--admin-text-secondary);
  padding: 0;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--admin-border-radius-sm);
}

.modal-close:hover {
  background: var(--admin-bg-primary);
}

.modal-body {
  padding: var(--admin-spacing-lg);
}

.modal-footer {
  padding: var(--admin-spacing-lg);
  border-top: 1px solid var(--admin-border);
  display: flex;
  justify-content: flex-end;
  gap: var(--admin-spacing-sm);
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--admin-spacing-md);
}

.form-text {
  display: block;
  margin-top: var(--admin-spacing-xs);
  font-size: 12px;
  color: var(--admin-text-secondary);
}

.text-muted {
  color: var(--admin-text-secondary);
  font-size: 14px;
}

/* Responsive */
@media (max-width: 1024px) {
  .admin-sidebar {
    width: var(--admin-sidebar-collapsed);
  }
  .nav-text {
    display: none;
  }
  .admin-main {
    margin-left: var(--admin-sidebar-collapsed);
  }
}

@media (max-width: 768px) {
  .admin-sidebar {
    transform: translateX(-100%);
    width: var(--admin-sidebar-width);
  }
  .admin-sidebar.open {
    transform: translateX(0);
  }
  .admin-main {
    margin-left: 0;
  }
  .main-content {
    padding: var(--admin-spacing-md);
  }
  .hamburger-btn {
    display: block;
  }
  .form-row {
    grid-template-columns: 1fr;
  }
  .modal {
    width: 95%;
    max-height: 95vh;
  }
}

/* Toast notifications */
.toast {
  position: fixed;
  top: 20px;
  right: 20px;
  background: var(--admin-bg-secondary);
  border-left: 4px solid var(--admin-primary);
  border-radius: var(--admin-border-radius-md);
  padding: 12px 16px;
  box-shadow: var(--admin-shadow-md);
  z-index: 10001;
  animation: slideIn 0.3s ease;
  max-width: 400px;
}

.toast-success {
  border-left-color: var(--admin-success);
}

.toast-error {
  border-left-color: var(--admin-error);
}

.toast-warning {
  border-left-color: var(--admin-warning);
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

/* Update indicator */
.update-indicator {
  position: fixed;
  top: 20px;
  right: 20px;
  background: var(--admin-primary);
  color: white;
  padding: 12px 20px;
  border-radius: var(--admin-border-radius-md);
  box-shadow: var(--admin-shadow-md);
  display: flex;
  align-items: center;
  gap: 8px;
  z-index: 9999;
  animation: slideIn 0.3s ease;
}

.update-indicator.fade-out {
  animation: fadeOut 0.3s ease;
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

---

## FASE 3: CRUD Productos

### 3.1 Mejorar tabla de inventario

**BUSCAR:** La tabla de inventario en `#tab-inventario`

**REEMPLAZAR la estructura de la tabla con:**

```html
<table class="admin-table products-table">
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

### 3.2 Modal de edición de producto

Agregar antes de `</body>`:

```html
<!-- Modal edición producto -->
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

<!-- Modal confirmación eliminación -->
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
      <p class="text-muted">Esta acción no se puede deshacer. El producto quedará inactivo.</p>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" data-close-modal>Cancelar</button>
      <button class="btn btn-danger" id="confirmDeleteBtn">Eliminar</button>
    </div>
  </div>
</div>
```

### 3.3 JavaScript para CRUD productos

Agregar dentro del IIFE principal (después de las funciones existentes de inventario):

```javascript
// ═══════════════════════════════════════════════════════════════
// CRUD PRODUCTOS (FASE 3)
// ═══════════════════════════════════════════════════════════════

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
          Editar
        </button>
        <button class="btn btn-sm btn-danger" data-delete="${escapeHtml(product.sku)}">
          Eliminar
        </button>
      </td>
    </tr>
  `).join('');
}

function getStockClass(stock) {
  if (stock === 0) return 'stock-out';
  if (stock < 5) return 'stock-low';
  return 'stock-ok';
}

// Event listeners para tabla de productos
document.getElementById('productsTableBody')?.addEventListener('click', async (e) => {
  const editBtn = e.target.closest('[data-edit]');
  const deleteBtn = e.target.closest('[data-delete]');
  
  if (editBtn) {
    const sku = editBtn.dataset.edit;
    const product = state.inventory.find(p => p.sku === sku);
    if (!product) return;
    
    document.getElementById('editProductSku').value = product.sku;
    document.getElementById('editProductName').value = product.name;
    document.getElementById('editProductPrice').value = product.price;
    document.getElementById('editProductStock').value = product.stock;
    document.getElementById('editProductCategory').value = product.category;
    document.getElementById('editProductPresentation').value = product.presentation || '';
    document.getElementById('editProductDescription').value = product.description || '';
    document.getElementById('editProductImageUrl').value = product.image_url || '';
    
    document.getElementById('editProductModal').classList.add('open');
  }
  
  if (deleteBtn) {
    const sku = deleteBtn.dataset.delete;
    const product = state.inventory.find(p => p.sku === sku);
    if (!product) return;
    
    document.getElementById('deleteProductSku').textContent = product.sku;
    document.getElementById('deleteProductName').textContent = product.name;
    document.getElementById('deleteProductModal').classList.add('open');
  }
});

// Guardar cambios de producto
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
  
  if (!data.name) {
    window.dhAdminToast('El nombre es requerido', 'error');
    return;
  }
  if (data.price < 0) {
    window.dhAdminToast('El precio no puede ser negativo', 'error');
    return;
  }
  if (data.stock < 0) {
    window.dhAdminToast('El stock no puede ser negativo', 'error');
    return;
  }
  
  try {
    const result = await api.request(`/inventory/${sku}`, {
      method: 'PATCH',
      body: JSON.stringify(data)
    });
    
    if (result.ok) {
      const index = state.inventory.findIndex(p => p.sku === sku);
      if (index !== -1) {
        state.inventory[index] = { ...state.inventory[index], ...data };
      }
      
      document.getElementById('editProductModal').classList.remove('open');
      renderProductsTable();
      invalidatePublicCache();
      window.dhAdminToast('Producto actualizado correctamente', 'success');
    }
  } catch (err) {
    window.dhAdminToast('Error al actualizar: ' + err.message, 'error');
  }
});

// Eliminar producto
document.getElementById('confirmDeleteBtn')?.addEventListener('click', async () => {
  const sku = document.getElementById('deleteProductSku').textContent;
  
  try {
    const result = await api.request(`/inventory/${sku}`, {
      method: 'DELETE'
    });
    
    if (result.ok) {
      state.inventory = state.inventory.filter(p => p.sku !== sku);
      document.getElementById('deleteProductModal').classList.remove('open');
      renderProductsTable();
      invalidatePublicCache();
      window.dhAdminToast('Producto eliminado correctamente', 'success');
    }
  } catch (err) {
    window.dhAdminToast('Error al eliminar: ' + err.message, 'error');
  }
});
```

---

## FASE 4: CRUD Servicios

### 4.1 Modal de creación/edición de servicio

Agregar antes de `</body>`:

```html
<!-- Modal creación/edición servicio -->
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

<!-- Modal confirmación eliminación servicio -->
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
      <p class="text-muted">Esta acción no se puede deshacer. El servicio quedará inactivo.</p>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" data-close-modal>Cancelar</button>
      <button class="btn btn-danger" id="confirmDeleteServiceBtn">Eliminar</button>
    </div>
  </div>
</div>
```

### 4.2 JavaScript para CRUD servicios

Agregar dentro del IIFE principal:

```javascript
// ═══════════════════════════════════════════════════════════════
// CRUD SERVICIOS (FASE 4)
// ═══════════════════════════════════════════════════════════════

// Estado global para servicios
state.services = [];

// Cargar servicios al iniciar
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
      category: ['SRV-001','SRV-002','SRV-003'].includes(s.id) ? 'principal' : 'secundario',
      duration: null,
      active: true
    }));
    renderServicesTable();
  }
}

function getEmojiForService(id) {
  const emojis = {
    'SRV-001': '🚗', 'SRV-002': '✨', 'SRV-003': '🧼',
    'SRV-004': '⚙️', 'SRV-005': '🛡️', 'SRV-006': '💡',
    'SRV-007': '💺', 'SRV-008': '🌬️'
  };
  return emojis[id] || '⭐';
}

function renderServicesTable() {
  const tbody = document.getElementById('servicesTableBody');
  if (!tbody) return;
  
  tbody.innerHTML = state.services.map(service => `
    <tr data-id="${escapeHtml(service.id)}">
      <td><code>${escapeHtml(service.id)}</code></td>
      <td style="font-size: 24px; text-align: center;">${escapeHtml(service.emoji || '⭐')}</td>
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
          Editar
        </button>
        <button class="btn btn-sm btn-danger" data-delete-service="${escapeHtml(service.id)}">
          Eliminar
        </button>
      </td>
    </tr>
  `).join('');
}

// Agregar servicio
document.getElementById('addServiceBtn')?.addEventListener('click', () => {
  document.getElementById('serviceForm').reset();
  document.getElementById('serviceMode').value = 'create';
  document.getElementById('serviceModalTitle').textContent = 'Agregar servicio';
  document.getElementById('serviceIdInput').disabled = false;
  document.getElementById('serviceModal').classList.add('open');
});

// Editar servicio
document.getElementById('servicesTableBody')?.addEventListener('click', (e) => {
  const editBtn = e.target.closest('[data-edit-service]');
  const deleteBtn = e.target.closest('[data-delete-service]');
  
  if (editBtn) {
    const id = editBtn.dataset.editService;
    const service = state.services.find(s => s.id === id);
    if (!service) return;
    
    document.getElementById('serviceId').value = service.id;
    document.getElementById('serviceIdInput').value = service.id;
    document.getElementById('serviceIdInput').disabled = true;
    document.getElementById('serviceName').value = service.name;
    document.getElementById('servicePrice').value = service.price;
    document.getElementById('serviceDuration').value = service.duration || '';
    document.getElementById('serviceEmoji').value = service.emoji || '';
    document.getElementById('serviceCategory').value = service.category;
    document.getElementById('serviceDescription').value = service.description || '';
    document.getElementById('serviceMode').value = 'edit';
    document.getElementById('serviceModalTitle').textContent = 'Editar servicio';
    
    document.getElementById('serviceModal').classList.add('open');
  }
  
  if (deleteBtn) {
    const id = deleteBtn.dataset.deleteService;
    const service = state.services.find(s => s.id === id);
    if (!service) return;
    
    document.getElementById('deleteServiceId').textContent = service.id;
    document.getElementById('deleteServiceName').textContent = service.name;
    document.getElementById('deleteServiceModal').classList.add('open');
  }
});

// Guardar servicio
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
  
  if (!id || !/^SRV-\d{3}$/.test(id)) {
    window.dhAdminToast('ID inválido. Formato: SRV-XXX', 'error');
    return;
  }
  if (!data.name) {
    window.dhAdminToast('El nombre es requerido', 'error');
    return;
  }
  if (data.price < 0) {
    window.dhAdminToast('El precio no puede ser negativo', 'error');
    return;
  }
  
  try {
    let result;
    
    if (mode === 'create') {
      result = await api.request('/services', {
        method: 'POST',
        body: JSON.stringify({ id, ...data })
      });
      
      if (result.ok || result.id) {
        state.services.push({ id, ...data, active: true });
        window.dhAdminToast('Servicio creado correctamente', 'success');
      }
    } else {
      result = await api.request(`/services/${id}`, {
        method: 'PATCH',
        body: JSON.stringify(data)
      });
      
      if (result.ok) {
        const index = state.services.findIndex(s => s.id === id);
        if (index !== -1) {
          state.services[index] = { ...state.services[index], ...data };
        }
        window.dhAdminToast('Servicio actualizado correctamente', 'success');
      }
    }
    
    document.getElementById('serviceModal').classList.remove('open');
    renderServicesTable();
    updateServiceCatalog();
    invalidatePublicCache();
    
  } catch (err) {
    window.dhAdminToast('Error: ' + err.message, 'error');
  }
});

// Eliminar servicio
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
      window.dhAdminToast('Servicio eliminado correctamente', 'success');
    }
  } catch (err) {
    window.dhAdminToast('Error: ' + err.message, 'error');
  }
});

// Actualizar serviceCatalog para POS
function updateServiceCatalog() {
  window.serviceCatalog = state.services
    .filter(s => s.active !== false)
    .map(s => ({
      id: s.id,
      name: s.name,
      price: s.price,
      type: 'service'
    }));
  
  if (document.getElementById('tab-pos')?.classList.contains('active')) {
    renderServicesStrip();
  }
}
```

### 4.3 Modificar renderServicesStrip para usar state.services

**BUSCAR:** Función `renderServicesStrip()` (línea ~4273)

**REEMPLAZAR con:**

```javascript
function renderServicesStrip() {
  const wrap = byId('posServicesGrid');
  if (!wrap) return;
  
  const services = state.services && state.services.length > 0 
    ? state.services.filter(s => s.active !== false)
    : serviceCatalog;
  
  const tiles = services.map(item => {
    const emoji = item.emoji || getEmojiForService(item.id);
    const isMain = item.category === 'principal' || ['SRV-001','SRV-002','SRV-003'].includes(item.id);
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

---

## FASE 5: Cache Invalidation

### 5.1 Función de invalidation

Agregar dentro del IIFE principal:

```javascript
// ═══════════════════════════════════════════════════════════════
// CACHE INVALIDATION (FASE 5)
// ═══════════════════════════════════════════════════════════════

const CACHE_VERSION_KEY = 'dh_cache_version';

function invalidatePublicCache() {
  const currentVersion = parseInt(localStorage.getItem(CACHE_VERSION_KEY) || '0');
  localStorage.setItem(CACHE_VERSION_KEY, String(currentVersion + 1));
  
  window.dispatchEvent(new CustomEvent('cache-invalidated', {
    detail: { version: currentVersion + 1 }
  }));
}

// Detectar invalidation en página pública
function initPublicPageCacheSync() {
  window.addEventListener('cache-invalidated', (e) => {
    console.log('Cache invalidado, recargando datos...');
    showUpdateIndicator();
    loadPublicData();
  });
  
  // Polling cada 60 segundos
  let pollingTimer = null;
  
  function startPolling() {
    if (pollingTimer) clearInterval(pollingTimer);
    pollingTimer = setInterval(() => {
      checkForUpdates();
    }, 60000);
  }
  
  function stopPolling() {
    if (pollingTimer) {
      clearInterval(pollingTimer);
      pollingTimer = null;
    }
  }
  
  document.addEventListener('visibilitychange', () => {
    if (document.hidden) {
      stopPolling();
    } else {
      startPolling();
      checkForUpdates();
    }
  });
  
  startPolling();
  
  window.addEventListener('storage', (e) => {
    if (e.key === CACHE_VERSION_KEY) {
      console.log('Cache invalidado desde otra pestaña');
      showUpdateIndicator();
      loadPublicData();
    }
  });
}

async function checkForUpdates() {
  try {
    const lastUpdate = await api.request('/inventory/last-update');
    const currentLastUpdate = localStorage.getItem('dh_last_inventory_update');
    
    if (lastUpdate && lastUpdate !== currentLastUpdate) {
      console.log('Detectados cambios en inventario');
      localStorage.setItem('dh_last_inventory_update', lastUpdate);
      showUpdateIndicator();
      await loadPublicData();
    }
  } catch (err) {
    console.error('Error al verificar actualizaciones:', err);
  }
}

async function loadPublicData() {
  try {
    const products = await api.request('/inventory');
    state.inventory = products;
    
    const services = await api.request('/services');
    state.services = services;
    
    renderPublicProducts('todos');
    renderServicesStrip();
    
    console.log('Datos públicos recargados');
  } catch (err) {
    console.error('Error al recargar datos públicos:', err);
  }
}

function showUpdateIndicator() {
  const indicator = document.createElement('div');
  indicator.className = 'update-indicator';
  indicator.innerHTML = '🔄 Actualizando...';
  document.body.appendChild(indicator);
  
  setTimeout(() => {
    indicator.classList.add('fade-out');
    setTimeout(() => indicator.remove(), 300);
  }, 1000);
}
```

### 5.2 Llamar initPublicPageCacheSync al cargar

**BUSCAR:** Función de inicialización (línea ~5160)

**AGREGAR después de `bindPublicInteractions()`:**

```javascript
initPublicPageCacheSync();
```

### 5.3 Agregar endpoint last-update al backend

**NOTA:** Este endpoint ya existe en el backend (Fase 1). Solo verificar que funciona.

---

## VALIDACIONES OBLIGATORIAS

Antes de reportar como listo:

1. **Verificar que el admin panel carga correctamente:**
   - Login con DH2025
   - Verificar que las 8 secciones aparecen en sidebar
   - Verificar que cada sección se muestra al hacer click

2. **Verificar CRUD productos:**
   - Ir a Inventario
   - Click en "Editar" de un producto
   - Cambiar nombre/precio/descripción
   - Guardar y verificar que se actualiza
   - Click en "Eliminar" de otro producto
   - Confirmar y verificar que desaparece

3. **Verificar CRUD servicios:**
   - Click en "Servicios" en sidebar
   - Verificar que se cargan los 8 servicios
   - Click en "Agregar servicio"
   - Crear nuevo servicio (SRV-009)
   - Verificar que aparece en la tabla
   - Click en "Editar" del nuevo servicio
   - Cambiar precio
   - Guardar y verificar que se actualiza
   - Ir a POS
   - Verificar que el nuevo servicio aparece
   - Volver a Servicios
   - Click en "Eliminar" del nuevo servicio
   - Confirmar y verificar que desaparece

4. **Verificar cache invalidation:**
   - Abrir página pública en pestaña 1
   - Abrir admin en pestaña 2
   - Modificar un producto en admin
   - Verificar que en pestaña 1 se actualiza automáticamente (o esperar 60 segundos)

5. **Verificar responsive:**
   - Reducir ventana a 768px
   - Verificar que aparece hamburger menu
   - Click en hamburger
   - Verificar que sidebar se abre
   - Click en una sección
   - Verificar que sidebar se cierra

6. **Verificar 0 errores en consola**

7. **Self-review manual:**
   - ¿El código refleja las SPECs?
   - ¿Hay code smells evidentes?
   - ¿Los modales funcionan correctamente?
   - ¿Los CRUD funcionan end-to-end?
   - ¿Algún riesgo de regresión?

---

## DEPLOY

Después de validar localmente:

```bash
cd /home/frank/repos/detailinghouse
git add .
git commit -m "feat: sistema admin profesional completo (Fases 2-5)

- Rediseño completo del panel admin con colores claros y responsive
- CRUD completo de productos (editar nombre/precio/descripción/eliminar)
- CRUD completo de servicios (crear/editar/eliminar)
- Cache invalidation para reflejo en tiempo real
- Sidebar con 8 secciones + configuración + logout
- Modales profesionales para edición
- Responsive completo (desktop/tablet/mobile)

SPECs: SPEC-FRONTEND-003, SPEC-FRONTEND-004, SPEC-FRONTEND-005, SPEC-FRONTEND-006"
git push origin main
```

Vercel hará deploy automático.

---

## REPORTE FINAL

Al terminar, reporta:
1. Archivos modificados
2. Resultado de todas las validaciones
3. Self-review (code smells, riesgos)
4. Confirmación de push a main
5. Screenshots si es posible

**NO solicites Qodo (está sunset).**

Al cerrar, sugiere que INTEGRA invoque a GEMINI como segunda mano.
