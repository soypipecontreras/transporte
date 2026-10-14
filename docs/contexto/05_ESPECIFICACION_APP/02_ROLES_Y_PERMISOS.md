# Roles y permisos

## 1. Organizaciones (tenants)
- `GENERADOR` (empresa)
- `EMPRESA_HABILITADA`
- `PROPIETARIO` (persona natural o jurídica)
- `DESTINATARIO`
- `ALIADO` (financiero, aseguradora, GPS, puerto)
- `PLATAFORMA`

## 2. Matriz de roles (C = crear, L = leer, A = aprobar/ejecutar, — = sin acceso)

| Acción | Gen. Admin | Gen. Operador | Gen. Finanzas | Emp. Admin | Emp. Despachador | Emp. Tesorería | Emp. Cumplimiento | Propietario | Conductor | Destinatario | Plataf. Riesgo | Plataf. Soporte |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Publicar carga | A | C | — | — | C (por cliente) | — | — | — | — | — | — | — |
| Ofertar / aceptar carga | — | — | — | A | A | — | — | A | L | — | — | — |
| Asignar vehículo | A | A | — | A | A | — | — | — | — | — | — | — |
| **Expedir manifiesto (RNDC)** | — | — | — | A | **A** | — | — | — | — | — | — | — |
| Ver la ubicación del viaje | L | L | — | L | L | — | — | L | C (emite) | L (su viaje) | L | L |
| Registrar eventos de cargue y descargue | C | C | — | C | C | — | — | — | C | C | — | — |
| Firmar la entrega | — | — | — | — | — | — | — | — | — | A | — | — |
| Cumplido | — | — | — | A | A | — | — | — | — | — | — | — |
| **Pagar al propietario** | — | — | — | L | — | **A (con doble aprobación)** | — | L | — | — | — | — |
| Pagar el flete | — | — | A | L | — | L | — | — | — | — | — | — |
| Solicitar crédito / factoring | A | — | A | A | — | A | — | A (anticipos) | — | — | — | — |
| Aprobar crédito | — | — | — | — | — | — | — | — | — | — | A | — |
| Gestionar alertas SARLAFT | — | — | — | — | — | — | A | — | — | — | A | — |
| Cambiar la cuenta bancaria | A (biometría) | — | — | A (biometría) | — | — | — | A (biometría) | — | — | L | — |
| Parámetros del sistema | — | — | — | — | — | — | — | — | — | — | A (riesgo) | — |
| Ver la bitácora de auditoría | L (propia) | — | — | L (propia) | — | — | L | L (propia) | — | — | L | L |

## 3. Reglas de acceso
- **2FA obligatorio:** roles de finanzas, despacho, cumplimiento y administración.
- **Doble aprobación (maker-checker)** en los pagos manuales, los cambios de parámetros y los desbloqueos de riesgo (RN-161).
- Mínimo privilegio y revisión trimestral de accesos.
- Un usuario puede pertenecer a varias organizaciones (por ejemplo, un propietario que conduce), con un selector de contexto.
