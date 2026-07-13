# CHK-2026-07-13-0601-FIX16-admin-layout-bug.md

**Fecha:** 2026-07-13 06:01 UTC  
**Severidad:** Alta (bloquea uso del admin)  
**Síntoma reportado:** "no veo los módulos en pantalla" / "no entra al admin"  
**Estado:** RESUELTO en commit `495c802` (FIX-16) + `885b6b2` (FIX-19)  
**Recurrencia:** 5+ veces (FIX-07, sync issues, FIX-13, FIX-16, FIX-19)

---

## 🔴 SÍNTOMA EXACTO

Cuando el usuario está logueado en `/admin`, ve:
- ✅ Sidebar con logo "DETAILINGHOUSE / PANEL DE ADMINISTRACIÓN"
- ✅ 8 nav-items visibles
- ✅ RoleBadge "ADMIN"
- ❌ **Main content área VACÍO o casi vacío** — los módulos (POS, Dashboard, Inventario, etc.) NO se ven
- ❌ Si el viewport es < 1100px, el main queda **fuera del viewport** (Y=731) → invisible

---

## 🔍 DIAGNÓSTICO (ejecutar cuando vuelva a pasar)

### Paso 1: Confirmar el layout
```bash
# En la consola del navegador (F12) o via Playwright:
const shell = document.querySelector('.admin-shell');
const sidebar = document.querySelector('.admin-sidebar');
const main = document.querySelector('.admin-main');

console.table({
  shell: {
    flexDir: getComputedStyle(shell).flexDirection,  // DEBE ser "row"
    width: shell.offsetWidth,
    height: shell.offsetHeight
  },
  sidebar: {
    width: sidebar.offsetWidth,   // DEBE ser 240
    height: sidebar.offsetHeight, // DEBE ser ~898 (viewport - 2)
    x: sidebar.getBoundingClientRect().x,  // DEBE ser 1
    y: sidebar.getBoundingClientRect().y   // DEBE ser 1
  },
  main: {
    width: main.offsetWidth,      // DEBE ser 1158 (1440 - 240 - 2)
    height: main.offsetHeight,
    x: main.getBoundingClientRect().x,  // DEBE ser 241
    y: main.getBoundingClientRect().y   // DEBE ser 1 (NO 731)
  }
});
```

### Interpretación

| Métrica | Si está MAL | Si está BIEN |
|---------|------------|--------------|
| `shell.flexDir` | `column` | `row` |
| `sidebar.height` | 731 (cap a 731) | ~898 (full viewport) |
| `main.x` | 1 (apilado, ocupa todo el ancho) | 241 (a la derecha del sidebar) |
| `main.y` | **731** (fuera de viewport) | 1 (visible) |
| `main.width` | 1438 (full width) | 1158 (viewport - sidebar) |

Si `shell.flexDir` es `column` → **CONFIRMADO EL BUG FIX-16**.

---

## 🐛 CAUSA RAÍZ

Hay **2 reglas CSS de `.admin-shell`** en el archivo. La regla más antigua (línea 1156) define `flex-direction: column`, y la regla nueva (línea 2903) NO redefine `flex-direction` → hereda `column` por CSS cascade.

### Regla 1 (vieja, línea 1156) — TIENE `flex-direction: column`
```css
.admin-shell {
  width: 100vw;
  max-width: 100vw;
  height: 100dvh;  /* también usa dvh en vez de vh */
  max-height: 100dvh;
  background: #0b0c10;  /* fondo oscuro - tema anterior */
  border: 1px solid rgba(255, 255, 255, 0.09);
  border-radius: 0;
  overflow: hidden;
  box-shadow: 0 24px 80px rgba(0, 0, 0, 0.45);
  display: flex;
  flex-direction: column;  /* ← problema */
}
```

### Regla 2 (nueva, línea 2903) — NO define `flex-direction`
```css
.admin-shell {
  display: flex;
  /* SIN flex-direction — hereda "column" de la regla anterior */
  height: 100dvh;
  background: #F8F9FA;
}
```

### Por qué ocurre
La regla 2903 viene **DESPUÉS** de la 1156 en el CSS, pero como NO redefine `flex-direction`, el navegador usa el último valor declarado para esa propiedad (`column` de la 1156). CSS specificity es igual (misma clase), gana el orden, pero el valor es heredado de la regla anterior.

---

## 🔧 FIX (aplicar cuando se detecte el bug)

### Editar manualmente en AMBOS archivos

**Archivo 1:** `/home/frank/repos/detailinghouse/index.html`

**Archivo 2:** `/home/frank/repos/detailinghouse/admin.html`

**Cambio en cada archivo:**

```css
/* ANTES (línea 2903) */
.admin-shell {
  display: flex;
  height: 100dvh;
  background: #F8F9FA;
}

/* DESPUÉS (corregido) */
.admin-shell {
  display: flex;
  flex-direction: row;  /* ← agregar */
  height: 100dvh;
  background: #F8F9FA;
}
```

### ⚠️ NO usar `cp index.html admin.html` para sincronizar

El `cp` copia el `index.html` completo sobre `admin.html`, lo cual:
- ✅ Sincroniza la mayoría de cambios
- ❌ **ELIMINA el script `autoOpenAdmin()` que solo existe en admin.html**
- ❌ **ELIMINA el handler de `closeAdmin` que navega a '/'**
- ❌ **PUEDE sobrescribir otros cambios únicos de admin.html**

**Alternativa segura para sincronizar:**
```bash
# 1. Hacer cambios en index.html PRIMERO
# 2. Usar diff + patch para traer solo los cambios necesarios a admin.html:
diff -u admin.html index.html > /tmp/admin.patch
# 3. Editar admin.html manualmente para preservar scripts únicos
# 4. NUNCA usar cp -f
```

### Después del fix, verificar:
```bash
# En el navegador, abrir DevTools → Console:
const shell = document.querySelector('.admin-shell');
console.log('flex-direction:', getComputedStyle(shell).flexDirection);
// DEBE mostrar: "row"
```

---

## 🔄 HISTORIAL DE RECURRENCIA

| Fecha | Commit | Síntoma | Causa |
|-------|--------|---------|-------|
| 2026-07-11 | `40b1992` (FIX-07) | Layout admin roto (test 1) | flex-direction: column en regla vieja |
| 2026-07-12 | (sync cp) | Layout admin roto (test 2) | `cp index.html admin.html` perdió el fix |
| 2026-07-12 | `5e3373a` (sync) | Layout admin roto (test 3) | sync eliminó cambio |
| 2026-07-12 | `60d44df` (logo fix) | Layout admin roto (test 4) | sync eliminó cambio |
| 2026-07-13 | `495c802` (FIX-16) | **RESUELTO** | flex-direction: row agregado a AMBOS archivos manualmente |

**Patrón identificado:** Cada vez que uso `cp index.html admin.html` para "sincronizar", el cambio de `flex-direction: row` se pierde. Es un ciclo vicioso:

1. Edito index.html (agregar flex-direction: row)
2. Hago `cp index.html admin.html` para sincronizar
3. admin.html ahora tiene flex-direction: row ✅
4. **PERO** admin.html pierde el script `autoOpenAdmin()` que solo vivía ahí ❌
5. Para recuperar el script, edito admin.html directamente
6. **PERO** ahora admin.html puede tener cambios divergentes de index.html
7. Si vuelvo a hacer `cp` para sincronizar, vuelvo al paso 2

**Solución al ciclo:** Editar AMBOS archivos manualmente cuando se hagan cambios en CSS compartido. Usar `cp` SOLO para sincronizar cambios específicos del contenido público (secciones de marketing, etc.).

---

## 🛠️ DIAGNÓSTICO RÁPIDO (si vuelve a pasar)

### Paso 1: Verificar flex-direction
```bash
# En el navegador o Playwright:
getComputedStyle(document.querySelector('.admin-shell')).flexDirection
# DEBE ser: "row"
# Si es "column" → bug FIX-16
```

### Paso 2: Verificar dimensiones
```bash
# Si main.offsetWidth === 1438 (full width) → bug FIX-16
# Si main.offsetWidth === 1158 (resto después de sidebar) → OK
```

### Paso 3: Aplicar fix
1. Editar `index.html` línea 2903, agregar `flex-direction: row`
2. Editar `admin.html` línea 2903, agregar `flex-direction: row`
3. **NO usar cp**
4. Commit ambos archivos
5. Push

### Paso 4: Verificar post-fix
```bash
# En Playwright:
const main = document.querySelector('.admin-main');
const rect = main.getBoundingClientRect();
console.log({x: rect.x, y: rect.y, width: rect.width, height: rect.height});
# DEBE ser: {x: 241, y: 1, width: 1198, height: 898}
# Si y > 100 → bug NO resuelto
```

---

## 📋 OTRAS REGLAS CSS CON EL MISMO PROBLEMA

Este patrón de "regla vieja vs regla nueva" puede afectar otras clases. Revisar si se ven mal:

- `.admin-sidebar` (línea 2912)
- `.admin-main` (línea 2984)
- `.admin-overlay` (línea 1119)
- `.nav-item`
- `.role-badge`

Si alguna tiene comportamiento incorrecto, buscar reglas duplicadas y verificar specificity.

---

## ⚠️ BUG RELACIONADO: Script `autoOpenAdmin` perdido (FIX-19)

**Síntoma:** "no entra al admin" (mismo síntoma que FIX-16 pero causa diferente)

**Causa raíz:** Cada vez que uso `cp index.html admin.html` para sincronizar, el script `autoOpenAdmin` (que solo existe en admin.html) se PIERDE.

**Diagnóstico rápido:**
```js
typeof autoOpenAdmin
// Si retorna "undefined" → script perdido, aplicar FIX-19
```

**Fix:** Agregar el script manualmente en `admin.html` (NO usar cp). Ver snippet en commit `885b6b2`.

**Prevención:** Después de cada `cp index.html admin.html`, ejecutar:
```bash
grep -c "autoOpenAdmin" admin.html
# Debe ser >0. Si es 0, restaurar el script.
```

---

## 🔗 COMMITS RELACIONADOS

- `40b1992` - Primer fix del layout (FIX-07)
- `5e3373a`, `60d44df` - Syncs que perdieron el fix
- `495c802` - FIX-16 definitivo (flex-direction: row)
- `9d63af4` - Sync POS que perdió el script autoOpenAdmin
- `885b6b2` - FIX-19: restaurar script autoOpenAdmin

---

## 📸 SCREENSHOTS DE REFERENCIA

- `admin-layout-arreglado-20260713.png` — Layout correcto (sidebar 240 + main 1198 lado a lado)
- `admin-layout-mal-antes-fix16.png` — Layout mal (sidebar 731 + main 167 apilados)

---

## ⚠️ CHECKLIST PARA FUTURAS SINCRONIZACIONES

Cuando necesites sincronizar cambios entre `index.html` y `admin.html`:

- [ ] **NO usar `cp index.html admin.html` directamente**
- [ ] Hacer cambios en `index.html` primero
- [ ] Aplicar cambios manualmente a `admin.html` (mismas líneas)
- [ ] Verificar que el script `autoOpenAdmin()` sigue en `admin.html`
- [ ] Verificar que el handler `closeAdmin` → `/` sigue en `admin.html`
- [ ] Commit AMBOS archivos
- [ ] Push
- [ ] Verificar con Playwright que el admin abre correctamente

---

## 💡 LECCIÓN APRENDIDA

**`cp` no es sincronización, es sobrescritura.** Para tener dos archivos similares con diferencias específicas, hay que mantener cada uno por separado, no copiarlos.

Si necesitas una arquitectura donde admin.html sea realmente "derivado" de index.html, considera:
- Un sistema de build que genere admin.html desde una plantilla
- Un único archivo HTML que detecte la URL y muestre/oculte el admin overlay
- Mover el admin a su propio subdominio (admin.dominio.com)

**Mientras tanto:** editar manualmente ambos archivos y documentar las diferencias.

---

**INTEGRA - 2026-07-13 06:01 UTC**
