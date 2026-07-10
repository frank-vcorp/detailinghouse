# SPEC-FRONTEND-005: Rediseño completo del panel admin

**ID:** ARCH-20260711-02  
**Fecha:** 2026-07-11  
**Estado:** Planificado  
**Autor:** INTEGRA  
**Delegado a:** SOFIA

---

## 1. Contexto

El panel admin actual tiene problemas de UX:
- Colores muy oscuros que cansan la vista
- Layout compacto que no aprovecha el espacio
- No es responsive (no se adapta a móvil)
- No está preparado para PWA futura

**Objetivo:** Rediseñar el panel admin con un look profesional, moderno, claro y responsive.

## 2. Requisitos de diseño

### 2.1 Paleta de colores (tema claro profesional)

**Colores principales:**
- **Fondo principal:** `#F8F9FA` (gris muy claro, no blanco puro para reducir fatiga visual)
- **Fondo secundario:** `#FFFFFF` (blanco para cards/modales)
- **Borde:** `#E1E4E8` (gris suave)
- **Texto principal:** `#24292E` (gris oscuro, no negro puro)
- **Texto secundario:** `#586069` (gris medio)

**Colores de acento:**
- **Primario:** `#0366D6` (azul profesional, similar a GitHub)
- **Primario hover:** `#0056B3`
- **Éxito:** `#28A745` (verde)
- **Warning:** `#FFC107` (amarillo)
- **Error:** `#DC3545` (rojo)
- **Info:** `#17A2B8` (cyan)

**Colores de tabs:**
- **Tab activa:** Fondo `#0366D6`, texto `#FFFFFF`
- **Tab inactiva:** Fondo transparente, texto `#586069`
- **Tab hover:** Fondo `#F1F3F5`, texto `#0366D6`

### 2.2 Tipografía

```css
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
font-size: 14px;
line-height: 1.5;
```

**Tamaños:**
- **H1 (título sección):** 24px, bold
- **H2 (subtítulo):** 20px, semibold
- **H3 (card title):** 16px, semibold
- **Body:** 14px, regular
- **Small:** 12px, regular
- **Caption:** 11px, regular

### 2.3 Espaciado

**Sistema de 8px:**
- **xs:** 4px
- **sm:** 8px
- **md:** 16px
- **lg:** 24px
- **xl:** 32px
- **xxl:** 48px

### 2.4 Layout

**Desktop (>1024px):**
- Sidebar fija a la izquierda (240px de ancho)
- Contenido principal ocupa el resto
- Padding: 32px

**Tablet (768px - 1024px):**
- Sidebar colapsable (iconos + texto)
- Contenido principal ocupa el resto
- Padding: 24px

**Mobile (<768px):**
- Sidebar oculta (hamburger menu)
- Contenido ocupa 100% del ancho
- Padding: 16px
- Tabs en scroll horizontal

### 2.5 Componentes

#### 2.5.1 Sidebar de navegación

```
┌─────────────────────────────────────┐
│ 🏠 DetailingHouse                   │
│                                     │
│ 📊 Dashboard                        │
│ 🛒 POS                              │
│ 📦 Inventario                       │
│ 🛍️ Servicios                        │
│ 👥 Clientes                         │
│ 📅 Agenda                           │
│ 💰 Caja Chica                       │
│ 💼 Nómina                           │
│                                     │
│ ─────────────────────────────────── │
│ ⚙️ Configuración                    │
│ 🚪 Cerrar sesión                    │
└─────────────────────────────────────┘
```

**Características:**
- Fondo: `#FFFFFF`
- Borde derecho: `1px solid #E1E4E8`
- Item activo: Fondo `#F1F3F5`, borde izquierdo `3px solid #0366D6`
- Item hover: Fondo `#F8F9FA`
- Iconos: 20px, alineados a la izquierda
- Texto: 14px, `#24292E`

#### 2.5.2 Cards

```css
.card {
  background: #FFFFFF;
  border: 1px solid #E1E4E8;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}
```

**Variaciones:**
- **Card simple:** Solo borde
- **Card con header:** Header con borde inferior
- **Card con acciones:** Footer con botones

#### 2.5.3 Botones

**Primario:**
```css
.btn-primary {
  background: #0366D6;
  color: #FFFFFF;
  border: none;
  border-radius: 6px;
  padding: 8px 16px;
  font-weight: 500;
}
.btn-primary:hover {
  background: #0056B3;
}
```

**Secundario:**
```css
.btn-secondary {
  background: #FFFFFF;
  color: #24292E;
  border: 1px solid #E1E4E8;
  border-radius: 6px;
  padding: 8px 16px;
}
.btn-secondary:hover {
  background: #F8F9FA;
  border-color: #D1D5DA;
}
```

**Danger:**
```css
.btn-danger {
  background: #DC3545;
  color: #FFFFFF;
  border: none;
  border-radius: 6px;
  padding: 8px 16px;
}
.btn-danger:hover {
  background: #C82333;
}
```

**Tamaños:**
- **Small:** 6px 12px, 12px font
- **Medium:** 8px 16px, 14px font (default)
- **Large:** 12px 24px, 16px font

#### 2.5.4 Tablas

```css
table {
  width: 100%;
  border-collapse: collapse;
  background: #FFFFFF;
}
th {
  background: #F8F9FA;
  border-bottom: 2px solid #E1E4E8;
  padding: 12px;
  text-align: left;
  font-weight: 600;
  color: #24292E;
}
td {
  border-bottom: 1px solid #E1E4E8;
  padding: 12px;
  color: #586069;
}
tr:hover {
  background: #F8F9FA;
}
```

**Responsive:**
- Desktop: Tabla completa
- Mobile: Cards en lugar de filas

#### 2.5.5 Formularios

```css
input, select, textarea {
  background: #FFFFFF;
  border: 1px solid #E1E4E8;
  border-radius: 6px;
  padding: 8px 12px;
  font-size: 14px;
  color: #24292E;
}
input:focus, select:focus, textarea:focus {
  outline: none;
  border-color: #0366D6;
  box-shadow: 0 0 0 3px rgba(3,102,214,0.1);
}
```

**Labels:**
```css
label {
  display: block;
  margin-bottom: 4px;
  font-weight: 500;
  color: #24292E;
}
```

#### 2.5.6 Modales

```css
.modal-overlay {
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal {
  background: #FFFFFF;
  border-radius: 8px;
  padding: 24px;
  max-width: 600px;
  width: 90%;
  box-shadow: 0 10px 40px rgba(0,0,0,0.2);
}
```

**Responsive:**
- Desktop: 600px max-width, centrado
- Mobile: 90% width, casi full-screen

#### 2.5.7 Toasts / Notificaciones

```css
.toast {
  background: #FFFFFF;
  border-left: 4px solid #0366D6;
  border-radius: 6px;
  padding: 12px 16px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}
.toast-success { border-left-color: #28A745; }
.toast-error { border-left-color: #DC3545; }
.toast-warning { border-left-color: #FFC107; }
```

**Posición:**
- Desktop: Top-right, 16px from edges
- Mobile: Bottom, full-width

### 2.6 Iconos

Usar **Lucide Icons** (SVG, 24x24, stroke-width 2):
- Dashboard: `layout-dashboard`
- POS: `shopping-cart`
- Inventario: `package`
- Servicios: `concierge-bell`
- Clientes: `users`
- Agenda: `calendar`
- Caja: `wallet`
- Nómina: `banknote`
- Configuración: `settings`
- Logout: `log-out`

**CDN:**
```html
<script src="https://unpkg.com/lucide@latest"></script>
```

**Uso:**
```html
<i data-lucide="shopping-cart"></i>
<script>lucide.createIcons();</script>
```

## 3. Estructura HTML

### 3.1 Layout principal

```html
<div class="admin-layout">
  <!-- Sidebar -->
  <aside class="admin-sidebar">
    <div class="sidebar-header">
      <h1>🏠 DetailingHouse</h1>
    </div>
    <nav class="sidebar-nav">
      <a href="#" class="nav-item active" data-tab="dashboard">
        <i data-lucide="layout-dashboard"></i>
        <span>Dashboard</span>
      </a>
      <a href="#" class="nav-item" data-tab="pos">
        <i data-lucide="shopping-cart"></i>
        <span>POS</span>
      </a>
      <a href="#" class="nav-item" data-tab="inventory">
        <i data-lucide="package"></i>
        <span>Inventario</span>
      </a>
      <a href="#" class="nav-item" data-tab="services">
        <i data-lucide="concierge-bell"></i>
        <span>Servicios</span>
      </a>
      <a href="#" class="nav-item" data-tab="clients">
        <i data-lucide="users"></i>
        <span>Clientes</span>
      </a>
      <a href="#" class="nav-item" data-tab="agenda">
        <i data-lucide="calendar"></i>
        <span>Agenda</span>
      </a>
      <a href="#" class="nav-item" data-tab="cash">
        <i data-lucide="wallet"></i>
        <span>Caja Chica</span>
      </a>
      <a href="#" class="nav-item" data-tab="payroll">
        <i data-lucide="banknote"></i>
        <span>Nómina</span>
      </a>
    </nav>
    <div class="sidebar-footer">
      <a href="#" class="nav-item" id="settingsBtn">
        <i data-lucide="settings"></i>
        <span>Configuración</span>
      </a>
      <a href="#" class="nav-item" id="logoutBtn">
        <i data-lucide="log-out"></i>
        <span>Cerrar sesión</span>
      </a>
    </div>
  </aside>

  <!-- Main content -->
  <main class="admin-main">
    <header class="main-header">
      <button class="hamburger" id="hamburgerBtn">
        <i data-lucide="menu"></i>
      </button>
      <h2 id="pageTitle">Dashboard</h2>
      <div class="user-info">
        <span id="userName">Admin</span>
        <span class="role-badge" id="roleBadge">ADMIN</span>
      </div>
    </header>
    <div class="main-content">
      <!-- Aquí van las secciones -->
    </div>
  </main>
</div>
```

### 3.2 Secciones

Cada sección es un `<section>` con `id="section-{tab}"`:

```html
<section id="section-dashboard" class="admin-section active">
  <div class="section-header">
    <h2>Dashboard</h2>
    <button class="btn btn-primary" id="exportReportBtn">
      <i data-lucide="download"></i>
      Exportar reporte
    </button>
  </div>
  <div class="section-content">
    <!-- Contenido del dashboard -->
  </div>
</section>
```

## 4. CSS completo

### 4.1 Variables CSS

```css
:root {
  /* Colores */
  --color-bg-primary: #F8F9FA;
  --color-bg-secondary: #FFFFFF;
  --color-border: #E1E4E8;
  --color-text-primary: #24292E;
  --color-text-secondary: #586069;
  
  --color-primary: #0366D6;
  --color-primary-hover: #0056B3;
  --color-success: #28A745;
  --color-warning: #FFC107;
  --color-error: #DC3545;
  --color-info: #17A2B8;
  
  /* Espaciado */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;
  --spacing-xxl: 48px;
  
  /* Bordes */
  --border-radius-sm: 4px;
  --border-radius-md: 6px;
  --border-radius-lg: 8px;
  
  /* Sombras */
  --shadow-sm: 0 1px 3px rgba(0,0,0,0.05);
  --shadow-md: 0 4px 12px rgba(0,0,0,0.1);
  --shadow-lg: 0 10px 40px rgba(0,0,0,0.2);
  
  /* Sidebar */
  --sidebar-width: 240px;
  --sidebar-width-collapsed: 60px;
}
```

### 4.2 Layout principal

```css
.admin-layout {
  display: flex;
  min-height: 100vh;
  background: var(--color-bg-primary);
}

.admin-sidebar {
  width: var(--sidebar-width);
  background: var(--color-bg-secondary);
  border-right: 1px solid var(--color-border);
  display: flex;
  flex-direction: column;
  position: fixed;
  height: 100vh;
  overflow-y: auto;
  transition: width 0.3s ease;
}

.admin-main {
  flex: 1;
  margin-left: var(--sidebar-width);
  display: flex;
  flex-direction: column;
}

.main-header {
  background: var(--color-bg-secondary);
  border-bottom: 1px solid var(--color-border);
  padding: var(--spacing-md) var(--spacing-xl);
  display: flex;
  align-items: center;
  justify-content: space-between;
  position: sticky;
  top: 0;
  z-index: 100;
}

.main-content {
  padding: var(--spacing-xl);
  flex: 1;
}
```

### 4.3 Sidebar

```css
.sidebar-header {
  padding: var(--spacing-lg);
  border-bottom: 1px solid var(--color-border);
}

.sidebar-header h1 {
  font-size: 18px;
  font-weight: 600;
  color: var(--color-text-primary);
  margin: 0;
}

.sidebar-nav {
  flex: 1;
  padding: var(--spacing-md) 0;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-md);
  padding: var(--spacing-md) var(--spacing-lg);
  color: var(--color-text-secondary);
  text-decoration: none;
  transition: all 0.2s ease;
  border-left: 3px solid transparent;
}

.nav-item:hover {
  background: var(--color-bg-primary);
  color: var(--color-primary);
}

.nav-item.active {
  background: var(--color-bg-primary);
  color: var(--color-primary);
  border-left-color: var(--color-primary);
  font-weight: 500;
}

.nav-item i {
  width: 20px;
  height: 20px;
}

.sidebar-footer {
  border-top: 1px solid var(--color-border);
  padding: var(--spacing-md) 0;
}
```

### 4.4 Responsive

```css
/* Tablet */
@media (max-width: 1024px) {
  .admin-sidebar {
    width: var(--sidebar-width-collapsed);
  }
  .nav-item span {
    display: none;
  }
  .admin-main {
    margin-left: var(--sidebar-width-collapsed);
  }
}

/* Mobile */
@media (max-width: 768px) {
  .admin-sidebar {
    transform: translateX(-100%);
    width: var(--sidebar-width);
    z-index: 1000;
  }
  .admin-sidebar.open {
    transform: translateX(0);
  }
  .admin-main {
    margin-left: 0;
  }
  .main-content {
    padding: var(--spacing-md);
  }
  .hamburger {
    display: block;
  }
}
```

## 5. JavaScript

### 5.1 Toggle sidebar (mobile)

```javascript
document.getElementById('hamburgerBtn')?.addEventListener('click', () => {
  document.querySelector('.admin-sidebar').classList.toggle('open');
});

// Cerrar sidebar al hacer click fuera (mobile)
document.addEventListener('click', (e) => {
  const sidebar = document.querySelector('.admin-sidebar');
  const hamburger = document.getElementById('hamburgerBtn');
  if (window.innerWidth <= 768 && 
      !sidebar.contains(e.target) && 
      !hamburger.contains(e.target)) {
    sidebar.classList.remove('open');
  }
});
```

### 5.2 Navegación entre secciones

```javascript
document.querySelectorAll('.nav-item[data-tab]').forEach(item => {
  item.addEventListener('click', (e) => {
    e.preventDefault();
    const tab = item.dataset.tab;
    
    // Actualizar nav
    document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
    item.classList.add('active');
    
    // Actualizar sección
    document.querySelectorAll('.admin-section').forEach(s => s.classList.remove('active'));
    document.getElementById(`section-${tab}`).classList.add('active');
    
    // Actualizar título
    document.getElementById('pageTitle').textContent = item.querySelector('span').textContent;
    
    // Cerrar sidebar en mobile
    if (window.innerWidth <= 768) {
      document.querySelector('.admin-sidebar').classList.remove('open');
    }
  });
});
```

## 6. Criterios de aceptación

- [ ] CA-1: Sidebar con 8 secciones + configuración + logout
- [ ] CA-2: Colores claros que no cansen la vista
- [ ] CA-3: Layout ocupa 100% del viewport
- [ ] CA-4: Responsive en desktop (>1024px)
- [ ] CA-5: Responsive en tablet (768px - 1024px) con sidebar colapsada
- [ ] CA-6: Responsive en mobile (<768px) con hamburger menu
- [ ] CA-7: Iconos Lucide cargados correctamente
- [ ] CA-8: Transiciones suaves entre secciones
- [ ] CA-9: No rompe funcionalidad existente (POS, ventas, etc.)
- [ ] CA-10: Accesible (contraste WCAG AA, focus visible)

## 7. Validaciones

1. Abrir en Chrome DevTools
2. Probar en 3 breakpoints: 1440px, 1024px, 375px
3. Verificar que todos los tabs funcionen
4. Verificar que no haya errores en consola
5. Verificar contraste de colores con Lighthouse

## 8. Timeline

- **Día 1:** CSS completo + layout principal
- **Día 2:** Migrar secciones existentes (POS, Inventario, Clientes, etc.)
- **Día 3:** Agregar secciones nuevas (Servicios) + responsive final

## 9. Riesgos

- **Riesgo medio:** Migrar todo el CSS puede romper estilos existentes
- **Mitigación:** Hacer cambios incrementales, probar cada sección

## 10. Dependencias

- Ninguna (se puede hacer en paralelo con SPEC-BACKEND-001)

## 11. Rollback

Si hay problemas:
1. Revertir commit
2. Volver a CSS anterior (backup en `index.html.bak-pre-fix-20260710`)
