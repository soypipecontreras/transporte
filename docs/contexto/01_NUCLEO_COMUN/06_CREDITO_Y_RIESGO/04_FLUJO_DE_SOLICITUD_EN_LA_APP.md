# Flujo de solicitud de crédito en la app (generador y transportista)

## 1. Para el generador: "Pagar a plazo"

```
[Perfil empresa] → botón "Solicitar pago a plazo"
   1. Elige el cupo y el plazo deseados (la app limita según Ley 2024 / RN-201)
   2. Autorizaciones con firma electrónica:
        - Consulta y reporte en centrales de riesgo (Ley 1266)
        - Tratamiento de datos y compartirlos con los aliados financieros nombrados (Ley 1581)
        - (Opcional) Finanzas abiertas: conexión a sus cuentas bancarias
   3. Carga de documentos (lo que no se obtiene automáticamente):
        - Estados financieros de 2 años + notas, declaración de renta
        - Composición accionaria y beneficiarios finales
        - Referencias comerciales
   4. Motor de decisión: capas 1-4 automáticas (minutos) → capa 5 manual si aplica (≤ 48 h hábiles 🔧)
   5. Resultado:
        - APROBADO: cupo, plazo, condiciones; firma del **pagaré electrónico / carta de instrucciones**
          (desmaterializado ante un depósito centralizado de valores ⚠️ o firma electrónica certificada)
        - CONDICIONADO: pide una garantía (póliza, aval, garantía FNG, depósito)
        - RECHAZADO: razones generales + opción de contado o factoring a cargo del generador
   6. Activación: las cargas publicadas "a plazo" descuentan el cupo; el saldo se ve en línea
```

## 2. Para la empresa habilitada: "Cobrar hoy" (factoring)
1. Lista de facturas **aceptadas en RADIAN** y elegibles.
2. La app muestra las ofertas de los factores aliados (tasa de descuento, con o sin recurso).
3. La empresa elige → **endoso electrónico en RADIAN** → desembolso en 24-48 h.
4. Al vencimiento, el generador paga al factor (la app le indica la nueva cuenta de pago a partir del endoso).
5. Se concilia automáticamente.

## 3. Para el transportista: anticipos y créditos
| Producto | Monto | Garantía natural | Proveedor |
|---|---|---|---|
| **Anticipo del viaje** | % del valor a pagar 🔧 | Se descuenta en el cumplido | Empresa o fondo propio |
| **Pronto pago** (cobrar el mismo día del cumplido en lugar de a los 5 días) | Valor a pagar − pequeño descuento 🔧 | Manifiesto cumplido (mérito ejecutivo) | Fondo propio / factor |
| Combustible y peajes a crédito | Por viaje | Se descuenta del valor a pagar (autorizado en el contrato de vinculación) | Estaciones aliadas |
| Llantas, repuestos, mantenimiento | Mediano | Libranza sobre los fletes futuros ⚠️ revisar la figura | Aliados |
| Crédito de vehículo / renovación (FOPAT) | Alto | Prenda | Bancos, Bancóldex, programas de modernización |

⚠️ **Descuentos al propietario por créditos:** solo con su **autorización expresa, previa y revocable** en el contrato de vinculación. **Nunca** pueden dejar el valor a pagar efectivo por debajo del SICE-TAC sin una autorización específica. Validar con un abogado: el Decreto 1017 prohíbe los descuentos "no permitidos".

## 4. Experiencia ("fácil")
- Todo en menos de 10 minutos para el usuario si está bien registrado.
- Barra de avance, lista de lo que falta y notificaciones por WhatsApp o correo.
- Un **solo expediente** reutilizable para varios aliados.
- El lenguaje es claro: se muestra la **tasa efectiva anual y el costo total** antes de aceptar.
