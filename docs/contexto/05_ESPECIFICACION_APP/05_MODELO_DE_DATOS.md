# Modelo de datos (entidades principales)

Notación: `entidad (campos clave)`. Todas las entidades tienen `id (UUID)`, `creado_en`, `actualizado_en`, `creado_por` y `version`. Las entidades críticas tienen historial (*soft delete* + bitácora).

## Identidad y organizaciones
- **organizacion** (tipo [GENERADOR|EMPRESA_HABILITADA|PROPIETARIO|DESTINATARIO|ALIADO|PLATAFORMA], nit/documento, razon_social, tamano_empresa [MICRO|PEQUENA|MEDIANA|GRANDE], estado_kyb, nivel_cuenta, pais)
- **usuario** (persona_id, email, telefono, 2fa, estado)
- **persona** (tipo_doc, numero_doc, nombres, fecha_nac, biometria_ref, estado_kyc, pep)
- **membresia** (usuario_id, organizacion_id, rol)
- **documento** (propietario_tipo, propietario_id, tipo, numero, emisor, fecha_emision, fecha_vencimiento, archivo_ref, estado_validacion, fuente_validacion)
- **cuenta_bancaria** (organizacion_id, banco, tipo, numero_cifrado, titular_doc, verificada, estado, fecha_cambio)
- **consulta_listas** (sujeto, fecha, proveedor, resultado, coincidencias)
- **consentimiento** (persona/organizacion, finalidad, version_texto, fecha, evidencia, revocado)

## Empresa habilitada
- **habilitacion** (organizacion_id, resolucion, fecha, modalidad, estado, tipo [GENERAL|PROPIETARIOS], capital_acreditado)
- **credencial_integracion** (organizacion_id, sistema [RNDC|DIAN|BANCO], ref_secreto [cofre], estado)
- **permiso_internacional** (organizacion_id, numero, paises[], vigencia)

## Flota
- **vehiculo** (placa, configuracion, pbv, carroceria, servicio, propietario_id, tenedor_id, gps_proveedor, gps_id, estado)
- **remolque** (placa, tipo, capacidad)
- **conductor** (persona_id, licencia_categoria, licencia_vence, certificaciones[], score)
- **vinculacion** (empresa_id, vehiculo_id, propietario_id, tipo [PERMANENTE|TRANSITORIA], viaje_id?, contrato_ref, vigencia)

## Carga y viaje
- **carga** (generador_id, origen, destino, ventanas, mercancia, naturaleza, un_numero?, peso, volumen, valor_declarado, configuracion_requerida, modo_asignacion, flete_ofrecido, forma_pago [CONTADO|PLAZO], plazo_dias, estado)
- **carga_puerto** (carga_id, contenedor_numero, tamano, tipo, bl_booking, naviera, terminal_id, dias_libres_hasta, patio_devolucion_id, dta [bool], cutoff)
- **oferta** (carga_id, empresa_id, vehiculo_id, valor_ofrecido, eta, estado)
- **viaje** (carga_id, empresa_id, vehiculo_id, remolque_id, conductor_id, estado, flete, valor_a_pagar, sicetac_costo, anticipo, fecha_pago_programada)
- **manifiesto** (viaje_id, numero_rndc, estado, fecha_expedicion, payload_ref, respuesta_rndc)
- **remesa** (viaje_id, numero_rndc, ...)
- **cumplido** (viaje_id, fecha, valores_finales, novedades, numero_rndc)
- **evento_viaje** (viaje_id, tipo, ts, lat, lon, actor_id, evidencia_refs[], datos_json)
- **tiempo_logistico** (viaje_id, punto [CARGUE|DESCARGUE], cita, llegada, inicio, fin, horas_exceso, valor_exceso)
- **precinto** (viaje_id, numero, tipo, eventos[])
- **novedad / disputa / siniestro** (viaje_id, tipo, descripcion, evidencia, estado, resolucion)

## Puerto
- **terminal** (nombre, tipo [PUERTO|PATIO|BODEGA], ciudad, geocerca, sistema_citas, api_disponible)
- **cita** (terminal_id, viaje_id, fecha_hora, numero, estado, cumplida)
- **eir** (viaje_id, contenedor, tipo [SALIDA|ENTRADA], fotos[], danos)

## Dinero
- **pago** (tipo [ANTICIPO|VALOR_A_PAGAR|HORAS|REEMBOLSO], beneficiario_id, cuenta_id, monto, fecha_programada, fecha_ejecutada, estado, referencia_banco, aprobado_por[])
- **descuento** (pago_id, tipo [catálogo cerrado], monto, soporte)
- **factura** (emisor_id, receptor_id, viaje_ids[], cufe, valor, vencimiento, estado_dian, estado_radian [ACUSE|RECIBO|ACEPTADA], endosada_a?)
- **recaudo** (factura_id, monto, fecha, medio, conciliado)
- **parametro** (clave, valor, vigente_desde, vigente_hasta, aprobado_por) ← SMMLV, tasas, umbrales, festivos

## Crédito
- **solicitud_credito** (organizacion_id, monto, plazo, estado, documentos[], consentimientos[])
- **evaluacion** (solicitud_id, capas_resultado_json, puntaje, decision, version_modelo, analista_id)
- **cupo** (organizacion_id, monto_aprobado, usado, plazo_max, estado, revisar_en)
- **garantia** (cupo_id, tipo, referencia, vigencia)
- **operacion_factoring** (factura_id, factor_id, tasa, desembolso, estado)
- **gestion_cobranza** (factura_id, canal, ts, resultado)

## Cumplimiento y auditoría
- **alerta_riesgo** (sujeto, regla, severidad, estado, analista, decision)
- **caso_sarlaft** (alerta_ids[], analisis, decision, ros_enviado)
- **bitacora** (ts, actor, accion, entidad, entidad_id, antes, despues, ip, dispositivo) ← solo escritura
- **calificacion** (viaje_id, de_id, a_id, puntaje, comentario)
