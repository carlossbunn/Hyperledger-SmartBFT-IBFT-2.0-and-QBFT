#!/bin/bash

set -e

CHANNEL_NAME="mychannel"
CHAINCODE_NAME="basic"
CHAINCODE_VERSION="1.0"
CHAINCODE_PATH="../chaincode/asset-transfer-basic/chaincode-go/"
CHAINCODE_LABEL="${CHAINCODE_NAME}_${CHAINCODE_VERSION}"
PACKAGE_NAME="${CHAINCODE_LABEL}.tar.gz"
ORDERER_ADDRESS="localhost:7050"
ORDERER_TLS_CA="organizations/ordererOrganizations/example.com/orderers/orderer1.example.com/tls/ca.crt"

echo "Empacotando o chaincode..."
peer lifecycle chaincode package ${PACKAGE_NAME} \
  --path ${CHAINCODE_PATH} \
  --lang golang \
  --label ${CHAINCODE_LABEL}

echo "Instalando e aprovando na Org1..."
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_ADDRESS="localhost:7051"
export CORE_PEER_TLS_ROOTCERT_FILE="organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt"
export CORE_PEER_MSPCONFIGPATH="organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"
peer lifecycle chaincode install ${PACKAGE_NAME}
PACKAGE_ID=$(peer lifecycle chaincode queryinstalled | grep ${CHAINCODE_LABEL} | awk -F "[, ]+" '{print $3}')

peer lifecycle chaincode approveformyorg \
  -o ${ORDERER_ADDRESS} \
  --ordererTLSHostnameOverride orderer1.example.com \
  --channelID ${CHANNEL_NAME} \
  --name ${CHAINCODE_NAME} \
  --version ${CHAINCODE_VERSION} \
  --package-id ${PACKAGE_ID} \
  --sequence 1 \
  --tls \
  --cafile ${ORDERER_TLS_CA}

echo "Instalando e aprovando na Org2..."
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_ADDRESS="localhost:9051"
export CORE_PEER_TLS_ROOTCERT_FILE="organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"
export CORE_PEER_MSPCONFIGPATH="organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp"
peer lifecycle chaincode install ${PACKAGE_NAME}

peer lifecycle chaincode approveformyorg \
  -o ${ORDERER_ADDRESS} \
  --ordererTLSHostnameOverride orderer1.example.com \
  --channelID ${CHANNEL_NAME} \
  --name ${CHAINCODE_NAME} \
  --version ${CHAINCODE_VERSION} \
  --package-id ${PACKAGE_ID} \
  --sequence 1 \
  --tls \
  --cafile ${ORDERER_TLS_CA}

echo "Commitando chaincode..."
peer lifecycle chaincode commit \
  -o ${ORDERER_ADDRESS} \
  --ordererTLSHostnameOverride orderer1.example.com \
  --channelID ${CHANNEL_NAME} \
  --name ${CHAINCODE_NAME} \
  --version ${CHAINCODE_VERSION} \
  --sequence 1 \
  --tls \
  --cafile ${ORDERER_TLS_CA} \
  --peerAddresses localhost:7051 \
  --tlsRootCertFiles organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 \
  --tlsRootCertFiles organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

echo "Testando o chaincode com InitLedger..."
peer chaincode invoke \
  -o ${ORDERER_ADDRESS} \
  --ordererTLSHostnameOverride orderer1.example.com \
  --tls \
  --cafile ${ORDERER_TLS_CA} \
  -C ${CHANNEL_NAME} \
  -n ${CHAINCODE_NAME} \
  --peerAddresses localhost:7051 \
  --tlsRootCertFiles organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 \
  --tlsRootCertFiles organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
  -c '{"Args":["InitLedger"]}'

echo "Realizando query GetAllAssets..."
peer chaincode query -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c '{"Args":["GetAllAssets"]}'

echo "Deploy e teste do chaincode concluído com sucesso!"

