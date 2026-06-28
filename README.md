# 🛡️ DetailingHouse — Plataforma Web Integral

<div align="center">

<br/>

```
██████╗ ███████╗████████╗ █████╗ ██╗██╗     ██╗███╗   ██╗ ██████╗
██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██║██║     ██║████╗  ██║██╔════╝
██║  ██║█████╗     ██║   ███████║██║██║     ██║██╔██╗ ██║██║  ███╗
██║  ██║██╔══╝     ██║   ██╔══██║██║██║     ██║██║╚██╗██║██║   ██║
██████╔╝███████╗   ██║   ██║  ██║██║███████╗██║██║ ╚████║╚██████╔╝
╚═════╝ ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝
                        H O U S E
```

### *"El Arte del Cuidado"*

[![Estado](https://img.shields.io/badge/Estado-Producción-brightgreen?style=for-the-badge)](https://github.com)
[![Versión](https://img.shields.io/badge/Versión-3.0.0-blue?style=for-the-badge)](CHANGELOG.md)
[![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)](https://developer.mozilla.org/es/docs/Web/HTML)
[![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)](https://developer.mozilla.org/es/docs/Web/JavaScript)
[![Netlify](https://img.shields.io/badge/Netlify-00C7B7?style=for-the-badge&logo=netlify&logoColor=white)](https://netlify.com)

**Detallado automotriz profesional a domicilio**
📍 Querétaro y Corregidora, México &nbsp;|&nbsp; 📱 [4461153815](https://wa.me/524461153815)

[🌐 Ver Sitio en Vivo](#-publicación--despliegue) &nbsp;•&nbsp;
[📋 Documentación](#-estructura-del-proyecto) &nbsp;•&nbsp;
[💬 WhatsApp](https://wa.me/524461153815) &nbsp;•&nbsp;
[🐛 Reportar Bug](https://github.com/TU_USUARIO/detailinghouse/issues)

</div>

---

## 📋 Tabla de Contenidos

- [Descripción del Proyecto](#-descripción-del-proyecto)
- [Demo en Vivo](#-demo-en-vivo)
- [Características](#-características)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Instalación y Ejecución Local](#-instalación-y-ejecución-local)
- [Publicación / Despliegue](#-publicación--despliegue)
- [Panel de Administración](#-panel-de-administración)
- [Módulos del Sistema](#-módulos-del-sistema)
- [Catálogo de Productos](#-catálogo-de-productos)
- [Tecnologías Utilizadas](#️-tecnologías-utilizadas)
- [Roadmap](#️-roadmap)
- [Contribuir](#-contribuir)

---

## 🎯 Descripción del Proyecto

**DetailingHouse** es una plataforma web integral de **una sola página (SPA)** que combina:

- ✅ **Página pública** orientada a clientes, con SEO local optimizado para Querétaro
- ✅ **Sistema de gestión interno** con 7 módulos de administración completos
- ✅ **Persistencia de datos** mediante `localStorage` (sin servidor externo requerido)
- ✅ **PWA-ready**: instalable en dispositivos móviles
- ✅ **Catálogo A1A**: 30 productos de detailing organizados en 7 categorías

> 💡 **Arquitectura offline-first**: funciona completamente sin conexión a internet después de la primera carga.

---

## 🌐 Demo en Vivo

| Entorno | URL | Contraseña Admin |
|---------|-----|-----------------|
| 🟢 **Producción** | [detailinghouse.netlify.app](https://detailinghouse.netlify.app) | `DH2025` |
| 🔵 **Preview** | [Ver en Genspark](https://www.genspark.ai/agents?id=cc6db175-1c4c-431e-a404-7e0ee457ccb7) | `DH2025` |

---

## ✨ Características

### 🖥️ Página Pública

| Función | Descripción |
|---------|-------------|
| 🎨 **Hero animado** | Banner principal con imagen real del negocio + CTA WhatsApp |
| 📦 **3 Paquetes de servicio** | Elite, Plus, Esencial — con precios por tipo de vehículo |
| 🔧 **5 Servicios adicionales** | Motor vapor, Cristales, Faros, Asientos, Desinfección |
| 🧴 **Catálogo A1A** | 30 productos con filtros por categoría, precios y descripciones reales |
| 📷 **Galería** | 6 fotos reales del negocio mejoradas con IA |
| ⭐ **Testimonios** | Sección de reseñas de clientes |
| ❓ **FAQ interactivo** | Acordeón con preguntas frecuentes |
| 📍 **Cobertura visual** | Mapa y explicación de zona de atención (Qro + Corregidora) |
| 🔢 **Contadores animados** | Autos atendidos, satisfacción, años de experiencia |
| 💬 **WhatsApp flotante** | Botón animado siempre visible |
| 🔍 **SEO completo** | Meta tags, Open Graph, Twitter Card, JSON-LD LocalBusiness |

### 🔧 Panel de Administración

| Módulo | Funciones Principales |
|--------|----------------------|
| 🛒 **POS** | Cobro rápido, efectivo/transferencia/MP Point, ticket por WhatsApp |
| 📦 **Inventario** | CRUD de 30 productos A1A, stock, alertas de bajo inventario |
| 💳 **Caja Chica** | Apertura/cierre de caja, registro de gastos operativos |
| 👥 **Clientes** | Registro, historial de compras, sistema de puntos, QR único |
| 💰 **Nómina** | Distribución automática: Andrés 35%, Erika 35%, Local 30% |
| 📅 **Agenda** | Calendario visual, citas por servicio y tipo de vehículo |
| 📊 **Dashboard** | Gráficas de ventas, top servicios, exportar a CSV |

---

## 📂 Estructura del Proyecto

```
detailinghouse/
│
├── 📄 index.html                   ← App completa (pública + admin)
├── ⚙️  netlify.toml                 ← Config de despliegue Netlify
├── 🚫 .gitignore                   ← Archivos excluidos de Git
├── 📋 README.md                    ← Este archivo
│
├── 📁 assets/
│   ├── 🖼️  images/                  ← Fotografías del negocio
│   │   ├── motor_completo_hero.jpg  ─ Hero banner (motor abierto)
│   │   ├── puesto_conductor_elite.jpg ─ Interior Elite
│   │   ├── asientos_tela_naranja.jpg  ─ Servicio asientos
│   │   ├── asientos_traseros_completo.jpg
│   │   ├── motor_macro_detallado.jpg  ─ Servicio motor vapor
│   │   ├── interior_tablero_oroch.jpg
│   │   ├── tablero_naranja.jpg
│   │   ├── tapetes_alfombra.jpg
│   │   ├── panel_puerta_interior.jpg
│   │   ├── auto_frontal_motor.jpg
│   │   └── bateria_detallada.jpg
│   │
│   ├── 🎥 videos/                   ← Videos del negocio (agregar aquí)
│   │   └── [colocar .mp4 aquí]
│   │
│   ├── 📄 docs/
│   │   └── Catalogo2026b.pdf        ← Catálogo A1A Ingeniería Mexicana
│   │
│   └── 🎨 icons/                    ← Íconos e iconografía
│       └── [favicon.ico, logo.svg]
│
├── 📁 docs/                         ← Documentación técnica
│   ├── ARCHITECTURE.md              ← Decisiones de arquitectura
│   ├── MODULES.md                   ← Documentación de módulos admin
│   └── CHANGELOG.md                 ← Historial de versiones
│
├── 📁 scripts/                      ← Scripts de utilidad
│   ├── deploy.sh                    ← Deploy automatizado a Netlify
│   └── backup-data.sh               ← Backup de datos localStorage
│
└── 📁 .github/
    └── workflows/
        └── deploy.yml               ← CI/CD automático (GitHub Actions)
```

---

## 💻 Instalación y Ejecución Local

### Requisitos Previos

> ✅ **No requiere ninguna dependencia**. Solo un navegador moderno (Chrome, Firefox, Safari, Edge).

### Método 1 — Abrir directamente (más simple)

```bash
# 1. Clona el repositorio
git clone https://github.com/TU_USUARIO/detailinghouse.git

# 2. Entra a la carpeta
cd detailinghouse

# 3. Abre el archivo en tu navegador
open index.html          # macOS
start index.html         # Windows
xdg-open index.html      # Linux/Ubuntu
```

### Método 2 — Servidor local (recomendado para desarrollo)

**Con Python** *(preinstalado en macOS y Linux)*:
```bash
cd detailinghouse
python3 -m http.server 8080
# Abre: http://localhost:8080
```

**Con Node.js**:
```bash
cd detailinghouse
npx serve .
# Abre: http://localhost:3000
```

**Con VS Code**:
1. Instala la extensión **"Live Server"** (Ritwick Dey)
2. Haz clic derecho en `index.html` → **"Open with Live Server"**
3. Se abrirá automáticamente en `http://127.0.0.1:5500`

### Método 3 — Con Docker *(para desarrollo avanzado)*

```dockerfile
# Crea un archivo Dockerfile con:
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
```

```bash
docker build -t detailinghouse .
docker run -p 8080:80 detailinghouse
# Abre: http://localhost:8080
```

---

## 🌐 Publicación / Despliegue

### ⭐ Opción A — Netlify Drop (Sin cuenta, 2 minutos)

> 🏆 **Recomendado para empezar**

1. Comprime la carpeta del proyecto:
   ```bash
   zip -r detailinghouse.zip detailinghouse/
   ```
2. Ve a **[app.netlify.com/drop](https://app.netlify.com/drop)**
3. Arrastra el archivo `.zip` a la zona gris
4. ¡Listo! Obtienes una URL pública inmediata:
   ```
   https://nombre-aleatorio.netlify.app
   ```

---

### 🔵 Opción B — Netlify CLI (URL personalizada gratis)

```bash
# Paso 1: Instalar Netlify CLI
npm install -g netlify-cli

# Paso 2: Iniciar sesión (crea cuenta gratis en netlify.com)
netlify login

# Paso 3: Desplegar (ejecutar dentro de la carpeta del proyecto)
cd detailinghouse
netlify deploy --dir=. --prod

# Paso 4: Personalizar nombre del sitio
netlify open:site
# En dashboard: Site Settings → Change site name → "detailinghouse"
```

**URL resultante:**
```
https://detailinghouse.netlify.app  ✅
```

O usa el script incluido:
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

---

### 🟢 Opción C — GitHub Pages (con cuenta GitHub)

```bash
# En GitHub.com:
# 1. Crea un repositorio público llamado "detailinghouse"
# 2. Sube los archivos:
git init
git add .
git commit -m "🚀 Initial deploy: DetailingHouse v3.0"
git remote add origin https://github.com/TU_USUARIO/detailinghouse.git
git push -u origin main

# 3. Ve a: Settings → Pages
# 4. Source: "Deploy from a branch"
# 5. Branch: main → / (root)
# 6. Guarda los cambios
```

**URL resultante (tarda ~2 min en activarse):**
```
https://TU_USUARIO.github.io/detailinghouse
```

---

### 🏆 Opción D — Dominio Propio (Producción Final)

> Para usar `https://detailinghouse.mx`

**Paso 1: Comprar dominio**
| Proveedor | Precio anual | Link |
|-----------|-------------|------|
| Namecheap | ~$180 MXN | [namecheap.com](https://namecheap.com) |
| GoDaddy | ~$200 MXN | [godaddy.com](https://godaddy.com) |
| Hostinger | ~$150 MXN | [hostinger.mx](https://hostinger.mx) |

**Paso 2: Conectar con Netlify**
```
En Netlify Dashboard:
→ Site Settings
→ Domain Management
→ Add custom domain
→ Ingresar: detailinghouse.mx
→ Seguir instrucciones de DNS
→ HTTPS automático con Let's Encrypt ✅
```

**Paso 3: Configurar DNS en tu proveedor de dominio**
```
Tipo: CNAME
Nombre: www
Valor: [tu-sitio].netlify.app

Tipo: A
Nombre: @
Valor: 75.2.60.5  (IP de Netlify)
```

---

### ⚡ CI/CD Automático con GitHub Actions

El repositorio incluye un workflow que **despliega automáticamente** cada vez que haces push a `main`:

```yaml
# .github/workflows/deploy.yml — ya incluido en el proyecto
# Solo necesitas configurar NETLIFY_AUTH_TOKEN como secreto en GitHub
```

**Configuración (una sola vez):**
1. En Netlify: User Settings → Applications → New access token
2. En GitHub: Repository Settings → Secrets → `NETLIFY_AUTH_TOKEN`
3. A partir de ahí: cada `git push` despliega automáticamente 🚀

---

## 🔐 Panel de Administración

### Acceso

El panel admin se accede desde el botón **"Panel Admin"** en el footer del sitio web.

| Rol | Contraseña | Módulos disponibles |
|-----|-----------|---------------------|
| 🔴 **Administrador** | `DH2025` | Todos los módulos |
| 🔵 **Empleado** | `DH-STAFF` | POS, Agenda, Clientes |

> ⚠️ **SEGURIDAD**: Cambia estas contraseñas antes de publicar.

**Para cambiar contraseñas** — busca en `index.html`:
```javascript
// Línea ~150 aprox — cambia los valores:
const ADMIN_PASSWORD = 'DH2025';      // ← Cambia esto
const STAFF_PASSWORD = 'DH-STAFF';   // ← Cambia esto
```

### Persistencia de Datos

Todos los datos del admin se guardan en el **localStorage del navegador**:

| Clave | Contenido |
|-------|-----------|
| `dh_products` | Inventario de productos |
| `dh_sales` | Registro de ventas |
| `dh_customers` | Base de datos de clientes |
| `dh_cashbox` | Estado de caja chica |
| `dh_appointments` | Citas agendadas |

**Backup de datos:**
```bash
# En la consola del navegador (F12 → Console):
# Exportar todos los datos
JSON.stringify({
  products: JSON.parse(localStorage.getItem('dh_products')),
  sales: JSON.parse(localStorage.getItem('dh_sales')),
  customers: JSON.parse(localStorage.getItem('dh_customers'))
})
```

---

## 🔧 Módulos del Sistema

### 🛒 POS — Punto de Venta
- Búsqueda rápida de productos por nombre o categoría
- Métodos de pago: Efectivo / Transferencia / Mercado Pago Point
- Cálculo automático de comisiones (35/35/30%)
- Generación de ticket por WhatsApp
- Descuentos por porcentaje o monto fijo

### 📦 Inventario
- CRUD completo de productos con SKU, categoría, precio y stock
- Alertas visuales cuando el stock es < 3 unidades
- Filtros por categoría y búsqueda en tiempo real
- 30 productos A1A preconfigurados

### 💳 Caja Chica
- Apertura de caja con monto inicial
- Registro automático de ingresos por ventas POS
- Registro de gastos por categoría (combustible, materiales, etc.)
- Cierre de caja con resumen del día

### 👥 Clientes + Lealtad
- Registro de clientes con nombre, teléfono y vehículo
- Historial de compras por cliente
- Sistema de puntos (1 punto = $10 MXN gastados)
- QR único por cliente para identificación rápida

### 💰 Nómina Automática
- Distribución configurable de utilidades
- Corte semanal y mensual automático
- Desglose por colaborador:
  - Andrés → 35%
  - Erika → 35%
  - Local (gastos operativos) → 30%

### 📅 Agenda
- Calendario visual mensual
- Nueva cita: cliente, servicio, tipo de vehículo, fecha y hora
- Envío de confirmación por WhatsApp
- Vista de citas del día

### 📊 Dashboard Ejecutivo
- Ventas del día y totales acumuladas
- Gráfica de ventas de los últimos 7 días (Canvas.js)
- Top 5 servicios más vendidos
- Exportar reporte a CSV (compatible con Excel)

---

## 🧴 Catálogo de Productos A1A

Catálogo completo de **A1A Ingeniería Mexicana** incluido en el sistema:

| # | Categoría | Productos | Precio |
|---|-----------|-----------|--------|
| 1 | 🔵 **Interiores** | Vinil Protect, Ecowash, H2L | $120–$150 |
| 2 | 🟠 **Rines y Llantas** | Restored Rim, Shine WP, Shine Base Agua | $110–$150 |
| 3 | 🟢 **Shampoos** | Dark Side, Foam Zero, Active Foam Cera, Foam 12, Nude Paint, Active Foam Motor | $110–$150 |
| 4 | 🟣 **Línea Cerámica** | Shield SiO2, Booster W2, Cerámico A2, Shine Protectant, S2 Ceramic | $190–$1,100 |
| 5 | 🟡 **Ceras** | Last Touch, Booster W2, Reuse | $150–$350 |
| 6 | ⚪ **Molduras** | Shine Protectant, Black Again | $150–$190 |
| 7 | 🔴 **Especiales** | Nice Air, Pingüinator, SAR, Clean Glass, Pads Cleaner, Moon Light, Metal Polish | $110–$250 |

> 📄 Catálogo completo en `assets/docs/Catalogo2026b.pdf`

---

## 🛠️ Tecnologías Utilizadas

```
Frontend
├── HTML5 Semántico
├── CSS3 (Custom Properties, Flexbox, Grid, Animations)
├── JavaScript Vanilla ES6+
│   ├── localStorage API (persistencia de datos)
│   ├── Canvas API (gráficas del dashboard)
│   ├── QRCode.js (códigos QR de clientes)
│   └── jsPDF (generación de reportes)
│
SEO & Metadatos
├── Open Graph (Facebook/WhatsApp)
├── Twitter Card
├── JSON-LD Schema (LocalBusiness)
└── Sitemap XML ready
│
Infraestructura
├── Netlify (hosting + CDN + HTTPS automático)
├── GitHub (control de versiones)
└── GitHub Actions (CI/CD)
```

---

## 🗺️ Roadmap

### ✅ v1.0 — Página Pública Base (Mayo 2026)
- [x] Diseño responsive dark mode
- [x] Sección de servicios y precios
- [x] Catálogo de productos
- [x] WhatsApp flotante

### ✅ v2.0 — Imágenes Reales + Catálogo A1A (Junio 2026)
- [x] 11 fotos reales mejoradas con IA
- [x] Catálogo completo A1A (30 productos)
- [x] Galería antes/después
- [x] Panel admin básico (POS + Inventario)

### ✅ v3.0 — Plataforma Completa (Junio 2026)
- [x] SEO avanzado (JSON-LD, Open Graph, Twitter Card)
- [x] Módulo de Caja Chica
- [x] Módulo de Clientes + Puntos + QR
- [x] Módulo de Nómina automática
- [x] Módulo de Agenda
- [x] Dashboard con gráficas y export CSV
- [x] Sistema de roles (Admin vs Empleado)
- [x] Testimonios, FAQ y sección de cobertura

### 🔄 v3.1 — Videos y Galería (En proceso)
- [ ] Integración de videos del negocio
- [ ] Lightbox para galería de fotos
- [ ] Más fotos del trabajo real

### 🔮 v4.0 — Backend Real (Planeado)
- [ ] Supabase (base de datos en la nube)
- [ ] Autenticación segura (JWT)
- [ ] API REST para sincronización multi-dispositivo
- [ ] Integración Google Calendar (API)
- [ ] PWA con notificaciones push
- [ ] Mercado Pago (pagos online)

### 🔮 v5.0 — App Móvil (Futuro)
- [ ] React Native (iOS + Android)
- [ ] Cámara para escáner de QR
- [ ] Notificaciones push de citas
- [ ] Firma digital del cliente

---

## 🤝 Contribuir

```bash
# 1. Fork el repositorio en GitHub
# 2. Clona tu fork
git clone https://github.com/TU_USUARIO/detailinghouse.git

# 3. Crea una rama para tu mejora
git checkout -b feature/mi-mejora

# 4. Haz tus cambios en index.html o los archivos de docs
# 5. Revisa que se vea bien en móvil y escritorio

# 6. Commit con mensaje descriptivo (convención Conventional Commits)
git add .
git commit -m "feat: agregar integración con Google Calendar"
# Prefijos: feat / fix / docs / style / refactor / test / chore

# 7. Push y abre un Pull Request
git push origin feature/mi-mejora
```

### Guía de Commits

| Prefijo | Uso |
|---------|-----|
| `feat:` | Nueva funcionalidad |
| `fix:` | Corrección de error |
| `docs:` | Cambios en documentación |
| `style:` | Cambios de estilo (CSS, colores) |
| `refactor:` | Refactorización de código |
| `chore:` | Mantenimiento general |

---

## 📞 Soporte y Contacto

| Canal | Detalle |
|-------|---------|
| **WhatsApp Negocio** | [4461153815](https://wa.me/524461153815) |
| **GitHub Issues** | [Reportar un problema](https://github.com/TU_USUARIO/detailinghouse/issues) |
| **Cobertura** | Querétaro y Corregidora, México |

---

## 📄 Licencia

```
Copyright © 2026 DetailingHouse
Todos los derechos reservados.

Este proyecto es de uso privado y exclusivo del negocio DetailingHouse.
No se permite su redistribución, modificación o uso comercial
sin autorización expresa de los propietarios.
```

---

<div align="center">

**Desarrollado con ❤️ para DetailingHouse**

*"El Arte del Cuidado"* 🛡️

[![WhatsApp](https://img.shields.io/badge/WhatsApp-25D366?style=for-the-badge&logo=whatsapp&logoColor=white)](https://wa.me/524461153815)
[![Querétaro](https://img.shields.io/badge/📍_Querétaro-México-red?style=for-the-badge)](https://maps.google.com/?q=Queretaro,Mexico)

---

*DetailingHouse v3.0 — Junio 2026*

</div>
