# SPEC-BACKEND-001: Tabla y endpoints para servicios

**ID:** ARCH-20260711-01  
**Fecha:** 2026-07-11  
**Estado:** Planificado  
**Autor:** INTEGRA  
**Delegado a:** SOFIA

---

## 1. Contexto

Actualmente los 8 servicios del POS están hardcodeados en el frontend (`serviceCatalog` línea 3932). No hay tabla en la base de datos ni endpoints para editarlos.

**Servicios actuales:**
```javascript
{ id: 'SRV-001', name: 'Paquete Elite', price: 2200, type: 'service' }
{ id: 'SRV-002', name: 'Paquete Plus', price: 1900, type: 'service' }
{ id: 'SRV-003', name: 'Paquete Esencial', price: 250, type: 'service' }
{ id: 'SRV-004', name: 'Lavado de motor a vapor', price: 500, type: 'service' }
{ id: 'SRV-005', name: 'Protección de cristales', price: 800, type: 'service' }
{ id: 'SRV-006', name: 'Pulido de faros', price: 500, type: 'service' }
{ id: 'SRV-007', name: 'Lavado de asientos', price: 900, type: 'service' }
{ id: 'SRV-008', name: 'Desinfección de ductos de aire', price: 300, type: 'service' }
```

## 2. Objetivos

1. Crear tabla `services` en PostgreSQL
2. Agregar endpoints CRUD completos
3. Migrar los 8 servicios existentes a la BD
4. Permitir agregar/editar/eliminar servicios desde el admin

## 3. Esquema de base de datos

### 3.1 Nueva tabla `services`

```sql
CREATE TABLE IF NOT EXISTS services (
  id            VARCHAR(20) PRIMARY KEY,  -- 'SRV-001', 'SRV-002', etc.
  name          VARCHAR(100) NOT NULL,
  price         NUMERIC(10,2) NOT NULL DEFAULT 0,
  description   TEXT,
  emoji         VARCHAR(10),              -- '🚗', '✨', etc.
  category      VARCHAR(50) NOT NULL DEFAULT 'principal',  -- 'principal' | 'secundario'
  duration      INTEGER,                  -- duración estimada en minutos (opcional)
  active        BOOLEAN NOT NULL DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_services_category ON services(category);
CREATE INDEX IF NOT EXISTS idx_services_active ON services(active);
```

### 3.2 Datos iniciales (seed)

```javascript
const services = [
  { id: 'SRV-001', name: 'Paquete Elite', price: 2200, emoji: '🚗', category: 'principal', description: 'Paquete completo premium con todos los servicios principales y secundarios.' },
  { id: 'SRV-002', name: 'Paquete Plus', price: 1900, emoji: '✨', category: 'principal', description: 'Paquete intermedio con servicios esenciales y algunos secundarios.' },
  { id: 'SRV-003', name: 'Paquete Esencial', price: 250, emoji: '🧼', category: 'principal', description: 'Lavado básico con productos premium.' },
  { id: 'SRV-004', name: 'Lavado de motor a vapor', price: 500, emoji: '⚙️', category: 'secundario', description: 'Limpieza profunda del motor con vapor a alta presión.' },
  { id: 'SRV-005', name: 'Protección de cristales', price: 800, emoji: '🛡️', category: 'secundario', description: 'Aplicación de sellador hidrofóbico en vidrios.' },
  { id: 'SRV-006', name: 'Pulido de faros', price: 500, emoji: '💡', category: 'secundario', description: 'Restauración de faros opacos o amarillentos.' },
  { id: 'SRV-007', name: 'Lavado de asientos', price: 900, emoji: '💺', category: 'secundario', description: 'Limpieza profunda de tapicería con extracción.' },
  { id: 'SRV-008', name: 'Desinfección de ductos de aire', price: 300, emoji: '🌬️', category: 'secundario', description: 'Ozonificación del sistema de aire acondicionado.' }
];
```

## 4. Endpoints API

### 4.1 GET /api/services — Listar servicios (público)

**Respuesta:**
```json
[
  {
    "id": "SRV-001",
    "name": "Paquete Elite",
    "price": 2200,
    "description": "Paquete completo premium...",
    "emoji": "🚗",
    "category": "principal",
    "duration": null,
    "active": true
  }
]
```

### 4.2 GET /api/services/:id — Detalle de servicio (público)

### 4.3 POST /api/services — Crear servicio (admin)

**Body:**
```json
{
  "id": "SRV-009",
  "name": "Nuevo servicio",
  "price": 1500,
  "description": "Descripción del servicio",
  "emoji": "⭐",
  "category": "secundario",
  "duration": 120
}
```

**Validaciones:**
- `id` único (si ya existe, error 409)
- `name` requerido
- `price` >= 0
- `category` en ['principal', 'secundario']

### 4.4 PATCH /api/services/:id — Actualizar servicio (admin)

**Body:** (todos los campos opcionales)
```json
{
  "name": "Nuevo nombre",
  "price": 2500,
  "description": "Nueva descripción",
  "emoji": "✨",
  "category": "principal",
  "duration": 180
}
```

### 4.5 DELETE /api/services/:id — Desactivar servicio (admin, soft delete)

**Respuesta:**
```json
{
  "ok": true,
  "message": "Servicio desactivado"
}
```

## 5. Migración incremental

Agregar a `db/migrate.js`:

```javascript
// Migración incremental
ALTER TABLE services ADD COLUMN IF NOT EXISTS duration INTEGER;
ALTER TABLE services ADD COLUMN IF NOT EXISTS active BOOLEAN NOT NULL DEFAULT true;
```

## 6. Seed script

Crear `db/seed_services.js`:

```javascript
const services = [ /* array de 8 servicios */ ];

async function seed() {
  const { rows: count } = await pool.query('SELECT COUNT(*) FROM services');
  if (parseInt(count[0].count) > 0) {
    console.log(`⚠️  Ya hay ${count[0].count} servicios. Limpiando...`);
    await pool.query('DELETE FROM services');
  }

  for (const s of services) {
    await pool.query(
      `INSERT INTO services (id, name, price, description, emoji, category, duration)
       VALUES ($1,$2,$3,$4,$5,$6,$7) ON CONFLICT (id) DO UPDATE SET
       name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description,
       emoji=EXCLUDED.emoji, category=EXCLUDED.category, duration=EXCLUDED.duration,
       updated_at=NOW()`,
      [s.id, s.name, s.price, s.description, s.emoji, s.category, s.duration]
    );
  }
  console.log(`✅ ${services.length} servicios cargados`);
}
```

## 7. Criterios de aceptación

- [ ] CA-1: Tabla `services` creada en PostgreSQL
- [ ] CA-2: 8 servicios iniciales cargados con datos correctos
- [ ] CA-3: GET `/api/services` devuelve lista completa
- [ ] CA-4: POST `/api/services` crea nuevo servicio (requiere auth admin)
- [ ] CA-5: PATCH `/api/services/:id` actualiza campos (requiere auth admin)
- [ ] CA-6: DELETE `/api/services/:id` desactiva servicio (soft delete, requiere auth admin)
- [ ] CA-7: Validaciones funcionan (precio >= 0, campos requeridos, ID único)
- [ ] CA-8: Endpoints públicos NO requieren autenticación
- [ ] CA-9: Endpoints admin requieren JWT con rol admin

## 8. Validaciones técnicas

1. Ejecutar migración: `node db/migrate.js`
2. Ejecutar seed: `node db/seed_services.js`
3. Probar endpoints con curl/Postman:
   ```bash
   # Login
   curl -X POST https://detailinghouse-api-production.up.railway.app/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"username":"admin","password":"DH2025"}'
   
   # Listar servicios (público)
   curl https://detailinghouse-api-production.up.railway.app/api/services
   
   # Crear servicio (admin)
   curl -X POST https://detailinghouse-api-production.up.railway.app/api/services \
     -H "Authorization: Bearer <token>" \
     -H "Content-Type: application/json" \
     -d '{"id":"SRV-009","name":"Test","price":100,"category":"secundario"}'
   
   # Actualizar servicio
   curl -X PATCH https://detailinghouse-api-production.up.railway.app/api/services/SRV-009 \
     -H "Authorization: Bearer <token>" \
     -H "Content-Type: application/json" \
     -d '{"price":150}'
   
   # Desactivar servicio
   curl -X DELETE https://detailinghouse-api-production.up.railway.app/api/services/SRV-009 \
     -H "Authorization: Bearer <token>"
   ```

4. Deploy a Railway: `railway up`

## 9. Riesgos

- **Riesgo bajo:** Si el seed falla, los servicios siguen hardcodeados en el frontend (fallback)
- **Riesgo bajo:** Los endpoints nuevos no rompen nada existente

## 10. Timeline

- **Día 1:** Implementar tabla + endpoints + seed + tests
- **Día 2:** Deploy + verificación en producción

## 11. Dependencias

- Ninguna (se puede hacer en paralelo con SPEC-FRONTEND-003/004)

## 12. Rollback

Si hay problemas:
1. Revertir commit en `detailinghouse-api`
2. Railway redeploy automático
3. Frontend sigue usando `serviceCatalog` hardcodeado (fallback)
