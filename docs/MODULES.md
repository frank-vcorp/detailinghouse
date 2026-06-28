# 🔧 Módulos del Panel Admin — DetailingHouse

## Acceso al Panel

**URL**: Hacer clic en "Panel Admin" en el footer del sitio

| Rol | Contraseña | Acceso |
|-----|-----------|--------|
| Administrador | `DH2025` | Todos los módulos |
| Empleado | `DH-STAFF` | POS, Agenda, Clientes |

---

## 🛒 Módulo POS (Punto de Venta)

### Flujo de una venta

```
1. Buscar producto (nombre o categoría)
      ↓
2. Agregar al carrito (cantidad)
      ↓
3. Seleccionar método de pago
      ↓
4. Aplicar descuento (opcional)
      ↓
5. Procesar venta
      ↓
6. Enviar ticket por WhatsApp (opcional)
```

### Métodos de pago soportados
- 💵 Efectivo
- 📱 Transferencia bancaria (SPEI/CoDi)
- 💳 Mercado Pago Point (con lector físico)

### Comisiones automáticas
Cada venta distribuye automáticamente:
- **Andrés**: 35% de la utilidad
- **Erika**: 35% de la utilidad
- **Local** (gastos operativos): 30%

---

## 📦 Módulo Inventario

### Estructura de un producto

```json
{
  "id": "A1A-001",
  "nombre": "Vinil Protect",
  "categoria": "Interiores",
  "precio": 150,
  "presentacion": "600 ml",
  "descripcion": "Brillo interior, filtro solar, diluible 1:3",
  "stock": 10,
  "stockMinimo": 3,
  "imagen": ""
}
```

### Alertas de stock
- 🟢 Stock > mínimo: Normal
- 🟡 Stock = mínimo: Advertencia
- 🔴 Stock < mínimo: Alerta crítica

---

## 💳 Módulo Caja Chica

### Estados de la caja

```
CERRADA → [Apertura con monto inicial] → ABIERTA
ABIERTA → [Registrar gastos/ingresos]  → ABIERTA
ABIERTA → [Cierre con resumen]         → CERRADA
```

### Categorías de gastos
- Combustible / gasolina
- Materiales y suministros
- Herramientas y equipos
- Alimentación del equipo
- Otros gastos operativos

---

## 👥 Módulo Clientes

### Datos que se registran

| Campo | Tipo | Requerido |
|-------|------|-----------|
| Nombre completo | Texto | ✅ |
| Teléfono WhatsApp | Número | ✅ |
| Tipo de vehículo | Select | ✅ |
| Marca/Modelo | Texto | Opcional |
| Color del vehículo | Texto | Opcional |
| Fecha de registro | Auto | ✅ |

### Sistema de puntos
- **Ganancia**: 1 punto por cada $10 MXN gastados
- **Consulta**: Escáner QR o búsqueda por nombre
- **QR único**: Generado automáticamente por cliente

---

## 💰 Módulo Nómina

### Período de corte
- **Semanal**: Lunes a Domingo
- **Mensual**: Del 1 al último día del mes

### Fórmula de distribución

```
Ventas brutas del período
  − Gastos operativos (Caja chica)
  = Utilidad neta
      ├── Andrés  → 35% = $X
      ├── Erika   → 35% = $X
      └── Local   → 30% = $X (reinversión)
```

---

## 📅 Módulo Agenda

### Datos de una cita

| Campo | Ejemplo |
|-------|---------|
| Cliente | Juan Pérez |
| Teléfono | 4461234567 |
| Servicio | Paquete Elite |
| Tipo de vehículo | SUV mediana |
| Fecha | 2026-07-15 |
| Hora | 10:00 AM |
| Dirección | Col. Juriquilla, Qro |
| Notas | Puerta chocada derecha |

### Confirmación
Al crear la cita se genera un mensaje preformateado para enviar por WhatsApp al cliente.

---

## 📊 Módulo Dashboard

### Métricas disponibles

| Métrica | Período |
|---------|---------|
| Ventas totales | Hoy / Semana / Mes |
| Número de transacciones | Hoy / Semana / Mes |
| Utilidad neta | Hoy / Semana / Mes |
| Top 5 servicios | Mes actual |
| Top 5 productos | Mes actual |
| Evolución de ventas | Últimos 7 días (gráfica) |

### Exportar reporte
El botón "Exportar CSV" descarga un archivo compatible con:
- Microsoft Excel
- Google Sheets
- LibreOffice Calc
