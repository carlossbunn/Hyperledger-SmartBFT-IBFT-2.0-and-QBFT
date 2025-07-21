#!/bin/bash

set -e

CHANNEL_NAME="mychannel"
GENESIS_BLOCK="./mychannel.block"

# Caminhos para o certificado TLS do orderer1 (admin client)
ORDERER_ADMIN_TLS_CERT="organizations/ordererOrganizations/example.com/orderers/orderer1.example.com/tls/server.crt"
ORDERER_ADMIN_TLS_KEY="organizations/ordererOrganizations/example.com/orderers/orderer1.example.com/tls/server.key"
ORDERER_TLS_CA="organizations/ordererOrganizations/example.com/orderers/orderer1.example.com/tls/ca.crt"

echo "Realizando o join do orderer1 ao canal via osnadmin..."
osnadmin channel join \
  --channelID ${CHANNEL_NAME} \
  --config-block ${GENESIS_BLOCK} \
  -o localhost:9443 \
  --ca-file "${ORDERER_TLS_CA}" \
  --client-cert "${ORDERER_ADMIN_TLS_CERT}" \
  --client-key "${ORDERER_ADMIN_TLS_KEY}"

echo "Realizando o join dos outros orderers ao canal..."

for i in 2 3 4
do
  ADMIN_PORT=$((9443 + ($i - 1) * 100))
  echo "Orderer${i} ingressando via p

