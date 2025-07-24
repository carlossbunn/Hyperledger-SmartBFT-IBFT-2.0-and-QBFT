#!/bin/bash

set -e

ROOT_DIR=${PWD}
GENESIS_BLOCK="${ROOT_DIR}/mychannel.block"
ORDERERS=(orderer1 orderer2 orderer3 orderer4)

echo "🔍 Verificando bloco gênese..."
if [ ! -f "${GENESIS_BLOCK}" ]; then
  echo "❌ Bloco gênese não encontrado em ${GENESIS_BLOCK}"
  echo "Execute o setup-bft-config.sh antes."
  exit 1
fi

echo "📦 Preparando diretórios dos orderers..."
for ORDERER in "${ORDERERS[@]}"; do
  DST_DIR="${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com"
  mkdir -p "${DST_DIR}/system-genesis-block"
  cp "${GENESIS_BLOCK}" "${DST_DIR}/system-genesis-block/genesis.block"
  echo "✅ Copiado para ${DST_DIR}/system-genesis-block/"
done

echo "✅ Todos os orderers receberam o bloco gênese."

echo "📁 Verificando estrutura dos peers..."

PEERS=(
  "peer0.org1.example.com"
  "peer1.org1.example.com"
  "peer0.org2.example.com"
  "peer1.org2.example.com"
)

for PEER in "${PEERS[@]}"; do
  ORG=$(echo "$PEER" | cut -d. -f2)
  DST_DIR="${ROOT_DIR}/organizations/peerOrganizations/${ORG}.example.com/peers/${PEER}"
  MSP_DIR="${DST_DIR}/msp"
  TLS_DIR="${DST_DIR}/tls"

  if [ ! -d "$MSP_DIR" ] || [ ! -d "$TLS_DIR" ]; then
    echo "❗ Diretórios de MSP/TLS ausentes em $PEER, verifique se a etapa do Fabric CA foi concluída."
  else
    echo "✅ Estrutura de $PEER está ok."
  fi
done

echo "🧹 Limpando volumes antigos de Docker (opcional)..."
# docker volume prune -f  # <- descomente apenas se tiver certeza!

echo "✅ Setup completo. Agora você pode executar:"
echo "docker-compose -f docker-compose-net.yaml up -d"

