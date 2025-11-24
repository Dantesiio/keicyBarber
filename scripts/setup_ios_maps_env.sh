#!/bin/bash

# Script helper para configurar la variable de entorno GOOGLE_MAPS_API_KEY desde .env
# Uso: source scripts/setup_ios_maps_env.sh
# Luego ejecuta: flutter run

ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
    echo "⚠️  Archivo .env no encontrado en la raíz del proyecto"
    return 1 2>/dev/null || exit 1
fi

# Leer GOOGLE_MAPS_API_KEY desde .env
GOOGLE_MAPS_API_KEY=$(grep "^GOOGLE_MAPS_API_KEY=" "$ENV_FILE" | cut -d '=' -f2- | tr -d '"' | tr -d "'" | tr -d ' ')

if [ -z "$GOOGLE_MAPS_API_KEY" ]; then
    echo "⚠️  GOOGLE_MAPS_API_KEY no encontrado en .env"
    return 1 2>/dev/null || exit 1
fi

# Exportar la variable de entorno (solo para esta sesión)
export GOOGLE_MAPS_API_KEY
echo "✅ Variable GOOGLE_MAPS_API_KEY configurada desde .env"
echo "   Ahora puedes ejecutar: flutter run"

