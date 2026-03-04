#!/bin/bash
# ──────────────────────────────────────────────
# Ejecutar análisis de SonarQube para MotoGo Frontend
# ──────────────────────────────────────────────
# Uso: ./scripts/execute_sonar.sh
# ──────────────────────────────────────────────

set -e

SONAR_TOKEN="sqp_b1abf475866e9ad8953cf69cdbee565d5acfdf35"
SONAR_URL="http://localhost:9020"
PROJECT_KEY="MotoGo-Frontend"

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔍 SonarQube Scanner — MotoGo Frontend${NC}"
echo "────────────────────────────────────"

# 1. Verificar que sonar-scanner esté instalado
if ! command -v sonar-scanner &> /dev/null; then
    echo -e "${RED}❌ sonar-scanner no encontrado. Instalar con: brew install sonar-scanner${NC}"
    exit 1
fi

# 2. Verificar que SonarQube esté corriendo
if ! curl -s "$SONAR_URL/api/system/status" | grep -q "UP"; then
    echo -e "${RED}❌ SonarQube no está corriendo en $SONAR_URL${NC}"
    echo -e "${YELLOW}   Levantar con: docker compose -f ~/Documents/go/Rb-Go-Backend/docker-compose.sonar.yml up -d${NC}"
    exit 1
fi
echo -e "${GREEN}✅ SonarQube corriendo en $SONAR_URL${NC}"

# 3. Generar cobertura con Flutter
echo -e "${YELLOW}📊 Ejecutando tests con cobertura...${NC}"
flutter test --coverage 2>&1 | tail -5
echo -e "${GREEN}✅ Cobertura generada: coverage/lcov.info${NC}"

# 4. Ejecutar scanner (sobreescribe sonar-project.properties para apuntar a local)
echo -e "${YELLOW}🚀 Ejecutando análisis...${NC}"
sonar-scanner \
  -Dsonar.projectKey="$PROJECT_KEY" \
  -Dsonar.projectName="MotoGo Frontend" \
  -Dsonar.host.url="$SONAR_URL" \
  -Dsonar.token="$SONAR_TOKEN" \
  -Dsonar.sources=lib \
  -Dsonar.tests=test \
  -Dsonar.test.inclusions="**/*_test.dart" \
  -Dsonar.exclusions="**/*.g.dart,**/*.freezed.dart,**/generated/**,**/*.mocks.dart" \
  -Dsonar.coverage.exclusions="**/*.g.dart,**/*.freezed.dart,**/generated/**,**/*.mocks.dart,**/presentation/**,**/core/widgets/**,**/core/injector/**,**/core/services/**" \
  -Dsonar.dart.lcov.reportPaths=coverage/lcov.info \
  -Dsonar.cpd.exclusions="**/domain/repositories/**,**/data/datasources/**" \
  -Dsonar.sourceEncoding=UTF-8

echo ""
echo -e "${GREEN}✅ Análisis completo. Ver resultados en:${NC}"
echo -e "${GREEN}   $SONAR_URL/dashboard?id=$PROJECT_KEY${NC}"
