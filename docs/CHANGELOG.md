# 📋 Changelog — DetailingHouse

Todos los cambios notables de este proyecto serán documentados aquí.

Formato basado en [Keep a Changelog](https://keepachangelog.com/es/1.0.0/)
y este proyecto sigue [Versionado Semántico](https://semver.org/lang/es/).

---

## [4.0.0] — 2026-07-07

### ✅ Añadido
- **Backend PostgreSQL** en Railway (API REST completa)
- **Autenticación JWT** con endpoints `/auth/login`, token persistente en `localStorage('dh_jwt')`
- **10 endpoints API**: inventario, clientes, ventas, citas, stock, productos, cortes de nómina
- **Carrito fuente única de verdad (SOT)**: eliminado `state.cart` duplicado, ahora usa `cart` por closure en ambos scopes (público + admin)
- **Modales visuales** (`dhAdminModal`): edición de stock y actualización de citas reemplazan `prompt()`
- **Toasts de feedback** (`dhAdminToast`): 6 alertas de error + 1 info de detalle de cita reemplazan `alert()`
- **CSS visual**: `.admin-toast`, `.admin-modal-overlay`, `.admin-modal` con estilos dark premium
- **Contenedores DOM**: `#adminToasts` + `#adminModals` para feedback visual no bloqueante
- **Mutación in-place** del carrito tras venta (`cart.length = 0` preserva referencia)

### 🔧 Modificado
- `api.getInventory()`, `api.getClients()`, `api.getSales()`, `api.getAppointments()` sustituyen lectura de `localStorage`
- `api.updateStock()`, `api.addProduct()`, `api.addClient()`, `api.addAppointment()` sustituyen escritura en `localStorage`
- `api.login(username, password)` envía POST a `/auth/login` y almacena JWT
- `api.restoreToken()` restaura sesión desde `localStorage('dh_jwt')` al cargar la página
- Listener legacy `cartItems` silenciado (handler muerto, carrito flotante toma control)
- `registerSale` envía venta a API y actualiza stock local tras confirmación del servidor

### 🗑️ Eliminado
- `localStorage` para productos, ventas, clientes, citas y nómina (solo queda `dh_jwt` para JWT)
- `state.cart` del objeto `state` (unificado a `cart` por closure)
- 9 calls nativas `prompt()` / `alert()` del panel admin
- Arquitectura offline-first sin backend (migrada a API PostgreSQL)

---

## [3.0.0] — 2026-06-28

### ✅ Añadido
- Módulo de **Caja Chica** completo (apertura/cierre + gastos por categoría)
- Módulo de **Clientes** con registro, historial, sistema de puntos y QR único
- Módulo de **Nómina automática** (Andrés 35%, Erika 35%, Local 30%)
- Módulo de **Agenda** con calendario visual mensual
- **Dashboard ejecutivo** con gráfica Canvas y exportar a CSV
- Sistema de **Roles** (Admin `DH2025` vs Empleado `DH-STAFF`)
- **SEO avanzado**: JSON-LD LocalBusiness, Open Graph, Twitter Card
- Sección de **Testimonios** de clientes
- **FAQ interactivo** con acordeón
- Sección de **Cobertura** (Querétaro + Corregidora)
- **Contadores animados** (autos, satisfacción, experiencia)
- GitHub Actions CI/CD workflow
- Scripts de deploy y backup

### 🔧 Modificado
- Reorganización completa de la estructura del proyecto
- README profesional con documentación completa
- Configuración Netlify mejorada con headers de seguridad

---

## [2.0.0] — 2026-06-27

### ✅ Añadido
- **11 fotografías reales** del negocio integradas en el sitio
- **Catálogo A1A completo** — 30 productos en 7 categorías con precios reales
- Filtros interactivos por categoría en el catálogo de productos
- Sistema de inventario preconfigurado con los 30 productos A1A
- Botones de WhatsApp en cada producto (mensaje predefinido)
- Mejora de imágenes con IA (brillo, contraste, composición)

### 🔧 Modificado
- Hero banner actualizado con foto real del motor
- Paquete Elite: foto real del interior del vehículo
- Paquete Plus: foto real del asiento trasero
- Servicio Motor: foto macro del motor detallado
- Galería: 6 fotos reales del trabajo

### 🗑️ Eliminado
- Imágenes placeholder generadas por IA (reemplazadas por fotos reales)

---

## [1.0.0] — 2026-06-26

### ✅ Añadido
- Página pública responsive con diseño dark premium
- Sección Hero con CTA WhatsApp
- Catálogo de 3 paquetes (Elite, Plus, Esencial) con precios del Excel
- 5 servicios adicionales (Motor, Cristales, Faros, Asientos, Desinfección)
- Galería con imágenes placeholder generadas por IA
- Sección "¿Por qué elegirnos?"
- Footer con links y datos de contacto
- WhatsApp flotante animado
- Panel Admin básico (POS + Inventario simple)
- Persistencia de datos con localStorage

---

## [0.1.0] — 2026-06-25 (Prototipo)

### ✅ Añadido
- Análisis de propuesta del negocio
- Revisión del archivo Excel de precios
- Revisión del archivo de ventas
- Propuesta arquitectural aprobada por el cliente
