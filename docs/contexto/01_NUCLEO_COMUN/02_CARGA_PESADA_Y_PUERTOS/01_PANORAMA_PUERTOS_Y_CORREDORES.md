# Carga pesada y puertos: panorama

El foco del negocio es la **carga pesada** (PBV > 10.500 kg), en especial la que **entra y sale por los puertos**. Ahí están los mayores volúmenes, los mayores sobrecostos (esperas, contenedores vacíos, citas) y la mayor presencia de intermediarios informales.

## 1. Zonas portuarias principales

| Zona | Terminales relevantes (ejemplos) | Tipo de carga | Corredores terrestres principales |
|---|---|---|---|
| **Buenaventura** (Pacífico) | Sociedad Portuaria Regional (SPRBUN), TCBUEN, Puerto Aguadulce, otros muelles | Contenedores (importación de Asia), granel agrícola (maíz, trigo, soya), acero | Buenaventura – Buga – Cali / Eje Cafetero / Bogotá (vía La Línea) / Medellín |
| **Cartagena** | SPRC (Manga), Contecar, muelles privados | Contenedores, transbordo, granel líquido | Cartagena – Bogotá (Ruta del Sol), Cartagena – Medellín, Costa |
| **Barranquilla** | Sociedad Portuaria de Barranquilla y muelles fluviales | Carbón, acero, granel, contenedores | Barranquilla – Bogotá / interior |
| **Santa Marta** | Sociedad Portuaria de Santa Marta, carboneras de la zona | Carbón, banano, granel, contenedores | Santa Marta – Bogotá / Cesar |
| **Urabá** | Puerto Antioquia y muelles bananeros | Banano, contenedores (nuevo) | Urabá – Medellín (Autopistas al Mar) ⚠️ verificar el estado operativo de las vías y del puerto |
| **La Guajira / Golfo de Morrosquillo / Tumaco** | Puertos especializados (carbón, hidrocarburos) | Granel especializado | Locales |

⚠️ Las terminales, sus sistemas de citas y sus reglas cambian. La app debe tener un **catálogo de terminales** 🔧 administrable (nombre, ubicación, geocercas, sistema de citas, horarios, contacto, requisitos de ingreso).

## 2. Tipos de carga pesada que debe soportar la app

| Tipo | Vehículo típico | Particularidades |
|---|---|---|
| Contenedor 20' / 40' / 40' HC (seco) | Tractocamión + portacontenedor (3S2, 3S3) | Comodato, EIR, devolución del vacío, DTA, precinto |
| Contenedor refrigerado (reefer) | Portacontenedor + generador (genset) | Monitoreo de temperatura, conexión |
| Granel sólido (maíz, trigo, carbón, fertilizante) | Volco, tolva, carpado | Pesaje en báscula, carpado obligatorio, merma |
| Granel líquido | Carrotanque | Mercancías peligrosas si aplica |
| Carga general / suelta / palets | Furgón, plancha, carpado | Estiba, amarre |
| Acero, bobinas, tubería | Plancha, cama baja | Amarre especial, sobrepeso |
| Carga de proyecto o extradimensionada | Cama baja, modulares | Permiso especial, escoltas, rutas |
| Mercancías peligrosas | Según la clase de la ONU | Rotulado, hoja de seguridad, tarjeta de emergencia, curso del conductor |

## 3. Dolores del sector portuario que la app resuelve

| Dolor | Solución en la app |
|---|---|
| Esperas de días para entrar al puerto (filas en la vía) | Gestión de **citas** e integración con las terminales; enturnamiento virtual; el camión llega a su hora |
| Camión vacío de regreso (viaje redondo perdido) | **Emparejamiento de retorno**: importación + exportación, o importación + devolución del vacío + nueva carga |
| Contenedor vacío sin dónde devolver; cobros de *detention* | Alertas de días libres, reserva de devolución en patios, evidencia de intentos fallidos para disputar cobros |
| "Jaladores" que cobran por conseguir carga o turno | La carga se publica y se asigna dentro de la app, sin cobro al transportista |
| Contaminación del contenedor (droga) que termina en el conductor | Protocolo de inspección con evidencia fotográfica, verificación del precinto y cadena de custodia (ver `08_SEGURIDAD_Y_ANTIFRAUDE`) |
| Documentación en papel (EIR, remesas, cumplidos) | Todo digital y firmado electrónicamente |
| Pago tardío al transportista | Pago en 5 días hábiles garantizado por la plataforma y sus aliados financieros |
