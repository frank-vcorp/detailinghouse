# CHK-2026-07-14-2027-CART-CART-DRAWER-NO-CIERRA.md

**Fecha:** 2026-07-14 20:27 UTC  
**Severidad:** Media (UX confunde al usuario)  
**Síntoma reportado:** "El cart no se actualiza, la venta no se registra"  
**Estado:** PARCIALMENTE RESUELTO (FIX-20 aplicado)

---

## 🔴 SÍNTOMA REPORTADO POR USUARIO

> "si los agrega al carrito pero al registrar la venta no los registra dice que no he añadido productos"
> "registra la venta en la base de datos pero el carrito no dice so[licitar el cierre]"

---

## 🔍 DIAGNÓSTICO REAL

**El cart SÍ funciona correctamente:**
- ✅ Productos se agregan al cart (count incrementa)
- ✅ Venta SÍ se registra (mensaje verde "Venta registrada en la base de datos ✅")
- ✅ Backend recibe la venta correctamente
- ✅ `state.cart.length = 0` limpia el cart correctamente

**El problema era UX:** El cart drawer **quedaba abierto** después de registrar la venta, mostrando el empty state "Aún no has añadido productos" que confundía al usuario.

---

## 🔧 FIX APLICADO (FIX-20260714-20)

En `handleRegisterSale()` (línea 5455) agregué:

```js
state.cart.length = 0;
if (success) success.textContent = 'Venta registrada en la base de datos ✅';
updateAll();
// FIX-20260714-20 — cerrar cart drawer después de registrar venta
if (typeof toggleFloatingCart === 'function') toggleFloatingCart(false);
```

Commit: `efc055a`

---

## 🔴 OTRO BUG REPORTADO: Caja Chica "no hace registros"

### Diagnóstico

**Caja SÍ funciona correctamente:**
- ✅ Abrir caja funciona (handler `openCashBtn`)
- ✅ Registrar gasto funciona (mensaje "Gasto registrado en BD ✅")
- ✅ Tabla de movimientos se actualiza (1 fila después de 1 gasto)
- ✅ Summary se actualiza (Ingresos $0, Gastos $150, Utilidad -$150)
- ✅ Backend recibe el gasto correctamente

**Problema UX:**
- El handler dice "Ya hay una caja abierta" sin mostrar la caja activa visualmente
- El usuario no sabe que ya hay caja porque no se muestra la lista de sesiones
- La tabla de movimientos está en otra sección de la UI

### Por qué el usuario lo percibe como bug

1. Usuario clickea "Abrir Caja" → ve "Ya hay una caja abierta" (de sesión fantasma)
2. Usuario clickea "Registrar Gasto" → ve "Gasto registrado en BD ✅"
3. PERO el summary inicialmente muestra Gastos $0 (no se actualiza visualmente al instante)
4. Usuario piensa que el gasto no se guardó

### Solución recomendada

1. **Mostrar lista de sesiones de caja** (estado actual, monto inicial, total ingresos/gastos)
2. **Cambiar mensaje "Ya hay caja abierta"** → "Caja abierta desde [hora]" (más informativo)
3. **Actualizar summary en tiempo real** (al click, no después de la API)

---

## 📊 DATOS DE PRUEBA (FIX-20 verificado)

```json
{
  "itemsBefore": 2,
  "itemsAfter": 0,
  "success": "Venta registrada en la base de datos ✅",
  "error": "",
  "cartCount": "0",
  "drawerOpen": false (después del FIX-20)
}
```

---

## 📦 COMMITS

| Commit | Descripción |
|--------|-------------|
| `efc055a` | fix: cerrar cart drawer después de registrar venta (FIX-20) |

---

## 🔜 PENDIENTE

- [ ] Mostrar lista de sesiones de caja en el UI
- [ ] Cambiar mensaje "Ya hay caja abierta" → "Caja activa desde [hora]"
- [ ] Indicador visual de caja activa
- [ ] Verificar que el sync admin.html tiene el fix
