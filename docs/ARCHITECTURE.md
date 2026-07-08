# 🏗️ Arquitectura — DetailingHouse

## Decisión de Arquitectura: SPA + API REST con PostgreSQL (v4.0)

### Contexto
DetailingHouse creció de 2-3 personas a un equipo que necesita:
- Sincronización de datos entre múltiples dispositivos
- Persistencia centralizada (no atada a un solo navegador)
- Autenticación segura con roles diferenciados
- API REST escalable con base de datos relacional

### Decisión: SPA (frontend) + API REST en Railway + PostgreSQL (backend)

```
┌───────────────────────────────────────────────────────┐
│                    NAVEGADOR DEL USUARIO                │
│                                                         │
│  ┌───────────────────────────────────────────────┐     │
│  │                index.html (SPA)                │     │
│  │                                                │     │
│  │  ┌──────────────┐  ┌─────────────────────┐    │     │
│  │  │ Página       │  │  Panel Admin        │    │     │
│  │  │ Pública      │  │                     │    │     │
│  │  │  Servicios   │  │  POS │ Inventario   │    │     │
│  │  │  Productos   │  │  Caja│ Clientes     │    │     │
│  │  │  Galería     │  │  Nom.│ Agenda       │    │     │
│  │  │  SEO         │  │  Dashboard          │    │     │
│  │  └──────────────┘  └─────────────────────┘    │     │
│  │                                                │     │
│  │  ┌─────────────────────────────────────┐      │     │
│  │  │  localStorage (solo JWT: 'dh_jwt')   │      │     │
│  │  └─────────────────────────────────────┘      │     │
│  │                                                │     │
│  │  ┌─────────────────────────────────────┐      │     │
│  │  │  Fetch API → API REST (HTTPS)        │      │     │
│  │  │  Authorization: Bearer <jwt>         │      │     │
│  │  └─────────────────────────────────────┘      │     │
│  └───────────────────────────────────────────────┘     │
│                         │                               │
└─────────────────────────┼───────────────────────────────┘
                          │ HTTPS
                   ┌──────▼──────┐
                   │   Netlify    │
                   │   (CDN)      │
                   │   HTTPS ✅   │
                   └──────┬──────┘
                          │
                   ┌──────▼──────────────────┐
                   │  API REST (Railway)      │
                   │  https://detailinghouse-  │
                   │  api-production.up.       │
                   │  railway.app/api          │
                   │                           │
                   │  /auth/login     (JWT)    │
                   │  /inventory      (GET/PUT)│
                   │  /clients        (GET/POST)│
                   │  /sales          (GET/POST)│
                   │  /appointments   (GET/POST)│
                   └──────┬──────────────────┘
                          │
                   ┌──────▼──────┐
                   │  PostgreSQL  │
                   │  (Railway)   │
                   │              │
                   │  products    │
                   │  clients     │
                   │  sales       │
                   │  appointments│
                   │  cash_sessions│
                   │  payroll_cuts│
                   │  users       │
                   └──────────────┘
```

### Ventajas de esta arquitectura

| Aspecto | Beneficio |
|---------|-----------|
| **Costo** | ~$5 USD/mes (Railway) + $0 Netlify |
| **Sincronización** | Datos centralizados, multi-dispositivo |
| **Seguridad** | JWT + roles (admin/staff) |
| **Persistencia** | PostgreSQL relacional con backups automáticos |
| **Mantenimiento** | Frontend SPA + API REST separados |
| **Despliegue** | Auto-deploy desde GitHub |
| **Respaldo** | DB en la nube + código en GitHub |

### Limitaciones y plan de migración

| Limitación anterior (v3.0) | Solución aplicada (v4.0) |
|---------------------------|--------------------------|
| Datos solo en un dispositivo | ✅ PostgreSQL en Railway |
| Sin sincronización multi-equipo | ✅ API REST + JWT |
| Contraseñas en código fuente | ✅ Auth backend con JWT |
| Sin Google Calendar real | Pendiente v5.0 |
| Sin pagos online | Pendiente v5.0 |

---

## Stack Técnico Actual (v4.0)

```
HTML5 Semántico
├── Estructura semántica (header, main, section, footer, article)
├── Meta tags SEO completos
├── Open Graph (para WhatsApp/Facebook)
├── Twitter Card
└── JSON-LD Schema.org (LocalBusiness)

CSS3
├── Custom Properties (variables CSS)
├── CSS Grid y Flexbox
├── Animaciones y transiciones
├── Diseño mobile-first (responsivo)
├── Dark mode nativo
├── .admin-toast / .admin-modal (feedback visual v4.0)
└── Transiciones de entrada/salida para toasts/modals

JavaScript Vanilla ES6+
├── Fetch API → API REST Railway (POST/GET/PUT)
├── Authorization: Bearer <jwt> en headers
├── localStorage (solo JWT: 'dh_jwt')
├── Canvas API (gráficas del dashboard)
├── dhAdminModal() / dhAdminToast() (UI visual v4.0)
├── Carrito SOT por closure (sin duplicación)
├── módulo de QR (QRCode.js inline)
└── Sin dependencias externas de CDN

Backend (v4.0 — Railway)
├── Node.js + Express
├── PostgreSQL (Railway DB)
├── JWT Authentication (/auth/login)
├── Endpoints REST:
│   ├── /auth/login        (POST)
│   ├── /inventory         (GET)
│   ├── /inventory/:sku/stock (PUT)
│   ├── /inventory/:sku/price (PUT)
│   ├── /clients           (GET, POST)
│   ├── /sales             (GET, POST)
│   ├── /appointments      (GET, POST)
│   └── /payroll/cuts      (POST)
└── CORS habilitado para Netlify
```

---

## Decisiones de Diseño

### Por qué NO React (aún)
- El proyecto no requiere actualización frecuente de componentes complejos
- Sin build system = despliegue inmediato sin configuración
- Los socios pueden editar el HTML directamente sin conocer React
- Migración posible cuando se requiera el backend (v4.0)

### Por qué PostgreSQL y NO localStorage (cambio v4.0)
- El negocio creció: necesita acceso desde múltiples dispositivos
- Sincronización en tiempo real entre socios y empleados
- Los datos viven en la nube: backups automáticos de Railway
- Escalable: listo para agregar pagos online y app móvil (v5.0)
- localStorage se mantiene solo para el JWT (persistencia de sesión)

### Por qué Netlify y NO hosting compartido
- Deploy automático desde GitHub con 0 configuración
- HTTPS gratuito y automático
- CDN global (carga rápida en México)
- Dominio gratuito (*.netlify.app)
