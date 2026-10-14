# Propietario (titular) y conductor

## 1. Tipos de transportista en la app

| Tipo | Descripción |
|---|---|
| **Hombre-camión** | Propietario que conduce su propio vehículo |
| **Pequeño flotista** | Propietario de 2 a 10 vehículos con conductores contratados |
| **Flota vinculada permanente** | Vehículos vinculados a la empresa habilitada |
| **Tenedor** | Arrendatario o *leasing*. Debe acreditar su tenencia |

## 2. Registro del propietario

| Requisito | Validación |
|---|---|
| Identidad (persona natural: cédula + biometría; persona jurídica: KYB como el generador) | Proveedor KYC |
| RUT (para la retención y el documento soporte) | DIAN |
| **Cuenta bancaria propia** (o billetera) a nombre del titular | Certificación bancaria y validación de titularidad (RN-041) |
| Vehículos a su nombre o con prueba de tenencia | RUNT |
| Listas restrictivas | Consulta |
| Autorizaciones de datos (incluido el GPS durante los viajes) | Firma electrónica |

**RN-041 (antifraude crítico):** el valor a pagar **solo se transfiere a una cuenta cuyo titular coincida con el titular del manifiesto** (o con un tercero autorizado mediante un documento firmado y verificado). Los cambios de cuenta exigen biometría y un **periodo de espera de 48 horas** 🔧, con notificación a todos los canales del usuario.

## 3. Registro del conductor
Ver `01_NORMATIVA_Y_PERMISOS/05_REQUISITOS_VEHICULOS_Y_CONDUCTORES.md`. Además:
- El conductor puede estar asociado a uno o varios propietarios.
- **Inicio de sesión biométrico** al empezar cada viaje (RN-106), para evitar la suplantación del conductor.

## 4. Vinculación con la empresa habilitada

| Tipo | Uso | En la app |
|---|---|---|
| **Permanente** | Flota propia de la empresa | Contrato marco firmado una vez; extracto mensual discriminado |
| **Transitoria (por viaje)** | Camionero independiente que toma una carga | **Contrato de vinculación transitoria firmado electrónicamente al aceptar la carga** (RN-102) |

Contenido mínimo (Decreto 1017 de 2025, art. 6): derechos, obligaciones, prohibiciones, plazo, terminación, preavisos, solución de conflictos, **detalle de pagos y cobros** y prohibición de descuentos no permitidos. Ver la plantilla en `06_PLANTILLAS_Y_CHECKLISTS`.

## 5. Beneficios para el transportista (propuesta de valor)
- Carga directa sin comisionistas.
- Valor a pagar ≥ SICE-TAC, visible antes de aceptar.
- **Pago en máximo 5 días hábiles**, garantizado por el sistema.
- Anticipos formales sin "gota a gota".
- Viajes de retorno.
- Citas en puerto.
- Documentos digitales.
- Calificación que vale como historial crediticio para acceder a financiación de llantas, combustible o repuestos.
