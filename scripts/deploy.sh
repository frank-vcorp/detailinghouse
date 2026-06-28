#!/bin/bash
# ============================================================
# DetailingHouse — Script de Deploy Automatizado
# Uso: ./scripts/deploy.sh [staging|prod]
# ============================================================

set -e  # Detener en caso de error

# ─── Colores ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

# ─── Banner ─────────────────────────────────────────────────
echo -e "${BLUE}"
echo "  ██████╗ ███████╗████████╗ █████╗ ██╗██╗     ██╗███╗   ██╗ ██████╗"
echo "  ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██║██║     ██║████╗  ██║██╔════╝"
echo "  ██║  ██║█████╗     ██║   ███████║██║██║     ██║██╔██╗ ██║██║  ███╗"
echo "  ██║  ██║██╔══╝     ██║   ██╔══██║██║██║     ██║██║╚██╗██║██║   ██║"
echo "  ██████╔╝███████╗   ██║   ██║  ██║██║███████╗██║██║ ╚████║╚██████╔╝"
echo "  ╚═════╝ ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝"
echo "                                    Deploy Script v3.0"
echo -e "${NC}"

# ─── Variables ──────────────────────────────────────────────
DEPLOY_ENV=${1:-"prod"}   # staging | prod
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo -e "${YELLOW}📁 Directorio del proyecto: ${PROJECT_DIR}${NC}"
echo -e "${YELLOW}🚀 Entorno de despliegue: ${DEPLOY_ENV}${NC}"
echo ""

# ─── Verificar dependencias ──────────────────────────────────
echo -e "${BLUE}[1/4] Verificando dependencias...${NC}"

if ! command -v netlify &> /dev/null; then
    echo -e "${YELLOW}⚠️  Netlify CLI no encontrado. Instalando...${NC}"
    npm install -g netlify-cli
    echo -e "${GREEN}✅ Netlify CLI instalado${NC}"
else
    echo -e "${GREEN}✅ Netlify CLI disponible: $(netlify --version)${NC}"
fi

# ─── Verificar archivos clave ────────────────────────────────
echo ""
echo -e "${BLUE}[2/4] Verificando archivos del proyecto...${NC}"

if [ ! -f "${PROJECT_DIR}/index.html" ]; then
    echo -e "${RED}❌ Error: index.html no encontrado en ${PROJECT_DIR}${NC}"
    exit 1
fi

FILE_SIZE=$(wc -c < "${PROJECT_DIR}/index.html")
echo -e "${GREEN}✅ index.html encontrado (${FILE_SIZE} bytes)${NC}"

IMAGE_COUNT=$(ls "${PROJECT_DIR}/assets/images/"*.jpg 2>/dev/null | wc -l)
echo -e "${GREEN}✅ ${IMAGE_COUNT} imágenes en assets/images/${NC}"

# ─── Deploy a Netlify ────────────────────────────────────────
echo ""
echo -e "${BLUE}[3/4] Desplegando en Netlify (${DEPLOY_ENV})...${NC}"
cd "${PROJECT_DIR}"

if [ "$DEPLOY_ENV" = "staging" ]; then
    echo -e "${YELLOW}📡 Desplegando en staging (preview)...${NC}"
    netlify deploy --dir=.
else
    echo -e "${YELLOW}🚀 Desplegando en producción...${NC}"
    netlify deploy --dir=. --prod
fi

# ─── Resumen ─────────────────────────────────────────────────
echo ""
echo -e "${GREEN}[4/4] ✅ Deploy completado exitosamente${NC}"
echo ""
echo -e "${BLUE}══════════════════════════════════════${NC}"
echo -e "${GREEN}  🌐 DetailingHouse está en línea  ${NC}"
echo -e "${BLUE}══════════════════════════════════════${NC}"
echo -e "  Timestamp: ${TIMESTAMP}"
echo -e "  Entorno: ${DEPLOY_ENV}"
echo -e "  Contacto: wa.me/524461153815"
echo -e "${BLUE}══════════════════════════════════════${NC}"
