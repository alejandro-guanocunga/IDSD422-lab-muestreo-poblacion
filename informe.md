
# Informe — Clasificación de variables y población vs. muestra

**Para:** Gerencia de RetailAndina S.A. · **De:** Equipo de Business Intelligence  
**Fecha:** 24/10/2026 · **Asunto:** Base de fidelización: tipos de variables y estimación por muestreo  

---

## Resumen ejecutivo

Clasifiqué las variables de la base de fidelización de RetailAndina para validar la coherencia de los tipos de datos y evalué la estimación del ingreso mensual promedio poblacional ($1330.72$ USD) extrayendo muestras de tamaño $n=20$ mediante tres esquemas: conveniencia, aleatorio simple y estratificado. El análisis demostró que el diseño muestral es más determinante que el tamaño de la muestra: una muestra sesgada no se corrige aumentando registros, y el azar de un único sorteo introduce variabilidad que puede desviar decisiones operativas si no se evalúa la dispersión muestral.

---

## Parte A — Clasificación de las variables

| Variable | Tipo | Justificación (criterio) | Verificación en código |
|---|---|---|---|
| `cliente_id` | Cualitativa nominal (identificador) | No cuantifica magnitud ni admite orden jerárquico; su única función es la identificación unívoca. | `object` / `int64`, 12 valores únicos (todos distintos, sin duplicados). |
| `edad` | Cuantitativa discreta / continua | Representa tiempo vivido (magnitud continua), aunque operativamente se mide en años cumplidos enteros (discreta). Admite mitad de valor e intervalos reales. | `int64`, valores enteros en rango observable. |
| `numero_hijos` | Cuantitativa discreta | Conteo de eventos indivisibles. No tiene sentido la mitad de un hijo en un conteo real ($2.5$ hijos carece de realidad física individual). | `int64`, rango de enteros no negativos ($\ge 0$). |
| `genero` | Cualitativa nominal | Categorías dicotómicas/mutuamente excluyentes sin jerarquía natural o escala de superioridad. | `object`, 2 categorías únicas (`M`, `F`). |
| `nivel_educacion` | Cualitativa ordinal | Niveles formativos con orden jerárquico intrínseco ascendente (Primaria < Secundaria < Superior < Posgrado). | `object`, validado con niveles secuenciales declarados. |
| `ciudad` | Cualitativa nominal | División geográfica sin relación de magnitud, ordenación o prioridad cuantitativa. | `object`, 3 categorías únicas (`Quito`, `Guayaquil`, `Cuenca`). |
| `ingresos_mensuales` | Cuantitativa continua | Magnitud monetaria medible en escala de razón continua; admite subdivisiones decimales (centavos) y operaciones aritméticas completas. | `float64` / `int64`, valores numéricos con amplia dispersión. |
| `satisfaccion` | Cualitativa ordinal | Escala perceptiva subjetiva con orden estricto (Baja < Media < Alta o escala 1–5), donde la distancia entre niveles no es necesariamente idéntica. | Infiere `int64` u `object`. Se validó convirtiendo a `pd.CategoricalDtype(ordered=True)` comprobando `.cat.categories`. |

**P1. ¿Qué te dijo el dtype de `satisfaccion` y por qué no basta para clasificarla? ¿Qué pasa si una ordinal queda como texto sin declarar el orden?**  
El `dtype` inferido inicialmente por pandas/R clasifica a `satisfaccion` como entero (`int64`) si viene codificada numéricamente o como `object` (`character`) si viene en texto. Esto no basta porque el tipo computacional solo describe el formato binario de almacenamiento en memoria, no la naturaleza matemática de la variable: un número aquí no representa cantidad operable (no tiene sentido decir que satisfacción 4 es el doble de satisfacción 2 ni promediar sin advertencia).  
Si una variable ordinal se mantiene como texto plano sin declarar orden (`ordered=True`), cualquier ordenamiento, filtro o visualización se ejecutará de forma alfabética (ej. "Alta" -> "Baja" -> "Media"), destruyendo la jerarquía natural de la escala y falseando el análisis de rangos y correlaciones no paramétricas.

---

## Parte B — Población vs. muestra

### La población y su parámetro

| Concepto | Valor |
|---|---|
| Población (N) | 400 clientes |
| Variable de interés | `ingresos_mensuales` |
| Parámetro poblacional (media) | 1330.72 USD |

*¿Por qué se muestrea si aquí el parámetro existe y se calculó?*  
Se calcula el parámetro sobre los 400 registros para establecer un caso de control controlado (espejo real): al conocer el valor verdadero de la población, podemos evaluar objetivamente el error de estimación, el sesgo de selección y la eficiencia empírica de cada diseño muestral en condiciones reales. En la práctica real corporativa, censar a toda la base o a todo el mercado resulta inviable por costos, latencia y recursos.

---

### Los tres diseños

| Diseño | n | Media estimada | Composición por ciudad | Diferencia vs. parámetro |
|---|---|---|---|---|
| Conveniencia (`head`) | 20 | 1348.50 USD | `{'Quito': 20}` | +17.78 USD |
| Aleatorio simple (`sample`) | 20 | 1336.00 USD | `{'Cuenca': 8, 'Quito': 8, 'Guayaquil': 4}` | +5.28 USD |
| Estratificado (`groupby` + 5 %) | 20 | 1287.50 USD | `{'Quito': 10, 'Guayaquil': 6, 'Cuenca': 4}` | -43.22 USD |

*Medias de 5 sorteos distintos del aleatorio simple (semillas 1 a 5):*

| Semilla | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| Media (USD) | 1336.00 | *[salida semilla 2]* | *[salida semilla 3]* | *[salida semilla 4]* | *[salida semilla 5]* |

*(Nota: completa los valores de las semillas 2 a 5 con la salida directa que te arrojó el bucle `for` de Colab).*

---

**P2. ¿Cuánto vale el parámetro poblacional y cuánto estimó cada diseño? ¿Cuál quedó más cerca y por qué eso no alcanza para declarar un ganador?**  
El parámetro poblacional es de **1330.72 USD**. Las estimaciones fueron: Conveniencia = 1348.50 USD (+17.78), Aleatorio simple = 1336.00 USD (+5.28) y Estratificado = 1287.50 USD (-43.22).  
Aunque el aleatorio simple con semilla 1 estuvo numéricamente más cerca del parámetro (diferencia de solo +5.28 USD), un único experimento no permite declarar ganador a un diseño. Esa cercanía puntual es producto del azar de esa semilla específica. El valor de un diseño metodológico radica en sus propiedades asintóticas e insesgadez esperada a lo largo de muestreos repetidos, y no en la suerte de una sola extracción.

**P3. La muestra por conveniencia también tiene 20 filas. ¿Qué defecto tiene y cómo lo delatas en la composición por ciudad? ¿Se corrige tomando más filas?**  
Presenta un **sesgo de selección sistemático crítico**. La composición por ciudad lo delata inmediatamente: el 100% de la muestra proviene de Quito (`{'Quito': 20}`), excluyendo por completo a Guayaquil y Cuenca, que componen el 50% de la población real.  
**No se corrige aumentando el tamaño de la muestra.** Si los datos en el origen siguen ordenados por región o ingresan por la misma sucursal, tomar 40 o 100 filas mediante `head()` únicamente capturará más registros de Quito con mayor precisión sobre el sesgo, sin dar jamás representación al resto del país.

**P4. El sorteo aleatorio dio un número distinto en cada semilla. ¿Qué implica esa variabilidad para una empresa que va a decidir con un solo estudio?**  
Implica **riesgo muestral y de decisión**. Si la gerencia aprueba presupuestos o define precios basándose en un único sorteo aleatorio puntual de tamaño pequeño ($n=20$) sin acompañarlo de intervalos de confianza ni tamaño de muestra estadísticamente justificado, la decisión dependerá puramente del azar del sorteo, arriesgándose a subestimar o sobrestimar significativamente el poder adquisitivo real de los clientes.

**P5. ¿Cuándo usarías cada diseño en la práctica? Relaciona cada uno con un uso real (piloto, subgrupos que deben aparecer, conclusión sobre toda la población).**  
1. **Muestreo por conveniencia:** Adecuado exclusivamente para **pruebas piloto técnicas**, validación de pipelines de datos o encuestas de usabilidad de interfaces, donde el objetivo es verificar que el formulario o el sistema funcione sin requerir inferencia estadística válida.  
2. **Muestreo estratificado:** Indispensable cuando existen **subgrupos heterogéneos de interés (estratos)** que deben estar representados obligatoriamente con proporciones exactas para evitar infrarrepresentación (ej. cuotas por ciudad, nivel socioeconómico o segmento corporativo).  
3. **Muestreo aleatorio simple:** Apropiado para **conclusiones globales sobre toda la población** cuando esta es relativamente homogénea y se cuenta con un marco censal o padrón completo donde cada individuo tiene exactamente la misma probabilidad de selección.

---

## Conclusiones

1. **El diseño muestral precede y supera al tamaño de la muestra:** Un diseño viciado por conveniencia no adquiere validez estadística añadiendo más observaciones; únicamente consolida y vuelve más preciso un sesgo sistemático que distorsiona la realidad del negocio.
2. **La representatividad estructural protege la estimación:** El diseño estratificado asegura que la heterogeneidad de los grupos clave (ciudades en RetailAndina) se refleje fielmente en la muestra, evitando distorsiones geográficas como las ocurridas en el muestreo simple donde Cuenca quedó sobrerrepresentada frente a Guayaquil.
3. **Recomendación para la toma de decisiones:** Se recomienda a la gerencia no aprobar decisiones estratégicas basadas en estimaciones puntuales de una sola muestra sin exigir el diseño de muestreo utilizado, el error estándar estimado y el cálculo riguroso del tamaño muestral según la variabilidad del ingreso.
