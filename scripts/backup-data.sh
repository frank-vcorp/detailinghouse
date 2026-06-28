#!/bin/bash
# ============================================================
# DetailingHouse — Script de Backup de Datos
# Copia las instrucciones para exportar datos del localStorage
# ============================================================

echo ""
echo "════════════════════════════════════════════════"
echo "  DetailingHouse — Backup de Datos Admin"
echo "════════════════════════════════════════════════"
echo ""
echo "Para hacer backup de los datos del sistema admin:"
echo ""
echo "1. Abre el sitio web en tu navegador"
echo "2. Presiona F12 (Herramientas de desarrollador)"
echo "3. Ve a la pestaña 'Console'"
echo "4. Copia y pega este código:"
echo ""
echo "─────────────────────────────────────────────────"
cat << 'SCRIPT'
// Backup completo de datos DetailingHouse
const backup = {
  timestamp: new Date().toISOString(),
  version: "3.0.0",
  negocio: "DetailingHouse",
  products:     JSON.parse(localStorage.getItem('dh_products')     || '[]'),
  sales:        JSON.parse(localStorage.getItem('dh_sales')        || '[]'),
  customers:    JSON.parse(localStorage.getItem('dh_customers')    || '[]'),
  cashbox:      JSON.parse(localStorage.getItem('dh_cashbox')      || '{}'),
  appointments: JSON.parse(localStorage.getItem('dh_appointments') || '[]'),
  payroll:      JSON.parse(localStorage.getItem('dh_payroll')      || '[]'),
};

// Mostrar en consola
console.log("=== BACKUP DETAILINGHOUSE ===");
console.log(JSON.stringify(backup, null, 2));

// Descargar como archivo JSON
const blob = new Blob([JSON.stringify(backup, null, 2)], {type: 'application/json'});
const url = URL.createObjectURL(blob);
const a = document.createElement('a');
a.href = url;
a.download = `detailinghouse-backup-${new Date().toISOString().split('T')[0]}.json`;
a.click();
console.log("✅ Backup descargado!");
SCRIPT
echo "─────────────────────────────────────────────────"
echo ""
echo "5. Presiona Enter para ejecutar"
echo "6. Se descargará un archivo .json con todos los datos"
echo ""
echo "Para RESTAURAR datos de un backup:"
echo ""
echo "─────────────────────────────────────────────────"
cat << 'RESTORE'
// Pega el contenido del JSON como variable 'data':
const data = { /* pegar JSON aquí */ };

// Restaurar
if (data.products)     localStorage.setItem('dh_products',     JSON.stringify(data.products));
if (data.sales)        localStorage.setItem('dh_sales',        JSON.stringify(data.sales));
if (data.customers)    localStorage.setItem('dh_customers',    JSON.stringify(data.customers));
if (data.cashbox)      localStorage.setItem('dh_cashbox',      JSON.stringify(data.cashbox));
if (data.appointments) localStorage.setItem('dh_appointments', JSON.stringify(data.appointments));
if (data.payroll)      localStorage.setItem('dh_payroll',      JSON.stringify(data.payroll));

console.log("✅ Datos restaurados. Recarga la página.");
location.reload();
RESTORE
echo "─────────────────────────────────────────────────"
echo ""
echo "════════════════════════════════════════════════"
