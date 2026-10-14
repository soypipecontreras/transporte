# Protección de datos personales (habeas data)

## 1. Normas
- **Ley 1581 de 2012** (general) y Decreto 1377 de 2013 (compilado en el Decreto 1074 de 2015).
- **Ley 1266 de 2008** (habeas data financiero), modificada por la **Ley 2157 de 2021**.
- Autoridad: **Superintendencia de Industria y Comercio (SIC)**.

## 2. Obligaciones

| Obligación | Implementación |
|---|---|
| **Política de tratamiento de datos** publicada | En la web y en la app |
| **Autorización previa, expresa e informada** | Pantallas de consentimiento separadas por finalidad: operación, GPS, biometría (**dato sensible**: autorización especial y facultativa), centrales de riesgo, compartir con aliados, marketing |
| Registro Nacional de Bases de Datos (RNBD) ante la SIC | Si se cumplen los umbrales de obligatoriedad ⚠️ |
| Derechos de los titulares: conocer, actualizar, rectificar, suprimir, revocar | Centro de privacidad en la app; respuesta a consultas en 10 días hábiles y a reclamos en 15 días hábiles |
| Responsable vs. encargado | Definir quién es quién en cada modelo (ver Modelo A: la plataforma suele ser **encargada** de los datos de la empresa habilitada y responsable de sus propios usuarios) |
| Transferencia o transmisión internacional | Si los servidores están fuera de Colombia: país con nivel adecuado o contrato de transmisión |
| Seguridad | Medidas técnicas (ver `08_SEGURIDAD`) y reporte de incidentes a la SIC |

## 3. Datos especialmente sensibles en esta app
- **Ubicación GPS de personas:** solo durante el viaje y para sus finalidades; minimizar el histórico identificable.
- **Biometría:** dato sensible. Guardar plantillas, no imágenes crudas, cuando sea posible.
- **Datos financieros y scoring:** Ley 1266.
- **Antecedentes:** uso restringido a la debida diligencia.
