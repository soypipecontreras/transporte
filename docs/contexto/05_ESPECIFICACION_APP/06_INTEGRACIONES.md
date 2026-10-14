# Integraciones externas

Patrón: **cada integración detrás de un adaptador** con interfaz propia, reintentos, cola de mensajes, registro de cada petición y respuesta, y un modo "manual" de contingencia.

| Sistema | Para qué | Tipo | Notas |
|---|---|---|---|
| **RNDC** (Ministerio de Transporte) | Terceros, vehículos, remesas, manifiestos, cumplidos, tiempos | **Interoperabilidad (web service)** como canal principal; **archivo plano** como contingencia (Res. 20263040016075 de 2026, art. 6 y Manual 4.1). Manual oficial en `07_FUENTES/DOCUMENTOS_OFICIALES` | `AdaptadorRNDC` intercambiable. Las credenciales son de **cada empresa habilitada**. 💡 Además, la plataforma puede pedir el rol **"Empresa de Monitoreo de Flota"** para reportar los tiempos reales por sus clientes |
| **SICE-TAC** | Costo eficiente por ruta y configuración | ⚠️ Verificar si hay un servicio web; si no, se valida al expedir el manifiesto y se usa una tabla de referencia cargada | Crítico para RN-010 |
| **RUNT** | Vehículo, SOAT, RTM, licencias | ⚠️ El acceso requiere convenio o proveedor autorizado | Validaciones RN-050/051 |
| **SIMIT** | Multas | Consulta | Informativo |
| **DIAN: facturación electrónica** | Factura, notas, documento soporte, nómina | Mediante un **proveedor tecnológico** autorizado | RN-150 |
| **DIAN: RADIAN** | Eventos de la factura, endosos | Mediante proveedor / plataforma de factoring | RN-151 |
| **DIAN: tránsito aduanero** | DTA | Portal MUISCA (normalmente lo hace la agencia de aduanas) | Registro manual del número |
| **Bancos / pagos** | Dispersión, recaudo (PSE), pagos inmediatos (Bre-B ⚠️), validación de titularidad | API bancaria / agregador | Fiducia si aplica |
| **Finanzas abiertas** | Lectura de cuentas con consentimiento para el scoring | Agregador autorizado ⚠️ marco de finanzas abiertas de la SFC | Opcional |
| **Centrales de riesgo** | Score e historial | API Datacrédito / TransUnion | Con autorización (Ley 1266) |
| **Listas restrictivas y PEP** | SARLAFT | Proveedor (o descarga de las listas ONU y OFAC) | Diario |
| **KYC / biometría** | Identidad | Proveedor con validación contra la Registraduría ⚠️ | RN-106 |
| **RUES** | Certificados de existencia | Consulta / proveedor | KYB |
| **Rama Judicial, Procuraduría, Contraloría, Policía** | Antecedentes | Consultas públicas / proveedor | Debida diligencia |
| **GPS** (múltiples proveedores) | Posición, eventos, precinto electrónico | API / webhooks; formato normalizado interno | Agregador multiproveedor |
| **Mapas y rutas** | Rutas, ETA, peajes, geocercas | Proveedor de mapas | — |
| **Terminales portuarias y patios** | Citas, EIR, estados | API o EDI (CODECO/COARRI) o manual | Por fases |
| **Aseguradoras** | Pólizas por viaje, siniestros | API / portal | — |
| **Firma electrónica / digital** | Contratos, pagarés | Proveedor certificado (ONAC) para la firma digital | — |
| **Mensajería** | WhatsApp Business, SMS, correo, push | API | Plantillas aprobadas |
| **Contabilidad** | Exportación de asientos | API / archivo | Por cliente |
