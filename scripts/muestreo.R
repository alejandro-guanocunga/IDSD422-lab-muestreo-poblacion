# muestreo.R — Parte B: población vs. muestra (RetailAndina).
#
# Uso (desde la raíz del repositorio):  Rscript scripts/muestreo.R

suppressPackageStartupMessages(library(dplyr))

poblacion <- read.csv("data/clientes_400.csv")

reporte <- function(nombre, muestra, parametro) {
  if (is.null(muestra)) {
    cat(sprintf("[%s] pendiente de completar (TODO)\n", nombre))
    return(invisible(NULL))
  }
  media <- mean(muestra$ingresos_mensuales)
  cat(sprintf("[%s] n=%d  media=%.2f USD  (parámetro %.2f, diferencia %+.2f)\n",
              nombre, nrow(muestra), media, parametro, media - parametro))
  cat("    composición por ciudad: ")
  print(table(muestra$ciudad))
}

# 1. Población y parámetro
cat(sprintf("Población: %d clientes × %d columnas\n", nrow(poblacion), ncol(poblacion)))
parametro <- mean(poblacion$ingresos_mensuales)
cat(sprintf("Parámetro poblacional — ingreso medio: %.2f USD\n", parametro))
cat("Ciudades en la población: "); print(table(poblacion$ciudad))
cat("\n")

# TODO 1: Conveniencia
muestra_conv <- head(poblacion, 20)

# TODO 2: Aleatorio simple (semilla 1)
set.seed(1)
muestra_aas <- poblacion[sample(nrow(poblacion), 20), ]

# TODO 3: Semillas 1 a 5
cat("--- Medias obtenidas con semillas 1 a 5 (Aleatorio simple) ---\n")
for (semilla in 1:5) {
  set.seed(semilla)
  m_temp <- poblacion[sample(nrow(poblacion), 20), ]
  cat(sprintf("Semilla %d: media = %.2f USD\n", semilla, mean(m_temp$ingresos_mensuales)))
}
cat("\n")

# TODO 4: Estratificado (5% por ciudad)
set.seed(1)
muestra_est <- poblacion %>% group_by(ciudad) %>% slice_sample(prop = 0.05) %>% ungroup()

# 5. Comparación final
reporte("Conveniencia", muestra_conv, parametro)
reporte("Aleatorio simple", muestra_aas, parametro)
reporte("Estratificado", muestra_est, parametro)

if (!is.null(muestra_conv) && !is.null(muestra_aas) && !is.null(muestra_est)) {
  resumen <- data.frame(
    diseno = c("Conveniencia (head)", "Aleatorio simple (sample)", "Estratificado (slice_sample)"),
    n = c(nrow(muestra_conv), nrow(muestra_aas), nrow(muestra_est)),
    media_estimada = round(c(mean(muestra_conv$ingresos_mensuales),
                             mean(muestra_aas$ingresos_mensuales),
                             mean(muestra_est$ingresos_mensuales)), 2)
  )
  cat(sprintf("\nParámetro poblacional: %.2f USD\n", parametro))
  print(resumen, row.names = FALSE)
}
