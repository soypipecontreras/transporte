# Requisitos de vehículos y conductores

Todo lo de esta tabla se valida **antes de permitir que el vehículo o el conductor tome una carga** (RN-050) y se **revalida automáticamente** antes de cada manifiesto (RN-051). Los vencimientos generan alertas a los 30, 15 y 5 días (RN-052).

## 1. Vehículo (cabezote, camión rígido o volqueta)

| Documento o requisito | Fuente de validación | Bloqueante |
|---|---|---|
| Licencia de tránsito (tarjeta de propiedad), **servicio público** | RUNT | Sí |
| Placa y configuración (C2, C3, 2S2, 3S2, 3S3, etc.) y PBV | RUNT | Sí |
| **SOAT vigente** | RUNT | Sí |
| **Revisión técnico-mecánica y de emisiones vigente** (si aplica por antigüedad) | RUNT | Sí |
| Registro como vehículo de carga en el RUNT (Registro Nacional de Carga) | RUNT | Sí |
| Propietario, poseedor o tenedor identificado (contrato de leasing o arriendo si no es el dueño) | RUNT + documento | Sí |
| Sin limitaciones a la propiedad que impidan operar (embargos, prendas: informativo) y sin reporte de **hurto** | RUNT / Policía | Hurto: sí |
| GPS instalado y reportando (requisito de la plataforma) | Proveedor GPS | Sí (de la plataforma) |
| Pólizas: RC contractual y extracontractual (según la empresa) | Aseguradora | Según la política |
| Fotos actuales del vehículo (4 lados, placa, cabina) | App | Sí |
| Para mercancías peligrosas: requisitos especiales del Decreto 1079 de 2015 (sección de mercancías peligrosas) y la NTC correspondiente | Documentos | Sí, si la carga es peligrosa |

### Remolque o semirremolque
- Registro en el **RNRYS** (Registro Nacional de Remolques y Semirremolques) del RUNT, con placa propia.
- Tipo: plancha, carpada, furgón, **portacontenedor (20'/40')**, tanque, cama baja, volco, refrigerado, niñera, etc.

## 2. Conductor

| Requisito | Fuente | Bloqueante |
|---|---|---|
| Cédula (validación biométrica o de documento con selfie) | Proveedor KYC / Registraduría vía aliado | Sí |
| **Licencia de conducción vigente**, categoría **C2** (rígidos) o **C3** (articulados) según el vehículo | RUNT | Sí |
| Sin suspensión ni cancelación de la licencia | RUNT | Sí |
| Multas de tránsito pendientes (SIMIT) | SIMIT | Informativo (política) |
| **Seguridad social activa**: EPS, pensión y **ARL** (como independiente cotiza sobre el 40 % de los ingresos; o como dependiente) | Planilla PILA | Sí (⚠️ la empresa responde) |
| Antecedentes: Procuraduría, Policía, medidas correctivas, listas restrictivas | Consultas | Coincidencia en listas restrictivas: sí |
| Exámenes o pruebas periódicas (alcohol y drogas, psicosensométrico) exigidos en la estructura del área de personal de la empresa (Decreto 1017 de 2025, art. 4) | Proveedor médico | Según la política de la empresa |
| Capacitación PESV y manejo defensivo | Empresa | Según el PESV |
| Para mercancías peligrosas: curso básico obligatorio | Certificado | Sí, si aplica |

## 3. Tiempos de conducción y fatiga

⚠️ No se confirmó una norma específica de tiempos máximos de conducción para carga en Colombia. Mientras se verifica, la app implementa **umbrales configurables** 🔧 dentro del PESV:
- Alerta a las **4 h** de conducción continua (referencia: Convenio 153 de la OIT).
- Alerta de jornada diaria según la política de la empresa (sugerido: 9 a 10 h).
- Registro de pausas a partir de los datos del GPS.

## 4. Pesos y dimensiones

- Resolución **4100 de 2004** del Ministerio de Transporte y sus modificaciones (Res. 1782 de 2009, entre otras). ⚠️ Verificar el texto consolidado.
- La app guarda una **tabla de configuración → PBV máximo** 🔧 y **compara con el peso declarado** de la carga (RN-055).
- Con el Decreto 1017 de 2025, la empresa debe **detener la operación** si conoce un sobrepeso sin permiso.
- **Carga extradimensionada o extrapesada** (transformadores, maquinaria, piezas de proyecto): requiere **permiso especial** del INVÍAS o de la autoridad de la vía, escoltas y horarios. La app lo trata como un flujo especial con documento obligatorio (RN-056).
