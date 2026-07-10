# 00 — Arquitectura DetailingHouse

**ID:** `ARCH-20260710-01`
**Generado por:** INTEGRA
**Fecha:** 2026-07-10
**Versión del proyecto:** v4.0.0

---

## 1. Resumen ejecutivo

DetailingHouse es una **plataforma web integral** para un negocio de detallado automotriz a domicilio en Querétaro/Corregidora (México). Combina sitio público de marketing + panel de administración con POS, conectado a una API REST con PostgreSQL.

## 2. Stack detectado

| Capa | Tecnología | Versión | Evidencia |
|---|---|---|---|
| Markup | HTML5 semántico | — | `index.html` L2856-3554 (header, main, section, article, footer) |
| Estilos | CSS3 con custom properties | — | `index.html` (inline, sin preprocesador) |
| Lógica frontend | JavaScript Vanilla ES6+ | — | `index.html` L3876-5329, sin frameworks ni CDN |
| API client | Fetch API + JWT | — | `api.request()` L3883-3900 |
| Persistencia sesión | `localStorage('dh_jwt')` | — | L3904, L3908 |
| Gráficas | Canvas API nativa | — | `drawChart()` L4967 |
| QR | SVG generado in-line (no lib) | — | `qrSvg()` L4780-4792 (⚠️ decorativo, no escaneable) |
| Backend | Node.js + Express | — | Endpoints en `api.*` (L3902-3935) — código del backend NO en este repo |
| DB | PostgreSQL | — | Hosting en Railway |
| Auth | JWT con `Authorization: Bearer` | — | L3887 |
| Hosting frontend | Netlify | — | `netlify.toml` |
| Hosting backend | Railway | — | `railway.json`, `API_BASE` L3878 |
| CI/CD | GitHub Actions | — | `.github/workflows/deploy.yml` |
| Hosting alternativo | Vercel, Docker/Nginx | — | `vercel.json`, `Dockerfile` + `nginx.conf` |
| Build | `echo '✅ build OK'` (Netlify) | — | `netlify.toml` L7 — sitio estático puro |

## 3. Topología

```
[Navegador] → Netlify CDN → index.html (SPA)
                ↓ fetch
            Railway API → PostgreSQL
```

- **Frontend estático**, sin build, sin bundler, sin framework. Cada deploy es un upload del `index.html`.
- **Backend desacoplado**, código fuera del repo. Frontend solo conoce la `API_BASE` hardcodeada.
- **Sincronización multi-dispositivo** vía PostgreSQL (era v3.0 localStorage, migrado en v4.0).

## 4. Estructura de archivos

```
detailinghouse/
├── index.html              # SPA completa (5,333 líneas, pública + admin)
├── netlify.toml            # Deploy + headers seguridad + cache
├── nginx.conf / Dockerfile # Deploy alternativo container
├── railway.json / vercel.json
├── README.md               # Spec funcional (cliente-facing)
├── docs/
│   ├── ARCHITECTURE.md     # Spec arquitectónica (pre-INTEGRA)
│   ├── MODULES.md          # Spec de los 7 módulos admin (pre-INTEGRA)
│   └── CHANGELOG.md        # Historial v0.1 → v4.0
├── assets/
│   ├── images/   (11 .jpg)
│   ├── icons/    (favicon.png)
│   └── docs/     (Catalogo2026b.pdf — A1A)
├── scripts/                # deploy.sh, backup-data.sh
└── .github/workflows/deploy.yml
```

## 5. Decisiones arquitectónicas documentadas

Ver `context/decisions/`:

- `ADR-20260710-01` — Vanilla JS, sin React/framework
- `ADR-20260710-02` — PostgreSQL + Railway + Netlify
- `ADR-20260710-03` — Roles hardcodeados en frontend (DH2025 / DH-STAFF)
- `ADR-20260710-04` — Catálogo `baseCatalog` hardcodeado en frontend

## 6. Restricciones y dependencias críticas

| Restricción | Impacto |
|---|---|
| `API_BASE` hardcodeada en JS | Cambio de entorno requiere redeploy del frontend |
| Magic strings de roles (`DH2025`/`DH-STAFF`) en JS | Nuevos usuarios requieren cambio de código |
| Catálogo `baseCatalog` duplica la DB | Riesgo de inconsistencia de precios |
| Sin CSP, sin SRI, sin SW real | PWA-ready está anunciado pero no implementado |
| 2 bloques `<script>` paralelos con código duplicado | Mantenibilidad comprometida (FIX-20260710-01) |
| Backend en repo separado | No versionado junto con frontend |

## 7. Entornos

| Entorno | URL | Notas |
|---|---|---|
| Producción | `https://detailinghouse.netlify.app` | Netlify CDN |
| Preview | Genspark AI | Temporal |
| API | `https://detailinghouse-api-production.up.railway.app/api` | Railway |
| Local | `python3 -m http.server 8080` o abrir `index.html` | No requiere build |

## 8. Estado de salud (auditado 2026-07-10)

- ✅ Spec funcional cubierta (~85% cumplimiento)
- ✅ Stack documentado
- 🔴 Código duplicado entre script blocks (FIX-20260710-01)
- 🔴 5 endpoints API declarados pero no consumidos
- ⚠️ Sin tests automatizados
- ⚠️ Sin CSP
