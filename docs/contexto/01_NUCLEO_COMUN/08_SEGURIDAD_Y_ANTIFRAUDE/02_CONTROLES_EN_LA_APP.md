# Controles antifraude y de seguridad en la app

## 1. Identidad
- KYC con biometría (selfie + prueba de vida + documento) para toda persona con capacidad de acción.
- KYB de las empresas (ver `06_CREDITO_Y_RIESGO/02_FILTROS...`).
- **Huella del dispositivo** y geolocalización del inicio de sesión. Un dispositivo nuevo exige verificación reforzada.
- Doble factor (2FA) obligatorio para los roles financieros y de despacho.

## 2. Vehículo y conductor
- Consulta al RUNT en el registro y antes de cada manifiesto.
- **Inicio biométrico del viaje** por parte del conductor (RN-106).
- Foto del vehículo con la placa visible en el cargue, comparada con la foto registrada (reconocimiento de placa).
- GPS del vehículo **y** del celular: si sus posiciones difieren por más de X km → alerta.

## 3. Viaje
- Ruta autorizada y geocercas.
- Alertas de desvío, detención, pérdida de señal y apertura.
- Cadena de custodia del precinto.
- Botón de pánico.
- Central de monitoreo.

## 4. Dinero
- Pago solo a la cuenta del titular verificado (RN-041).
- Doble aprobación (*maker-checker*) para pagos manuales o fuera del flujo normal (RN-161).
- Límites diarios por usuario 🔧.
- Conciliación diaria en cuatro vías (RN-160).
- Reglas de fraude transaccional: velocidad, montos atípicos, cuentas compartidas entre usuarios distintos.

## 5. Motor de reglas de riesgo
Cada evento (registro, publicación, asignación, cambio de cuenta, pago, solicitud de crédito) pasa por un **motor de reglas** que devuelve `PERMITIR / REVISAR / BLOQUEAR` con sus razones. Las reglas son configurables por el equipo de riesgo sin desplegar código.

## 6. Registro de auditoría inmutable
Toda acción relevante queda en una bitácora **solo de escritura**: quién, qué, cuándo, desde dónde, antes y después. Es indispensable ante la Supertransporte, la DIAN, la Fiscalía y en las disputas.

## 7. Seguridad informática (mínimos)
- Cifrado en tránsito (TLS 1.2 o superior) y en reposo.
- Gestión de secretos (las credenciales del RNDC, los bancos y la DIAN nunca van en el código).
- Pruebas de penetración antes del lanzamiento y cada año.
- Principio de mínimo privilegio en los roles.
- Copias de respaldo y plan de recuperación (RPO y RTO definidos).
- Referencia: ISO/IEC 27001 y OWASP ASVS.
