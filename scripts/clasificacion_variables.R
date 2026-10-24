# clasificacion_variables.R — Parte A: clasificación y verificación de variables en R.
#
# Uso (desde la raíz del repositorio):  Rscript scripts/clasificacion_variables.R

# 1. Cargar datos e inspeccionar estructura
df <- read.csv("data/clientes.csv")

cat("=== 1. ESTRUCTURA Y TIPOS INFERIDOS (str) ===\n")
str(df)
cat("\n")

# 2. Valores únicos
cat("=== 2. VALORES ÚNICOS POR COLUMNA ===\n")
print(lapply(df, unique))
cat("\n")

# 3. Factor ordenado para variables ordinales
cat("=== 3. CONVERSIÓN A FACTOR ORDENADO (ORDINALES) ===\n")

if (is.numeric(df$satisfaccion)) {
  df$satisfaccion <- factor(df$satisfaccion, levels = sort(unique(df$satisfaccion)), ordered = TRUE)
} else {
  df$satisfaccion <- factor(df$satisfaccion, levels = c("Baja", "Media", "Alta"), ordered = TRUE)
}

if ("nivel_educacion" %in% names(df)) {
  niveles_edu <- c("Primaria", "Secundaria", "Superior", "Posgrado")
  presentes_edu <- niveles_edu[niveles_edu %in% unique(df$nivel_educacion)]
  if (length(presentes_edu) > 0) {
    df$nivel_educacion <- factor(df$nivel_educacion, levels = presentes_edu, ordered = TRUE)
  }
}

str(df)
