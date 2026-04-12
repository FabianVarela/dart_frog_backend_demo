#!/bin/bash

# Script para probar el rate limiting
# Uso: ./test_rate_limit.sh [número_de_solicitudes]

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# URL del servidor (ajusta si es necesario)
URL="http://localhost:8080"

# Número de solicitudes (por defecto 105 para exceder el límite de 100)
NUM_REQUESTS=${1:-105}

echo -e "${YELLOW}🧪 Probando Rate Limiting${NC}"
echo -e "URL: $URL"
echo -e "Número de solicitudes: $NUM_REQUESTS"
echo -e "Límite configurado: 100 solicitudes por minuto\n"

# Contador de respuestas exitosas y limitadas
SUCCESS_COUNT=0
RATE_LIMITED_COUNT=0

for i in $(seq 1 $NUM_REQUESTS); do
    # Hacer la solicitud y capturar headers y status code
    RESPONSE=$(curl -s -w "\n%{http_code}" -D - "$URL" 2>/dev/null)
    STATUS_CODE=$(echo "$RESPONSE" | tail -n 1)
    HEADERS=$(echo "$RESPONSE" | sed '$d')

    # Extraer headers relevantes
    LIMIT=$(echo "$HEADERS" | grep -i "x-ratelimit-limit" | cut -d' ' -f2 | tr -d '\r')
    REMAINING=$(echo "$HEADERS" | grep -i "x-ratelimit-remaining" | cut -d' ' -f2 | tr -d '\r')
    RETRY_AFTER=$(echo "$HEADERS" | grep -i "retry-after" | cut -d' ' -f2 | tr -d '\r')

    if [ "$STATUS_CODE" -eq 429 ]; then
        RATE_LIMITED_COUNT=$((RATE_LIMITED_COUNT + 1))
        echo -e "${RED}Request #$i - Status: $STATUS_CODE (TOO MANY REQUESTS)${NC}"
        echo -e "  Retry-After: ${RETRY_AFTER}s"
    else
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        echo -e "${GREEN}Request #$i - Status: $STATUS_CODE${NC}"
    fi

    if [ ! -z "$LIMIT" ]; then
        echo -e "  Limit: $LIMIT | Remaining: $REMAINING"
    fi

    # Pequeña pausa entre solicitudes
    sleep 0.05
done

echo -e "\n${YELLOW}📊 Resumen:${NC}"
echo -e "${GREEN}✓ Solicitudes exitosas: $SUCCESS_COUNT${NC}"
echo -e "${RED}✗ Solicitudes limitadas (429): $RATE_LIMITED_COUNT${NC}"

if [ $RATE_LIMITED_COUNT -gt 0 ]; then
    echo -e "\n${GREEN}🎉 ¡Rate limiting funcionando correctamente!${NC}"
else
    echo -e "\n${YELLOW}⚠️  No se alcanzó el límite. Intenta con más solicitudes.${NC}"
fi
