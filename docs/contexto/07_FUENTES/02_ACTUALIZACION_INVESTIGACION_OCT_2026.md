# Actualización de la investigación (13 de octubre de 2026)

Respuesta a los pendientes 3.x y 6.x de `GUIA_DE_PENDIENTES.md`. Cada hallazgo indica su fuente y si **corrige** algo que estaba en la versión 1.0 de la carpeta.

Leyenda: ✅ confirmado en fuente oficial · 🟡 fuente secundaria (prensa, blog, firma de abogados) · ❌ no se encontró / sigue pendiente · 🔁 corrige la versión 1.0

---

## 1. Retención del 0,1 % para el FOPAT: YA ESTÁ VIGENTE ✅ 🔁

| Punto | Dato |
|---|---|
| Base legal | **Ley 2251 de 2022, art. 21** + Decreto 1079 de 2015, art. 2.2.1.7.7.16 (adicionado por el art. 24 del Decreto 1017 de 2025) |
| Reglamentación | **Resolución DIAN 000008 del 25 de marzo de 2026** (Diario Oficial 53.440); agrega los arts. 1.8.2.5.1 a 1.8.2.5.11 a la Res. DIAN 000227 de 2025 |
| Vigencia | **Desde el 1 de abril de 2026** |
| A qué aplica | Servicio público de carga **intermunicipal o nacional** en vehículos con **PBV > 10,5 t** |
| Agente retenedor | La **empresa de transporte habilitada** |
| Base | Según los considerandos de la DIAN, el **valor a pagar** del manifiesto. Hay un **concepto DIAN 1057 de 2026** sobre flota propia con valor a pagar en cero (en ese caso se retiene sobre el flete). ⚠️ Confirmar con el contador |
| Cuándo se causa | Cuando se **acepta el cumplido** del manifiesto en el RNDC |
| Pago | Dentro de los **10 primeros días hábiles del mes siguiente**, con el **Formulario 490, concepto 81**. La mora genera intereses (Estatuto Tributario, art. 635) |
| Soporte | Se registra en el RNDC (cumplido o facturas). El Ministerio publicó una **guía de registro del 31 de marzo de 2026** |

**Corrección:** la versión 1.0 decía "retención sobre el flete, demandada, dejar desactivada". Ahora el parámetro `fopat.activo` debe quedar en **verdadero** desde el 1 de abril de 2026, con la base en el **valor a pagar** (sujeto a la confirmación del contador).

Fuentes: [Res. DIAN 0008 de 2026](https://normograma.dian.gov.co/dian/compilacion/docs/resolucion_dian_0008_2026.htm) · [Guía FOPAT de Mintransporte](https://plc.mintransporte.gov.co/LinkClick.aspx?fileticket=eAQjoQEKdwM%3D&tabid=90&portalid=0&mid=485) · [INCP sobre empresas del SIMPLE](https://incp.org.co/publicaciones/infoincp-publicaciones/impuestos/2026/08/dian-empresas-del-simple-deben-practicar-retencion-del-01-en-transporte/)

## 2. Demanda contra el Decreto 1017 🟡 🔁
- Fenalco demandó **solo los artículos 17 y 18** (registro inicial de vehículos y aporte al FOPAT por reposición, que pasa del **15 % al 25 %** del valor comercial y se amplía a vehículos desde 3,5 t). **No** demandó el pago a 5 días, el SICE-TAC ni la retención del 0,1 %.
- ❌ No se encontró ninguna decisión del Consejo de Estado sobre la suspensión a octubre de 2026.
- **Corrección:** la retención del 0,1 % **no** está demandada. Las reglas de pago y del SICE-TAC siguen firmes.

Fuentes: [La República](https://www.larepublica.co/economia/fenalco-pidio-suspension-del-decreto-1017-por-impacto-en-los-transportadores-4288689) · [Fenalco](https://www.fenalco.com.co/blog/noticias-10/fenalco-demanda-y-pide-suspension-del-decreto-1017-ante-el-consejo-de-estado-por-su-grave-impacto-en-los-transportadores-8583)

## 3. Nueva resolución única del RNDC ✅ 🔁 (la más importante para el desarrollo)

**Resolución 20263040016075 del 29 de abril de 2026** del Ministerio de Transporte. Unifica toda la normativa del RNDC e incluye el **Anexo 1: Manual de operación del RNDC** (73 páginas). **Copia guardada en** `07_FUENTES/DOCUMENTOS_OFICIALES/`.

| Tema | Lo que dice | Impacto en la app |
|---|---|---|
| Canales de acceso (art. 6 y manual 4.1) | **Interoperabilidad (web service u otra tecnología)**, plataforma web del Ministerio, **apps móviles del Ministerio** y transmisión de **archivo plano** | El adaptador RNDC se integra por web service. El archivo plano sirve como contingencia |
| Obligados (art. 4) | Empresas habilitadas, **generadores**, titulares de manifiesto y quienes hacen contratación directa | El generador también tiene usuario y obligaciones propias |
| **Rol "Empresa de Monitoreo de Flota"** (manual 4.2.1) | Tercero opcional que reporta al RNDC la ubicación y los **tiempos reales** de los eventos del manifiesto, con autorización de la empresa | 💡 **Oportunidad:** la plataforma puede registrarse en este rol y reportar los tiempos logísticos por sus clientes. Una empresa con un certificado de herramientas tecnológicas propias puede reportar directamente |
| Tiempos reales de cargue y descargue | **Obligatorios mediante sistemas de monitoreo de flota desde el 30 de noviembre de 2025** (art. 18.4) | RN-030 ya no es opcional: es una obligación legal |
| Piso del SICE-TAC (art. 9) | Solo se expiden manifiestos con un valor a pagar ≥ el SICE-TAC | Confirma RN-010 |
| **Control del 20 %** (art. 9) | Si los cumplidos pendientes superan el **20 % de los manifiestos de los últimos 30 días**, el RNDC **bloquea nuevos manifiestos** | 🆕 Nueva regla RN-021: alerta temprana de cumplidos pendientes |
| Otros controles del 20 % (manual) | También se controlan las remesas sin dato del flete y las facturas sin aceptar después de 5 días hábiles | 🆕 RN-022 |
| Tipos de manifiesto (art. 10) | Varios viajes en un día · multiparadas · **ida y regreso** · municipal · general | El modelo de datos debe soportar los 5 tipos |
| Porte (art. 11) | Físico o **digital**, con un **código de seguridad cifrado (QR)** en el PDF del formato estándar | Confirma RN-013 |
| Fecha del valor a pagar | No puede superar **5 días hábiles** contados desde el día siguiente al cumplido | Confirma RN-012/RN-040 |
| **Generador** | Debe registrar el **dato del flete** y **aceptar la factura electrónica en el RNDC** dentro de los **5 días hábiles** siguientes al plazo pactado o a la entrega. Después de ese plazo, el RNDC acepta automáticamente el valor del flete si cumple la norma | 🆕 RN-023: recordatorio y asistencia al generador |
| Titular | Puede aceptar el manifiesto y **aceptar o rechazar el cumplido** (incluso desde la app móvil "Transportador" del Ministerio) | La app del transportista debe mostrar y facilitar esa aceptación |
| Formatos estándar (art. 19) | Obligatorios a los **2 meses de la publicación** (≈ julio de 2026) | Generar el PDF con el formato oficial |
| Puertos (manual) | Los puertos autorizados son **obligados** en el RNDC con su **sistema de enturnamiento portuario** (Res. 20213040005875 de 2021, módulo INSIDE) | 🔁 Sí existe un marco nacional de enturnamiento ligado al RNDC |
| Deroga | Res. 377 de 2013, 20223040045515 y 20223040077365 de 2022, 20233040035795 de 2023, 20243040006835 y 20243040058015 de 2024, 20253040048905 de 2025 | — |

**"RNDC 360" desde el 1 de enero de 2027 (precisión posterior):**
- La **ministra de Transporte lo anunció en el 51 Congreso de Colfecar (2 de octubre de 2026)**: será un nuevo sistema de despachos que gestionará desde el celular el inicio y cierre de viajes, las autorizaciones y la facturación, con asistente de IA y operación 24/7. Fuentes: Caracol Radio vía [Head Topics](https://co.headtopics.com/news/mintransporte-cambiar-plataforma-de-despachos-de-carga-88400303) y [V12 Magazine](https://v12magazine.com/actualidad/colombia/colfecar-2026-transporte-carga/).
- **Todavía no hay una resolución** que lo regule. Por eso se mantiene el adaptador RNDC intercambiable.
- Según Colfecar, las fallas del RNDC causaron **36 días perdidos entre enero y septiembre de 2026**. Es un argumento para que la app tenga un modo de contingencia (el archivo plano previsto en la resolución).
- **Datos del congreso útiles para la presentación comercial:**
  - El corredor Buga–Loboguerrero–Buenaventura mueve **≈ 42 % del comercio internacional**.
  - Edad promedio del parque de carga: **≈ 21 años**.
  - Hubo 2.841 bloqueos viales entre 2023 y agosto de 2026.

Fuentes: [Texto de la resolución (Mintransporte)](https://mintransporte.gov.co/info/mintransporte/media/anexos/dx2Es4bu.pdf) · [Comunicado del Ministerio](https://mintransporte.gov.co/publicaciones/12295/el-ministerio-de-transporte-fortalece-la-logistica-del-pais-y-actualiza-las-reglas-del-registro-nacional-de-despachos-de-carga/)

## 4. Otras resoluciones que reglamentan el Decreto 1017
- 🟡 **Res. 20263040015655 del 27 de abril de 2026:** registro inicial de vehículos nuevos de carga de 3,5 a 10,5 t y volquetas, y cambio de servicio particular a público. (Fuente comercial: [Chevrolet Buses y Camiones](https://www.busesycamioneschevrolet.com.co/blog/decreto-1017-reforma-al-transporte-de-carga/).) ⚠️ Verificar en el Diario Oficial.
- ✅ **Res. 20263040016075 de 2026** (RNDC): ver el punto 3.

## 5. Puertos y Buenaventura (situación actual) ✅/🟡 🔁
- **Res. 20263040028845 de 2026** (Mintransporte): condiciones mínimas obligatorias de operación para **patios de contenedores y zonas de enturnamiento** en todo el país, incluida la atención 24/7. Los operadores deben adoptar un **reglamento de operación**. ⚠️ Confirmar el número y la fecha en el Diario Oficial (el comunicado del Ministerio es de marzo de 2026 y Analdex cita esta resolución como de julio de 2026).
- **Res. 312 de 2025** y **Circular conjunta MinTransporte–Supertransporte del 6 de febrero de 2026:** plan semanal de recepción y evacuación de vacíos en Buenaventura. Se ordenó a las navieras recoger los vacíos represados y frenar los cobros de mora.
- **Situación (septiembre de 2026, Analdex):** tras el **terremoto del 10 de agosto de 2026** hay:
  - **Cierre nocturno del corredor Buga–Buenaventura (de 8 p. m. a 6 a. m.)**.
  - Paso a un carril en Cajamarca.
  - Patios congestionados con pocas citas.
  - Más días de permanencia de los contenedores.
  - Sobrecostos por almacenamiento, mora y *stand-by*.
  - Analdex pide **reutilizar los vacíos de importación para exportación**, crear un doble ciclo de citas y abrir una línea de crédito de Bancóldex.
- 💡 **Para la reunión con Humadea:** estos son exactamente los problemas que resuelven el módulo de puerto (RN-064 reutilización, RN-071 enturnamiento virtual, RN-074/075 vacíos) y la evidencia del *stand-by*. Además, la restricción nocturna exige **programar ventanas de viaje** en la app.

Fuentes: [Analdex](https://analdex.org/2026/09/02/carta-abierta-situacion-logistica-buenaventura/) · [Supertransporte](https://www.supertransporte.gov.co/index.php/comunicaciones-2026/mintransporte-y-supertransporte-ordenan-a-navieras-recoger-contenedores-represados-en-buenaventura-y-frenar-cobros-de-mora/) · [Mintransporte](https://mintransporte.gov.co/publicaciones/12261/mintransporte-y-supertransporte-adoptan-medidas-para-enfrentar-crisis-de-contenedores-vacios-y-mejorar-el-enturnamiento-en-buenaventura/)

## 6. SARLAFT de la Supertransporte (3.10) ✅/🟡
- **Res. 4607 del 9 de abril de 2026** (modifica la Res. **2328 de 2025**, que creó el SARLAFT del sector, y la 16615 de 2025). Texto guardado en `DOCUMENTOS_OFICIALES` (es un PDF escaneado).
- **SARLAFT pleno:** ingresos ≥ **142.206,50 UVB**. **Régimen de Medidas Simplificadas:** por debajo de ese umbral. Con la UVB de 2026 ($12.110), el umbral equivale a **≈ $1.722 millones** de ingresos anuales (cálculo propio; ⚠️ confirmar el año base que usa la norma).
- El responsable de cumplimiento se registra en el **módulo SARLAFT de VIGÍA 2** de la Supertransporte.
- Existe la **Res. 9596 de 2026** sobre un "Aliado Tecnológico SARLAFT" de la Supertransporte. 💡 Revisar si abre la puerta a que proveedores tecnológicos (como la plataforma) apoyen a las empresas.
- ❌ Pendiente: leer el texto completo para confirmar la lista de sujetos obligados por tipo de empresa de carga (es un escaneo; se necesita OCR o una lectura directa).

Fuentes: [Pérez-Llorca](https://www.perezllorca.com/es-co/actualidad/boletin/nuevas-reglas-para-el-sarlaft-de-la-superintendencia-de-transporte/) · [Deloitte](https://www.deloitte.com/latam/es/services/legal/perspectives/co-24abril2026-boletin-legal-corporativo.html) · [Supertransporte, Res. 4607](https://www.supertransporte.gov.co/documentos/2026/Abril/Planeaci%C3%B3n_10/4607.pdf) · [Res. 9596 de 2026](https://www.supertransporte.gov.co/documentos/2026/Julio/Despacho_30/1.Resolucion_9596_de_2026_Aliado_Tecnologico_SARLAFT.pdf)

## 7. Plazos de pago de la Ley 2024 y "gran empresa" (3.6) ✅
- Ley 2024 de 2020: máximo de **45 días calendario**, excepto entre grandes empresas.
- **Tamaño de empresa:** Decreto 957 de 2019, por **ingresos ordinarios anuales** según el sector. El transporte entra en el sector **servicios** (sección H del CIIU), según una tabla de la Supertransporte:
  - Micro: ≤ 32.988 UVT.
  - Pequeña: ≤ 131.951 UVT.
  - Mediana: ≤ 483.034 UVT.
  - **Grande: > 483.034 UVT** → con la UVT de 2026 ($52.374), **≈ $25.298 millones** de ingresos anuales (cálculo propio; ⚠️ el decreto puede usar la UVT del año de los estados financieros).
- **Aplicación:** RN-201 clasifica a cada generador y empresa con esta tabla 🔧.

Fuentes: [Decreto 957 de 2019 – Función Pública](https://www1.funcionpublica.gov.co/eva/gestornormativo/norma.php?i=94550) · [Supertransporte – segmentación](https://www.supertransporte.gov.co/documentos/2026/Abril/Planeaci%C3%B3n_21/PPT_Metodologia_de_Segmentacion_Sarlaft_ST.pdf)

## 8. Tiempos de conducción (3.9) 🟡 ❌
- **No hay una fuente oficial confirmada** con límites específicos para conductores de carga.
- Una fuente comercial atribuye la regla a la **Resolución 315 de 2013** (5 h de conducción continua, 30 min de descanso, jornada de 10 h). ⚠️ Sin verificar.
- ✅ **Circular conjunta Mintransporte–Mintrabajo 20261300000087 (marzo de 2026):** recuerda que las empresas de transporte, **incluida la carga por carretera**, deben respetar los límites de la jornada y los descansos del **Código Sustantivo del Trabajo**.
- **Decisión para la app:** mantener umbrales configurables (4 a 5 h continuas, 10 h al día) como **política del PESV**, no como norma.

Fuentes: [Logitools (no oficial)](https://logitools.co/guias/tiempo-descanso-conductor-colombia) · [El Transporte – circular](https://eltransporte.com/conductores-garantias-laborales-ministerios-colombia/)

## 9. Internacional (3.12) ✅ 🔁
- **Venezuela:** el **Acuerdo bilateral Colombia–Venezuela de transporte internacional de carga y pasajeros por carretera** está **vigente desde el 22 de agosto de 2025**. Lineamientos en la **Circular 20254000000547 de 2025** (Mintransporte). Requisitos y plazos:
  - **Documento de Idoneidad** ante el Grupo de Transporte Internacional y Multimodal del Ministerio. Se presenta con la habilitación nacional, la relación de vehículos, los contratos de vinculación o leasing, una **póliza de RC internacional por vehículo** y la estructura organizacional.
  - Luego, el **permiso complementario en Venezuela (INTT)** dentro de 60 días.
  - **Habilitación de vehículos** ante la Dirección Territorial.
  - Las autorizaciones transitorias (Circular 347 de 2025) vencieron el **27 de julio de 2026**.
  - En mayo de 2026 se instaló una mesa binacional en Cúcuta (comisión permanente y zona transfronteriza).
- **CAN (Ecuador, Perú, Bolivia):** 🟡 hay un **proyecto de resolución del Ministerio (PR-MT 0084-AJ-2025, diciembre de 2025)** para reglamentar en Colombia el **permiso originario**, el **certificado de habilitación de vehículos** y el **permiso especial de origen** de la Decisión 837. ❌ No se confirmó si ya se expidió.
- **Humadea** opera con Ecuador y Venezuela, así que ya debe tener estos permisos. Es una buena pregunta para la reunión.

Fuentes: [Circular 0547 de 2025 – Cancillería](https://cancilleria.gov.co/normograma/compilacion/docs/circular_mintransporte_0547_2025.htm) · [Proyecto PR-MT 0084 de 2025](https://www.redjurista.com/Compilaciones2018/tablas_ProyectosNormas/2025/12/18/pr_mt_0084aj_2025.pdf) · [Cancillería – mesa de transporte](https://cancilleria.gov.co/sala-de-prensa/noticias/colombia-y-venezuela-avanzan-en-acuerdos-para-fortalecer-el-transporte-transfronterizo-en-la-frontera-colombo-venezolana)

## 10. Valores de 2026 (6.5) ✅/🟡
| Parámetro | Valor | Fuente |
|---|---|---|
| SMMLV 2026 | **$1.750.905** (Decreto 1469 de 2025; +23 %). Hubo una suspensión y un decreto transitorio, pero el Consejo de Estado levantó la medida y **el Decreto 1469 sigue vigente** | 🟡 [Portafolio](https://www.portafolio.co/economia/gobierno/consejo-de-estado-reactiva-el-aumento-del-23-del-salario-minimo-de-2026-esto-determino-498416) |
| SMLDV 2026 | $58.363,50 | Cálculo |
| Auxilio de transporte 2026 | $249.095 (Decreto 1470 de 2025) | 🟡 |
| UVT 2026 | **$52.374** (Res. DIAN 000238 de 2025) | 🟡 [Siempre al Día](https://siemprealdia.co/colombia/impuestos/uvt-2026/) |
| UVB 2026 | **$12.110** (Res. MinHacienda 3488 de 2025) | 🟡 [Buk](https://www.buk.co/blog/uvb-colombia-valor-2026) |
| Interés bancario corriente, octubre de 2026 | 19,06 % E.A. (Res. SFC 1472 de 2026) | ✅ [Superfinanciera](https://www.superfinanciera.gov.co/publicaciones/10116267/superfinanciera-certifica-el-interes-bancario-corriente/) |
| **Tasa de usura, octubre de 2026** | **28,59 % E.A.** | ✅ [Portafolio](https://www.portafolio.co/economia/finanzas/tasa-de-usura-baja-en-octubre-y-establece-nuevo-limite-para-el-cobro-de-intereses-a-los-bancos-503770) |

**Cálculos útiles con los valores de 2026:**
- Capital para habilitar una empresa: 1.000 SMMLV = **$1.750.905.000**. Empresa de propietarios: 250 SMMLV = **$437.726.250**.
- Horas logísticas adicionales: articulado 3 SMLDV ≈ **$175.091 por hora**; rígido 2 SMLDV ≈ **$116.727 por hora**.

## 11. Lo que sigue pendiente (no se pudo resolver investigando)
| # | Punto | Por qué |
|---|---|---|
| 3.1, 3.4, 3.5, 3.7, 3.8 | Interpretación legal y tributaria de fondo | Requiere el criterio de un abogado o contador (próximo paso: memo) |
| 3.11 | Pesos y dimensiones consolidados | No hay un texto consolidado oficial en línea; pedírselo al abogado o consultarlo directamente con el Ministerio |
| 6.3 | Consulta automática del SICE-TAC | No se encontró una API pública. **Alternativa confirmada:** el RNDC rechaza el manifiesto bajo el piso, y la app puede precalcular con tablas descargadas del portal del SICE-TAC |
| 6.4 | API de citas de cada terminal | Hay que preguntarle directamente a cada terminal. Nota: los puertos ya reportan el enturnamiento al RNDC (módulo INSIDE) |
| 6.6 | Datos de mercado para las proyecciones | Se trabajará en el modelo financiero |
