# Requisitos no funcionales

| Categoría | Requisito |
|---|---|
| Disponibilidad | 99,5 % mensual en el núcleo (despacho, pagos, rastreo). Operación sin conexión en la app del conductor con sincronización posterior |
| Rendimiento | Búsqueda de cargas < 2 s; ingesta de GPS de miles de vehículos a 1 evento por minuto o más; manifiesto en el RNDC con reintentos y cola |
| Escalabilidad | Arquitectura modular (servicios por dominio: identidad, viajes, pagos, crédito, cumplimiento); colas de mensajes |
| Seguridad | TLS, cifrado en reposo, gestión de secretos, 2FA, OWASP ASVS nivel 2, pruebas de penetración, registro de auditoría inmutable |
| Privacidad | Ley 1581: consentimiento por finalidad, minimización, retención definida, derechos ARCO desde la app |
| Trazabilidad | Cada cambio de estado con actor, hora, ubicación y evidencia; sello de tiempo en los documentos |
| Conservación | Documentos contables y de transporte ≥ 10 años ⚠️ |
| Localización | Español de Colombia; preparado para multipaís y multimoneda |
| Accesibilidad | Botones grandes, alto contraste, lectura por voz para conductores; funciona en Android de gama baja |
| Conectividad | Tolerante a 2G/3G; compresión de fotos; carga diferida |
| Observabilidad | Logs centralizados, métricas, alertas técnicas, trazas |
| Recuperación | Respaldo diario; RPO ≤ 1 h; RTO ≤ 4 h (núcleo) |
| Ubicación de los datos | Nube con región aprobada; contratos de transmisión si es fuera de Colombia |
| Calidad | Pruebas automatizadas, en especial de **todas las RN bloqueantes** (cada RN-xxx tiene su prueba) |
