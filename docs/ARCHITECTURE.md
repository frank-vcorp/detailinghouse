# 🏗️ Arquitectura — DetailingHouse

## Decisión de Arquitectura: SPA con localStorage

### Contexto
DetailingHouse es un negocio pequeño (2-3 personas) que necesita:
- Una página pública para atraer clientes
- Un sistema de gestión interno (POS, inventario, caja, nómina)
- Presupuesto limitado para infraestructura
- Funcionamiento offline (el equipo trabaja a domicilio)

### Decisión: Aplicación de una sola página (SPA) sin backend

```
┌─────────────────────────────────────────────────────┐
│                  NAVEGADOR DEL USUARIO               │
│                                                      │
│  ┌─────────────────────────────────────────────┐    │
│  │              index.html (SPA)               │    │
│  │                                             │    │
│  │  ┌──────────────┐  ┌─────────────────────┐ │    │
│  │  │ Página       │  │  Panel Admin        │ │    │
│  │  │ Pública      │  │                     │ │    │
│  │  │              │  │  POS │ Inventario   │ │    │
│  │  │  Servicios   │  │  Caja│ Clientes     │ │    │
│  │  │  Productos   │  │  Nom.│ Agenda       │ │    │
│  │  │  Galería     │  │  Dashboard          │ │    │
│  │  │  SEO         │  │                     │ │    │
│  │  └──────────────┘  └─────────────────────┘ │    │
│  │                                             │    │
│  │  ┌─────────────────────────────────────┐   │    │
│  │  │        localStorage (DB local)       │   │    │
│  │  │  dh_products │ dh_sales             │   │    │
│  │  │  dh_customers│ dh_cashbox           │   │    │
│  │  │  dh_appoints │ dh_payroll           │   │    │
│  │  └─────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────┘    │
│                                                      │
└─────────────────────────────────────────────────────┘
                           │
                    ┌──────▼──────┐
                    │   Netlify   │
                    │   (CDN)     │
                    │   HTTPS ✅  │
                    └─────────────┘
```

### Ventajas de esta arquitectura

| Aspecto | Beneficio |
|---------|-----------|
| **Costo** | $0 MXN/mes (Netlify gratis) |
| **Velocidad** | Sin latencia de servidor |
| **Offline** | Funciona sin internet |
| **Mantenimiento** | Un solo archivo HTML |
| **Despliegue** | 2 minutos con Netlify Drop |
| **Respaldo** | Código en GitHub, datos exportables |

### Limitaciones y plan de migración

| Limitación | Solución futura (v4.0) |
|-----------|----------------------|
| Datos solo en un dispositivo | Supabase (DB en la nube) |
| Sin sincronización multi-equipo | API REST + autenticación JWT |
| Contraseñas en código fuente | Autenticación segura |
| Sin Google Calendar real | API de Google Calendar |
| Sin pagos online | SDK de Mercado Pago |

---

## Stack Técnico Actual (v3.0)

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
└── Dark mode nativo

JavaScript Vanilla ES6+
├── localStorage API
├── Canvas API (gráficas)
├── Fetch API (WhatsApp links)
├── módulo de QR (QRCode.js inline)
└── Sin dependencias externas de CDN
```

---

## Decisiones de Diseño

### Por qué NO React (aún)
- El proyecto no requiere actualización frecuente de componentes complejos
- Sin build system = despliegue inmediato sin configuración
- Los socios pueden editar el HTML directamente sin conocer React
- Migración posible cuando se requiera el backend (v4.0)

### Por qué localStorage y NO una base de datos
- El equipo trabaja con 1-2 dispositivos max
- No hay necesidad de acceso simultáneo de múltiples usuarios
- Los datos se pueden exportar a CSV/JSON manualmente
- Supabase está listo para cuando escale el negocio

### Por qué Netlify y NO hosting compartido
- Deploy automático desde GitHub con 0 configuración
- HTTPS gratuito y automático
- CDN global (carga rápida en México)
- Dominio gratuito (*.netlify.app)
