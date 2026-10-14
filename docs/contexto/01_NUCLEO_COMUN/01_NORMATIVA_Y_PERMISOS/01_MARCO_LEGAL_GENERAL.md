# Marco legal general del transporte terrestre de carga en Colombia

## 1. Jerarquía normativa

| Nivel | Norma | Qué regula | Impacto en la app |
|---|---|---|---|
| Ley | **Ley 105 de 1993** | Principios del transporte y distribución de competencias | Contexto |
| Ley | **Ley 336 de 1996** (Estatuto Nacional de Transporte) | El servicio público requiere habilitación; régimen sancionatorio | Define quién puede operar y qué pasa si se opera sin habilitación |
| Ley | **Ley 769 de 2002** (Código Nacional de Tránsito) | Licencias, documentos del vehículo, infracciones | Validación de conductor y vehículo |
| Ley | **Código de Comercio**, arts. 981 a 1035 | Contrato de transporte, responsabilidad del transportador y del remitente, arts. 1008 y 1009 sobre el destinatario | Términos y condiciones, responsabilidad por la carga |
| Decreto | **Decreto 1079 de 2015**, Libro 2, Parte 2, Título 1, Cap. 7 | Reglamento del servicio público de carga | Núcleo de las reglas de negocio |
| Decreto | **Decreto 1017 de 2025** (21 de septiembre de 2025) | Modifica el Cap. 7: habilitación, manifiesto, SICE-TAC, pagos, horas logísticas, FOPAT | **El más importante para la app** (ver `02_DECRETO_1017_DE_2025.md`) |
| Resoluciones | RNDC, SICE-TAC, pesos y dimensiones, PESV | Reglamentación técnica | Integraciones y validaciones |
| Ley | **Ley 2024 de 2020** | Pago en plazos justos | Límite a los plazos de crédito |
| Ley | **Ley 1581 de 2012** y **Ley 1266 de 2008** | Datos personales y datos financieros | Consentimientos y scoring |
| Ley | **Ley 527 de 1999** y **Decreto 2364 de 2012** | Mensajes de datos y firma electrónica | Firma de contratos y cumplidos en la app |
| Decreto | **Decreto 1165 de 2019** (modificado por el **Decreto 360 de 2021**) | Régimen aduanero | Carga de puerto y DTA |
| Supranacional | **Decisión 837 CAN** (2019) | Transporte internacional por carretera | Carpeta 04 |

## 2. Autoridades y su rol frente a la app

| Autoridad | Rol | Interacción de la app |
|---|---|---|
| **Ministerio de Transporte** | Habilita empresas, administra el RNDC y el SICE-TAC y reglamenta | Integración con el RNDC y consulta al SICE-TAC |
| **Superintendencia de Transporte** | Vigila a empresas y puertos; sanciona; supervisa el SARLAFT y el PESV de las empresas de transporte | Reportes, atención de requerimientos, evidencia de cumplimiento |
| **RUNT** | Registro de vehículos, licencias, SOAT y RTM | Validación de vehículos y conductores |
| **DIAN** | Facturación electrónica, RADIAN, aduanas, RUT | Facturación, factoring, DTA |
| **Policía de Tránsito (DITRA) y POLFA** | Control en vía y antinarcóticos en puertos | Documentos digitales disponibles en la app del conductor |
| **Superintendencia Financiera** | Vigila a las entidades financieras | Solo los aliados financieros. La plataforma no debe captar. |
| **SIC** | Datos personales, competencia, protección al consumidor | Habeas data; prácticas comerciales |
| **Supersociedades** | Sociedades comerciales, insolvencia, SAGRILAFT | Consulta de insolvencias de los clientes de crédito |
| **UIAF** | Reportes de operaciones sospechosas | El oficial de cumplimiento reporta |
| **INVÍAS / ANI / concesionarios** | Vías, peajes, permisos de carga extradimensionada | Rutas, peajes, permisos |

## 3. Principio rector para el diseño

> **La responsabilidad legal del transporte recae en la empresa habilitada.** La app debe garantizar que cada acción quede atribuida a un usuario identificado de la empresa, con su trazabilidad, para que esa responsabilidad sea demostrable ante la Supertransporte.
