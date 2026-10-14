# SICE-TAC, fletes y tiempos logísticos

## 1. SICE-TAC

- **Qué es:** el sistema del Ministerio de Transporte que calcula el **costo eficiente de operación** por ruta (origen-destino), configuración del vehículo, tipo de carga y otras variables.
- **Valor jurídico:** desde el Decreto 1017 de 2025 es el **costo mínimo obligatorio** del *valor a pagar* al propietario. Antes, la Resolución 4405 de 2021 ya fijaba su obligatoriedad.
- **No incluye** comisiones, utilidades ni servicios adicionales.
- Consulta pública en el portal del Ministerio. ⚠️ Revisar si existe un servicio web oficial para consulta automática. Si no existe, se obtiene vía RNDC: el manifiesto se rechaza si el valor está por debajo.

## 2. Cómo construye la app el precio

```
FLETE (lo que paga el generador)
 = VALOR A PAGAR al propietario         (≥ SICE-TAC de la ruta y configuración)
 + margen de la empresa habilitada
 + comisión de la plataforma            (sobre el margen o como tarifa aparte; NUNCA se descuenta del valor a pagar)
 + servicios adicionales                (cargue, descargue, escolta, seguro adicional, etc.)
```

| Regla | Descripción |
|---|---|
| RN-010 | Bloqueo si el valor a pagar < SICE-TAC |
| RN-018 | El generador ve el desglose del flete. El transportista ve el valor a pagar y **también el flete**. La transparencia total es parte de la propuesta de valor. |
| RN-019 | Sugerencia de precio: SICE-TAC + histórico de mercado de la ruta (rango) |
| RN-020 | En el modo **subasta o oferta**, ninguna oferta del transportista puede quedar por debajo del SICE-TAC (evita la "guerra a la baja") |

## 3. Horas logísticas (Decreto 1017 de 2025, art. 15)

| Situación | Pago |
|---|---|
| Cargue + descargue ≤ 8 h desde la llegada (según la cita) | Valor de la hora logística del SICE-TAC |
| Cada hora adicional, vehículo **articulado** | **3 SMLDV** por hora |
| Cada hora adicional, vehículo **rígido** | **2 SMLDV** por hora |
| Retraso imputable al propietario (llegó tarde, sin documentos) | Reglas contractuales; la app registra la causa |

**Implementación (RN-030 a RN-033):**
- **RN-030:** cronómetro automático por **geocerca** del punto de cargue o descargue, más una confirmación manual de llegada con foto.
- **RN-031:** la hora de inicio se cuenta desde la **cita programada** si el vehículo llegó antes, o desde la llegada si llegó dentro de la ventana.
- **RN-032:** el cálculo automático del sobrecosto se agrega al valor a pagar y se factura al generador como servicio adicional.
- **RN-033:** los acuerdos entre generador y empresa no afectan lo que se le paga al propietario (no oponibilidad).

## 4. Datos útiles para el mercado (transparencia)

- Publicar índices de flete por corredor, como Bogotá-Buenaventura o Medellín-Cartagena, con datos anonimizados de la app.
- Mostrar el tiempo promedio de cargue por punto, con un **ranking público de generadores y puertos** según sus tiempos. Esto presiona la eficiencia.
