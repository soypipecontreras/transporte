# Filtros antifraude para otorgar crédito a empresas (generadores)

Objetivo: que **ninguna empresa fraudulenta, de fachada o insolvente** reciba plazo. El crédito se otorga en **capas**: si una capa falla, se detiene o se pasa a revisión manual.

## Capa 1: Existencia y legitimidad (automática)

| # | Filtro | Fuente | Señal de alerta (🚩) |
|---|---|---|---|
| 1.1 | Certificado de existencia y representación | RUES / Cámara de Comercio | Inactiva, en liquidación, **constituida hace menos de 12 meses** 🔧, **renovación de matrícula atrasada**, **cambios recientes de representante legal, domicilio o razón social** (menos de 6 meses), objeto social que no corresponde a la carga |
| 1.2 | RUT | DIAN | Responsabilidades incoherentes; dirección distinta |
| 1.3 | Biometría del representante legal | KYC | Falla de prueba de vida; documento alterado |
| 1.4 | Beneficiario final | Declaración / RUB | Estructuras opacas, sociedades en cadena, beneficiario no identificable |
| 1.5 | Dirección física | Geolocalización + imagen satelital o de calle + **visita** (para cupos altos) | Dirección de oficina virtual, vivienda, lote vacío |
| 1.6 | Dominio de correo y sitio web | WHOIS / DNS | Dominio creado hace poco; correo gratuito; web clonada de una empresa real |
| 1.7 | Teléfono | OTP + verificación con el directorio de la Cámara de Comercio | El número no coincide con el registrado en la Cámara |

## Capa 2: Listas y reputación

| # | Filtro | Fuente |
|---|---|---|
| 2.1 | **Listas vinculantes**: ONU (Consejo de Seguridad), OFAC (SDN), UE, otras | Proveedor de listas |
| 2.2 | PEP (personas expuestas políticamente) | Proveedor |
| 2.3 | Antecedentes disciplinarios y fiscales (Procuraduría, Contraloría: boletín de responsables fiscales), judiciales (Policía) del representante legal y los socios | Consultas públicas |
| 2.4 | **Procesos judiciales** (demandas ejecutivas, laborales, penales) | Rama Judicial |
| 2.5 | **Insolvencia** (Ley 1116 de 2006): reorganización o liquidación | Supersociedades |
| 2.6 | Noticias negativas (*adverse media*) | Búsqueda automatizada |
| 2.7 | **Base interna de fraude** de la plataforma: NIT, cédulas, teléfonos, cuentas, IP y dispositivos vinculados a fraudes previos | Interna |

## Capa 3: Capacidad financiera

| # | Filtro | Fuente |
|---|---|---|
| 3.1 | Historial en **centrales de riesgo** (score, moras, endeudamiento), con autorización | Datacrédito / TransUnion |
| 3.2 | **Estados financieros** de los 2 últimos años (firmados por contador o revisor fiscal) y declaración de renta | El cliente + Supersociedades (SIIS) si reporta |
| 3.3 | **Comportamiento de facturas en RADIAN** (cómo paga a sus proveedores) ⚠️ disponibilidad de datos | RADIAN / factores |
| 3.4 | **Extractos bancarios** de 6 meses o **finanzas abiertas** (consentimiento para leer cuentas) | Banco / agregador |
| 3.5 | Referencias comerciales **verificadas** (llamada a proveedores reales, no a los números que dio el cliente) | Manual |
| 3.6 | Volumen real de carga (coherencia: lo que pide mover contra su tamaño) | Análisis |

## Capa 4: Comportamiento en la plataforma (continuo)

- Empieza en **contado**. El cupo se gana con un historial de pagos (escalera de cupo, ver `03_SCORING_Y_CUPOS.md`).
- Monitoreo diario: aumento brusco de volumen, nuevas rutas inusuales, cambios de usuarios, cambio de la cuenta bancaria, retrasos de pago incipientes.
- **Patrón "bust-out"**, el fraude más común con plazo: la empresa paga bien varios meses, sube el volumen de golpe hasta llenar el cupo y desaparece. Controles:
  - Límite de **crecimiento del cupo por mes**.
  - Alerta si el uso salta de menos del 50 % a más del 90 % en menos de 2 semanas.
  - Exposición máxima por cliente.
  - Seguro de crédito.

## Capa 5: Revisión humana

Obligatoria para:
- Cupos > X 🔧.
- Cualquier 🚩 de las capas 1 y 2.
- Clientes del sector de **mercancía de alto riesgo** (combustibles, metales, licores, tecnología, químicos precursores).

Comité de crédito con acta digital.

## Señales clásicas de fraude con generadores falsos (para entrenar al equipo y los modelos)

1. **Suplantación de una empresa real** (nombre parecido, documentos falsos, correo de un dominio parecido) para pedir transporte de mercancía de un tercero y **robarla** → validar con la empresa real por un canal oficial independiente.
2. Empresa nueva con capital alto declarado pero sin operación real.
3. Pide el primer viaje **urgente, de alto valor y a crédito**.
4. Cambia el destino a mitad del viaje.
5. Insiste en que se pague a una cuenta de un tercero o en hacer el pago en efectivo.
6. Se niega a la visita o a la videollamada.
