# SPEC-FRONTEND-003 — Escapar 4 innerHTML restantes con user-data

**ID:** `FIX-20260710-15`
**Tipo:** Remediación de seguridad (XSS)
**Prioridad:** Alta
**Estimación:** 20 minutos
**Origen:** Auditoría durante `FIX-20260710-07`

---

## 1. Contexto

Durante la implementación de `FIX-20260710-07` (sanitización de `dhAdminModal`), SOFIA detectó 4 `innerHTML` adicionales con user-data sin escapar. Se decidió abrir este ticket para cubrirlas.

**Vectores XSS activos:**
- Si un cliente tiene `name = "<img src=x onerror=alert(1)>"`, se ejecuta en el render del admin
- Si un producto tiene `name` malicioso, se ejecuta en el dashboard
- Si una venta tiene `items[].name` malicioso, se ejecuta en el dashboard

**Helper ya existe** (`escapeHtml` en L4035) — no se necesita nueva implementación, solo aplicar.

## 2. Los 4 innerHTML a escapar

### 2.1 L4396 — `renderPosClientOptions` (datalist)

```js
// ANTES (vulnerable):
list.innerHTML = state.clients.map(c => `<option value="${c.name} — ${c.phone}"></option>`).join('');

// DESPUÉS (seguro):
list.innerHTML = state.clients.map(c => `<option value="${escapeHtml(c.name)} — ${escapeHtml(c.phone)}"></option>`).join('');
```

### 2.2 L4415 — `renderSelectedClientInfo`

```js
// ANTES:
box.innerHTML = `<strong>${client.name}</strong> · ${client.phone}<br>Puntos: <strong>${client.points}</strong> · Visitas: <strong>${visits}</strong><br>${reward}`;

// DESPUÉS:
box.innerHTML = `<strong>${escapeHtml(client.name)}</strong> · ${escapeHtml(client.phone)}<br>Puntos: <strong>${escapeHtml(client.points)}</strong> · Visitas: <strong>${escapeHtml(visits)}</strong><br>${escapeHtml(reward)}`;
```

### 2.3 L4544 — `renderClients` (tabla)

```js
// ANTES:
body.innerHTML = filtered.length ? filtered.map(client => `<tr><td><strong>${client.name}</strong><br><span class="muted">${client.phone} · ${getClientVisits(client.id)} visitas</span></td><td>${client.carType}</td><td>${client.points}</td><td><div class="client-qr">${qrSvg(client.id)}</div></td></tr>`).join('') : '...';

// DESPUÉS (escapar client.name, client.phone, client.carType, client.points):
body.innerHTML = filtered.length ? filtered.map(client => `<tr><td><strong>${escapeHtml(client.name)}</strong><br><span class="muted">${escapeHtml(client.phone)} · ${escapeHtml(getClientVisits(client.id))} visitas</span></td><td>${escapeHtml(client.carType)}</td><td>${escapeHtml(client.points)}</td><td><div class="client-qr">${qrSvg(client.id)}</div></td></tr>`).join('') : '...';
```

**Nota:** `qrSvg(client.id)` no se escapa porque el `id` es UUID generado por backend, no user-input. Sin embargo, por seguridad defensiva se podría escapar. Decisión: NO escapar `qrSvg` (es interno, no afecta XSS).

### 2.4 L4686 — `renderDashboard` stockAlerts

```js
// ANTES:
byId('stockAlerts').innerHTML = low.length ? low.map(item => `<span class="alert-pill">${item.name} · ${item.stock} ud.</span>`).join('') : '<span class="muted">Sin alertas activas.</span>';

// DESPUÉS:
byId('stockAlerts').innerHTML = low.length ? low.map(item => `<span class="alert-pill">${escapeHtml(item.name)} · ${escapeHtml(item.stock)} ud.</span>`).join('') : '<span class="muted">Sin alertas activas.</span>';
```

### 2.5 L4688 — `renderDashboard` recentSalesBody

```js
// ANTES:
byId('recentSalesBody').innerHTML = state.sales.length ? state.sales.slice(0, 6).map(sale => `<tr><td>${new Date(sale.timestamp).toLocaleString('es-MX')}</td><td>${sale.items.map(i => `${i.name} x${i.qty}`).join(', ')}</td><td>${sale.paymentMethod}</td><td>${formatCurrency(sale.total)}</td></tr>`).join('') : '...';

// DESPUÉS (escapar i.name, i.qty, sale.paymentMethod):
byId('recentSalesBody').innerHTML = state.sales.length ? state.sales.slice(0, 6).map(sale => `<tr><td>${new Date(sale.timestamp).toLocaleString('es-MX')}</td><td>${sale.items.map(i => `${escapeHtml(i.name)} x${escapeHtml(i.qty)}`).join(', ')}</td><td>${escapeHtml(sale.paymentMethod)}</td><td>${formatCurrency(sale.total)}</td></tr>`).join('') : '...';
```

## 3. Criterios de aceptación

| ID | Criterio | Verificación |
|---|---|---|
| CA-1 | L4396 usa `escapeHtml` en `c.name` y `c.phone` | `grep -A1 "renderPosClientOptions" index.html \| grep escapeHtml` ≥ 2 |
| CA-2 | L4415 usa `escapeHtml` en `client.name`, `client.phone`, `client.points`, `visits`, `reward` | `grep -A1 "renderSelectedClientInfo" index.html \| grep escapeHtml` ≥ 5 |
| CA-3 | L4544 usa `escapeHtml` en `client.name`, `client.phone`, `client.carType`, `client.points` | `grep -A1 "renderClients" index.html \| grep escapeHtml` ≥ 4 |
| CA-4 | L4686 usa `escapeHtml` en `item.name`, `item.stock` | `grep -A1 "stockAlerts" index.html \| grep escapeHtml` ≥ 2 |
| CA-5 | L4688 usa `escapeHtml` en `i.name`, `i.qty`, `sale.paymentMethod` | `grep -A1 "recentSalesBody" index.html \| grep escapeHtml` ≥ 3 |
| CA-6 | Total de ocurrencias de `escapeHtml` en `index.html` = 16 (anterior) + 16 (nuevas) ≈ 32 | `grep -c "escapeHtml" index.html` ≥ 25 |
| CA-7 | Ningún `${userData}` sin escapar en los 5 innerHTML | `grep -E "(state\.clients\|client\.name\|client\.phone\|item\.name\|item\.stock\|sale\.items\|sale\.paymentMethod\|c\.name\|c\.phone)" index.html \| grep -v escapeHtml` no debe incluir los 5 callers modificados |
| CA-8 | Smoke E2E en producción sigue 18/18 OK | Playwright sin regresión |
| CA-9 | Sin nuevos console errors | Playwright |

## 4. Out-of-scope

- Refactor a `textContent` (sprint futuro)
- DOMPurify (no justificado per `ADR-20260710-05`)
- `qrSvg()` output (interno, no user-input)

## 5. Salida esperada

- 1 commit: `fix(security): escape 4 additional innerHTML with user-data (FIX-20260710-15)`
- 5 líneas modificadas en `index.html`
- 0 innerHTML adicionales con user-data sin escapar
- Smoke E2E producción 18/18

---

**Aprobado por:** INTEGRA
