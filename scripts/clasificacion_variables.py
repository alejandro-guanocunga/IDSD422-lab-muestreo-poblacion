# clasificacion_variables.py — Parte A: clasificación y verificación de variables.
#
# La base de trabajo es data/clientes.csv (12 clientes, 7 variables + identificador).
# El objetivo es inspeccionar los tipos inferidos, evaluar el orden de las variables
# cualitativas y declarar explícitamente el orden en las ordinales.
#
# Uso (desde la raíz del repositorio):  python scripts/clasificacion_variables.py

import pandas as pd

# 1. Cargar datos e inspeccionar tipos iniciales
df = pd.read_csv("data/clientes.csv")

print("=== 1. TIPOS DE DATOS INFERIDOS (dtypes) ===")
print(df.dtypes)
print()

# 2. Exploración de valores únicos por variable
print("=== 2. VALORES ÚNICOS POR COLUMNA ===")
for col in df.columns:
    unicos = df[col].unique()
    print(f"{col:20s} | {len(unicos):2d} únicos | {unicos}")
print()

# 3. Declaración explícita de variables cualitativas ordinales
print("=== 3. DECLARACIÓN DE ORDEN EN VARIABLES ORDINALES ===")

if df["satisfaccion"].dtype in ["int64", "float64"]:
    niveles_sat = sorted(df["satisfaccion"].unique())
else:
    niveles_sat = ["Baja", "Media", "Alta"]

df["satisfaccion"] = pd.Categorical(df["satisfaccion"], categories=niveles_sat, ordered=True)

if "nivel_educacion" in df.columns:
    niveles_edu = ["Primaria", "Secundaria", "Superior", "Posgrado"]
    presentes_edu = [n for n in niveles_edu if n in df["nivel_educacion"].unique()]
    if presentes_edu:
        df["nivel_educacion"] = pd.Categorical(df["nivel_educacion"], categories=presentes_edu, ordered=True)

print("dtypes verificados tras definir variables categóricas:")
print(df.dtypes)
print(f"\nCategorías ordenadas de satisfacción: {df['satisfaccion'].cat.categories}")
