# Aduanas: DTA, transportador inscrito, OEA y precintos

## 1. Régimen aduanero
- **Decreto 1165 de 2019**, modificado por el **Decreto 360 de 2021**, y las resoluciones reglamentarias de la DIAN (Res. 046 de 2019 y sus modificaciones, entre ellas la Res. 0039 de 2021).

## 2. Transportador inscrito ante la DIAN
- **Solo** se exige inscripción para transportar **mercancías bajo control aduanero**: tránsito aduanero, cabotaje, transbordo terrestre, traslados a zona franca, etc. Para la mercancía ya nacionalizada **no** se exige (Oficio DIAN, art. 113 del Decreto 1165).
- Las operaciones de **tránsito aduanero** se hacen solo en vehículos de **empresas inscritas y autorizadas** por la DIAN. Excepcionalmente se permiten vehículos del declarante con garantía.
- ⚠️ Requisitos de inscripción (garantía, sistemas, etc.): revisar los arts. 113 y siguientes del Decreto 1165 de 2019 vigentes y la resolución reglamentaria.

**En la app:** el perfil de la empresa tiene la bandera `inscrita_DIAN_transportador` con número y vigencia, y el vehículo tiene `autorizado_transito`. RN-060.

## 3. DTA (Declaración de Tránsito Aduanero)
- Formulario **651**, tramitado por el servicio informático de tránsito aduanero de la DIAN.
- Lleva la mercancía extranjera **sin nacionalizar** desde la aduana de llegada (puerto) hasta otra aduana, zona franca o depósito.
- Plazos de tránsito y rutas definidos por la DIAN. La app compara el ETA con el plazo y genera alertas (RN-068).
- **Dispositivos electrónicos de seguridad:** la DIAN puede exigir características mínimas (art. 773 del Decreto 1165). La app debe poder **integrar precintos electrónicos** (eventos de apertura y ubicación).

## 4. OTM (Operador de Transporte Multimodal)
- Si la empresa quiere ofrecer puerta a puerta con un solo documento (marítimo + terrestre): registro como OTM ante el Ministerio de Transporte (Decisiones CAN 331 y 393, y la normativa nacional). ⚠️ Verificar los requisitos actuales.

## 5. OEA (Operador Económico Autorizado)
- Certificación voluntaria de la DIAN (con la Policía, el ICA y el INVIMA) para operadores seguros de la cadena: menos inspecciones y más agilidad en puerto.
- **Recomendación:** que la empresa habilitada del Modelo B apunte a la certificación OEA como transportador. Los requisitos de seguridad (vetting de conductores, control de precintos, GPS, trazabilidad) son justamente lo que la app ya hace. Es un argumento de venta fuerte.
- Estándar complementario: **BASC** (privado, muy usado en puertos).

## 6. Precintos
- Número registrado en el BL, el EIR, la DTA y la app. Se verifica en cada punto de control.
- Tipos: mecánico (de alta seguridad, ISO 17712) y electrónico.
- RN-061 y RN-066: cadena de custodia.
