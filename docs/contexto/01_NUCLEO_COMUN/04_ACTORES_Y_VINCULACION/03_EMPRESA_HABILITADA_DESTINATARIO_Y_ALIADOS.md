# Empresa habilitada, destinatario y aliados

## 1. Empresa habilitada (en la app)

| Requisito para operar en la plataforma | Validación |
|---|---|
| **Resolución de habilitación** vigente para la modalidad de carga | Ministerio de Transporte / consulta pública |
| Sin cancelación ni suspensión de la habilitación; consulta de investigaciones y sanciones de la **Supertransporte** | Supertransporte |
| Usuario y credenciales del **RNDC** (servicio web) | Prueba de conexión |
| Pólizas vigentes | Copia + validación con la aseguradora |
| SARLAFT / PTEE implementados (según los umbrales) | Certificación del oficial de cumplimiento |
| PESV (si aplica) | Evidencia |
| Inscripción DIAN como transportador aduanero (si mueve DTA) | DIAN |
| Facturador electrónico habilitado | DIAN |
| Estados financieros (para evaluar su capacidad de pagar en 5 días) | Revisor fiscal |

**Roles internos:** representante legal, gerente de operaciones, despachador, tesorería, contabilidad, oficial de cumplimiento, auditor (solo lectura).

## 2. Destinatario / cliente final
- Puede ser el mismo generador u otra empresa o persona.
- **App Cliente** liviana: enlace sin descarga obligatoria; OTP por SMS o WhatsApp.
- Funciones:
  - Ver el ETA.
  - Confirmar la cita de descargue.
  - **Firmar la entrega electrónicamente**.
  - Registrar novedades con fotos.
  - Calificar.
- Si el destinatario acepta el contrato, se vuelve generador (C. Co. arts. 1008 y 1009) y responde solidariamente por el flete.

## 3. Aliados

| Aliado | Rol | Tipo de integración |
|---|---|---|
| Proveedores de GPS | Posición, eventos | API / webhooks |
| Aseguradoras | Pólizas por viaje, reclamaciones | API / portal |
| Bancos, fintech, factoring | Crédito, factoring, pagos | API, finanzas abiertas |
| Centrales de riesgo (Datacrédito Experian, TransUnion) | Historial y score | API con autorización |
| Proveedores KYC / biometría | Identidad | API |
| Proveedor de facturación electrónica | Factura, notas, documento soporte, RADIAN | API |
| Terminales y patios | Citas, EIR | API / EDI / manual |
| Parqueaderos y estaciones aliadas | Enturnamiento virtual, descuentos en combustible | Convenio |
| Talleres, llantas, combustible | Beneficios y financiación para transportistas | Convenio |
