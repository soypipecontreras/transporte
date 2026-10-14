# Estrategia de crédito: qué se puede hacer legalmente

## 1. Límites legales (no negociables)

| Prohibición o límite | Norma | Consecuencia para el diseño |
|---|---|---|
| **No captar dinero del público** de forma masiva y habitual para prestarlo | Decreto 1981 de 1988; Código Penal, art. 316 (captación ilegal) | La plataforma **no recibe "inversiones" de terceros** para prestar, salvo con una figura autorizada (crowdlending vigilado, fondos de inversión colectiva, etc.) |
| Tasa de interés ≤ **tasa de usura** (1,5 veces el interés bancario corriente certificado por la SFC) | C. Co. art. 884; Código Penal, art. 305 | Todo crédito o mora se calcula con la tasa del mes 🔧 |
| Habeas data financiero: autorización previa, **aviso 20 días antes del reporte negativo**, permanencia limitada | Ley 1266 de 2008, modificada por la **Ley 2157 de 2021** | Flujo de autorización y de aviso automatizado |
| Cobranza respetuosa: horarios y canales limitados | **Ley 2300 de 2023** | Motor de cobranza con restricciones de horario y frecuencia |
| Plazos máximos de pago entre empresas | Ley 2024 de 2020 | RN-201 |

## 2. Modelos posibles (de menor a mayor complejidad regulatoria)

| # | Modelo | Cómo funciona en la app | Quién asume el riesgo | Recomendación |
|---|---|---|---|---|
| 1 | **Marketplace financiero (referido)** | La app comparte (con autorización) el perfil del generador o transportista con aliados financieros. El aliado decide y desembolsa. La plataforma cobra un *fee* por referido | El aliado | ✅ **Fase 1** |
| 2 | **Factoring con aliado** | Al aceptarse la factura en RADIAN, la app ofrece "cobra hoy". El factor compra la factura y paga a la empresa, que paga al camionero | El factor (con o sin recurso) | ✅ **Fase 1** (el núcleo) |
| 3 | **Cupo de crédito comercial** (venta a plazo del servicio) | La empresa habilitada da plazo de 30/45/60 días al generador aprobado; el riesgo se cubre con un **seguro de crédito** y/o factoring sin recurso | La empresa y la aseguradora | ✅ Fase 1-2 |
| 4 | **Fondo propio** | Los socios fondean una SAS financiera con **capital propio** para dar crédito o anticipos | Los socios | Fase 2, con asesoría |
| 5 | **Financiación colaborativa** | Inversionistas fondean facturas o créditos a través de una **plataforma autorizada por la SFC** (Decreto 1357 de 2018, en el Decreto 2555 de 2010) | Los inversionistas | Fase 3, aliándose con una plataforma existente |
| 6 | **Entidad vigilada propia** | Compañía de financiamiento, sociedad especializada en depósitos y pagos electrónicos (SEDPE), etc. | La entidad | Solo a largo plazo |

## 3. Recomendación por fases

- **Fase 1 (lanzamiento):** contado + **cupo comercial asegurado** + **factoring con 2 o 3 aliados** + marketplace de crédito referido. **Sin riesgo de balance para la plataforma.**
- **Fase 2:** fondo propio con capital de los socios para anticipos a transportistas, que son de bajo monto, alta rotación y se descuentan del manifiesto (garantía natural).
- **Fase 3:** finanzas abiertas e inversionistas a través de una plataforma de financiación colaborativa autorizada.

## 4. Enlace del cliente con su crédito desde la app ("solicitar crédito fácil")

Ver `04_FLUJO_DE_SOLICITUD_EN_LA_APP.md`. Principio: **una sola solicitud y varias ofertas**. El usuario autoriza una vez; la app arma el expediente digital y lo envía a los aliados; el usuario compara las ofertas y acepta con firma electrónica.
