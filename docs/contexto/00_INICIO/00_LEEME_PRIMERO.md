# TRANSPORTE: base de conocimiento para una plataforma digital de carga terrestre en Colombia

**Versión:** 1.1 (14 de octubre de 2026: foco en el Modelo A)  ·  **Fecha de corte normativo:** 13 de octubre de 2026
**Propósito:** documentar todo lo que una app necesita para conectar **generadores de carga**, **transportistas** (propietarios y conductores) y **destinatarios** sin intermediarios informales, cumpliendo la ley colombiana. Incluye operación portuaria, crédito y finanzas, antifraude y transporte internacional.

---

## 1. Lo primero que hay que entender (la regla de oro)

En Colombia **solo una empresa de transporte habilitada** por el Ministerio de Transporte puede prestar el servicio público de transporte terrestre automotor de carga y **expedir el manifiesto electrónico de carga** en el RNDC. Lo dicen el Decreto 1079 de 2015, art. 2.2.1.7.3, y el Decreto 1017 de 2025.

Por eso **la app no puede reemplazar a la empresa habilitada. Lo que hace es volverla transparente y digital.** Los intermediarios que sí puede eliminar son:

| Intermediario o práctica que se elimina | Cómo lo elimina la app |
|---|---|
| Comisionistas y "despachadores" informales que se quedan con parte del flete | El generador publica la carga y el transportista la toma directamente. La empresa habilitada solo formaliza el viaje. |
| Empresas "de papel" que **venden manifiestos** sin operar | Trazabilidad total: el manifiesto se expide desde la app, con GPS, cumplido y pago registrados. |
| Pagos por debajo del SICE-TAC y descuentos ilegales | La app bloquea cualquier valor a pagar inferior al SICE-TAC y muestra al camionero el flete y el valor a pagar. |
| Pagos tardíos al camionero (60 a 90 días informales) | Pago automático al titular en máximo 5 días hábiles después del cumplido, como exige el Decreto 1017 de 2025. |
| "Jaladores" y cobros irregulares en puertos | Citas, enturnamiento y documentos digitales. |
| Créditos informales ("gota a gota") a transportistas | Créditos y anticipos formales con aliados financieros vigilados. |

## 2. Cómo está organizada esta carpeta

```
TRANSPORTE/
├── 00_INICIO ........................ este archivo, glosario, mapa de actores, advertencias
├── 01_NUCLEO_COMUN .................. lo que aplica a CUALQUIER modelo de negocio
│   ├── 01_NORMATIVA_Y_PERMISOS ...... leyes, decretos, RNDC, SICE-TAC, vehículos, conductores
│   ├── 02_CARGA_PESADA_Y_PUERTOS .... puertos, contenedores, aduana, citas, vacíos
│   ├── 03_LOGISTICA_Y_OPERACION ..... ciclo del viaje, asignación, rastreo, cumplido
│   ├── 04_ACTORES_Y_VINCULACION ..... requisitos y documentos por actor
│   ├── 05_FINANZAS .................. flujo del dinero, pagos, facturación, impuestos
│   ├── 06_CREDITO_Y_RIESGO .......... crédito a 30/60 días, filtros, scoring, factoring
│   ├── 07_SEGUROS
│   ├── 08_SEGURIDAD_Y_ANTIFRAUDE .... fraudes típicos, controles, SARLAFT
│   ├── 09_PROTECCION_DE_DATOS ....... habeas data
│   └── 10_LEGAL_GENERAL ............. contratos, firma electrónica, consumidor, competencia
├── 02_MODELO_A_VENTA_DE_LA_APP ...... ⭐ ÚNICO FOCO: la app como software (SaaS) que se licencia a transportadoras habilitadas
│   ├── 00_PLAN_MAESTRO_MODELO_A.md .. empezar aquí
│   ├── 01_MODELO · 02_LEGAL (contrato de licencia SaaS .docx) · 03_FINANZAS (calculadora de retorno .xlsx)
│   └── 04_COMERCIAL (proceso de venta y prospectos) · 05_PRODUCTO (oferta, MVP, implementación, soporte)
├── 05_ESPECIFICACION_APP ............ roles, módulos, reglas de negocio, datos, integraciones, MVP
├── 06_PLANTILLAS_Y_CHECKLISTS ....... listas de chequeo y esqueletos de contratos
├── 07_FUENTES ....................... cada norma con enlace, fecha de verificación y documentos oficiales (PDF)
├── 08_CLIENTES ...................... kit por cliente (01_HUMADEA: perfil, guía de reunión, piloto, confidencialidad)
├── 09_DOCUMENTOS_PARA_ABOGADO_Y_CONTADOR ... memo de consulta y borrador del acuerdo de fundadores
├── 10_ALIADOS_Y_FINANZAS ............ lista corta de aliados y modelo financiero en Excel
├── 90_FUTURO ........................ en segundo plano: Modelo B (socios de una transportadora) y transporte internacional
└── GUIA_DE_PENDIENTES_v2.xlsx ....... lo que falta conseguir por fuera (seguimiento vigente; el .md queda como referencia)
```

**Orden de lectura sugerido**

- **Para el socio o inversionista:** 00 → 02_MODELO_A (empezar por el plan maestro) → 01/05 → 01/06.
- **Para el desarrollador:** 00 → 05_ESPECIFICACION_APP (completa) → consultar 01 cuando una regla lo remita.
- **Para el abogado o contador que valida:** 00/03_ADVERTENCIAS → 01/01 → 01/10 → 02_MODELO_A/02_LEGAL (incluye el contrato de licencia) → 07_FUENTES.

## 3. Convenciones usadas en todos los documentos

- **RN-xxx** = Regla de Negocio, que la app debe programar. El catálogo completo está en `05_ESPECIFICACION_APP/04_REGLAS_DE_NEGOCIO.md`.
- ✅ **Verificado** = confirmado en fuente oficial en la fecha de corte.
- ⚠️ **VERIFICAR** = dato que cambia con frecuencia o que no se pudo confirmar en fuente oficial. Un abogado o contador debe validarlo antes de programarlo como regla dura.
- 🔧 **Parametrizable** = valor que la app NO debe dejar fijo en el código (tarifas, porcentajes, SMMLV, umbrales, plazos), porque la norma cambia.
- Las cifras en **SMMLV** o **UVB** se calculan con el valor del año vigente. La app debe tener una tabla de parámetros por año.

## 4. Cómo usar esta documentación con Claude (para el desarrollador)

1. Cargar como contexto, como mínimo, `00_INICIO/*`, `05_ESPECIFICACION_APP/*` y el documento del modelo de negocio elegido.
2. Usar el prompt base de `05_ESPECIFICACION_APP/11_PROMPT_BASE_PARA_CLAUDE.md`.
3. Cuando Claude programe una funcionalidad, pedirle que cite la regla RN-xxx que implementa.
4. Si una norma cambia, actualizar primero el documento de `01_NUCLEO_COMUN` y la tabla de parámetros. El código lee los parámetros y no necesita cambiar.

## 5. Advertencia legal

Esta documentación es una **base técnica de trabajo y no reemplaza la asesoría profesional**. Antes de operar, un abogado especialista en transporte, un contador o revisor fiscal y, para la parte de crédito, un asesor financiero deben revisar lo marcado con ⚠️ y los contratos. La regulación del transporte de carga en Colombia cambia seguido: el Decreto 1017 de 2025 se reglamenta con resoluciones posteriores y hay demandas y proyectos en curso. Ver `03_ADVERTENCIAS_Y_PENDIENTES.md`.
