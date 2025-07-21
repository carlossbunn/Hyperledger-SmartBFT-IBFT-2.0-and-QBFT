#!/bin/bash

set -e

ROOT_DIR=${PWD}
FABRIC_CA_IMAGE="hyperledger/fabric-ca:latest"

function start_ca_containers() {
  echo "Iniciando servidores Fabric CA via Docker Compose..."
  docker-compose -f docker-compose-ca.yaml up -d
}

function enroll_bootstrap_admin() {
  ORG=$1
  PORT=$2
  CA_NAME=$3
  ORG_PATH=$4

  export FABRIC_CA_CLIENT_HOME=${ROOT_DIR}/organizations/${ORG_PATH}

  fabric-ca-client enroll -u https://admin:adminpw@localhost:${PORT} \
    --caname ${CA_NAME} \
    --tls.certfiles ${ROOT_DIR}/organizations/fabric-ca/${ORG}/tls-cert.pem

  echo "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-${PORT}-${CA_NAME}.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-${PORT}-${CA_NAME}.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-${PORT}-${CA_NAME}.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-${PORT}-${CA_NAME}.pem
    OrganizationalUnitIdentifier: orderer" > ${ROOT_DIR}/organizations/${ORG_PATH}/msp/config.yaml
}

function register_and_enroll_orderers() {
  echo "Registrando e emitindo certificados para os orderers..."

  for i in {1..4}
  do
    fabric-ca-client register --caname ca-orderer \
      --id.name orderer${i} --id.secret ordererpw --id.type orderer \
      --tls.certfiles ${ROOT_DIR}/organizations/fabric-ca/ordererOrg/tls-cert.pem

    fabric-ca-client enroll -u https://orderer${i}:ordererpw@localhost:9054 \
      --caname ca-orderer \
      -M ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer${i}.example.com/msp \
      --csr.hosts orderer${i}.example.com \
      --tls.certfiles ${ROOT_DIR}/organizations/fabric-ca/ordererOrg/tls-cert.pem

    fabric-ca-client enroll -u https://orderer${i}:ordererpw@localhost:9054 \
      --caname ca-orderer \
      -M ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer${i}.example.com/tls \
      --enrollment.profile tls \
      --csr.hosts orderer${i}.example.com \
      --tls.certfiles ${ROOT_DIR}/organizations/fabric-ca/ordererOrg/tls-cert.pem

    cp ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer${i}.example.com/tls/signcerts/*.pem \
       ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer${i}.example.com/tls/server.crt

    cp ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer${i}.example.com/tls/keystore/*_sk \
       ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer${i}.example.com/tls/server.key

    cp ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer${i}.example.com/tls/tlscacerts/*.pem \
       ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer${i}.example.com/tls/ca.crt

    mkdir -p ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer${i}.example.com/msp/tlscacerts

    cp ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer${i}.example.com/tls/ca.crt \
       ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer${i}.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    cp ${ROOT_DIR}/organizations/ordererOrganizations/example.com/msp/config.yaml \
       ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer${i}.example.com/msp/config.yaml
  done

  fabric-ca-client register --caname ca-orderer \
    --id.name ordererAdmin --id.secret ordererAdminPW --id.type admin \
    --tls.certfiles ${ROOT_DIR}/organizations/fabric-ca/ordererOrg/tls-cert.pem

  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminPW@localhost:9054 \
    --caname ca-orderer \
    -M ${ROOT_DIR}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp \
    --tls.certfiles ${ROOT_DIR}/organizations/fabric-ca/ordererOrg/tls-cert.pem
}

function register_and_enroll_peers() {
  ORG=$1
  PORT=$2
  CA_NAME=$3
  ORG_PATH=$4

  for PEER in peer0 peer1
  do
    fabric-ca-client register --caname ${CA_NAME} \
      --id.name ${PEER} --id.secret ${PEER}pw --id.type peer \
      --tls.certfiles ${ROOT_DIR}/organizations/fabric-ca/${ORG}/tls-cert.pem

    fabric-ca-client enroll -u https://${PEER}:${PEER}pw@localhost:${PORT} \
      --caname ${CA_NAME} \
      -M ${ROOT_DIR}/organizations/${ORG_PATH}/peers/${PEER}.${ORG_PATH}/msp \
      --csr.hosts ${PEER}.${ORG_PATH} \
      --tls.certfiles ${ROOT_DIR}/organizations/fabric-ca/${ORG}/tls-cert.pem

    fabric-ca-client enroll -u https://${PEER}:${PEER}pw@localhost:${PORT} \
      --caname ${CA_NAME} \
      -M ${ROOT_DIR}/organizations/${ORG_PATH}/peers/${PEER}.${ORG_PATH}/tls \
      --enrollment.profile tls \
      --csr.hosts ${PEER}.${ORG_PATH} --csr.hosts localhost \
      --tls.certfiles ${ROOT_DIR}/organizations/fabric-ca/${ORG}/tls-cert.pem

    cp ${ROOT_DIR}/organizations/${ORG_PATH}/peers/${PEER}.${ORG_PATH}/tls/signcerts/*.pem \
       ${ROOT_DIR}/organizations/${ORG_PATH}/peers/${PEER}.${ORG_PATH}/tls/server.crt

    cp ${ROOT_DIR}/organizations/${ORG_PATH}/peers/${PEER}.${ORG_PATH}/tls/keystore/*_sk \
       ${ROOT_DIR}/organizations/${ORG_PATH}/peers/${PEER}.${ORG_PATH}/tls/server.key

    cp ${ROOT_DIR}/organizations/${ORG_PATH}/peers/${PEER}.${ORG_PATH}/tls/tlscacerts/*.pem \
       ${ROOT_DIR}/organizations/${ORG_PATH}/peers/${PEER}.${ORG_PATH}/tls/ca.crt

    mkdir -p ${ROOT_DIR}/organizations/${ORG_PATH}/peers/${PEER}.${ORG_PATH}/msp/tlscacerts

    cp ${ROOT_DIR}/organizations/${ORG_PATH}/peers/${PEER}.${ORG_PATH}/tls/ca.crt \
       ${ROOT_DIR}/organizations/${ORG_PATH}/peers/${PEER}.${ORG_PATH}/msp/tlscacerts/tlsca.${ORG}-cert.pem

    cp ${ROOT_DIR}/organizations/${ORG_PATH}/msp/config.yaml \
       ${ROOT_DIR}/organizations/${ORG_PATH}/peers/${PEER}.${ORG_PATH}/msp/config.yaml
  done

  fabric-ca-client register --caname ${CA_NAME} \
    --id.name ${ORG}admin --id.secret ${ORG}adminpw --id.type admin \
    --tls.certfiles ${ROOT_DIR}/organizations/fabric-ca/${ORG}/tls-cert.pem

  fabric-ca-client enroll -u https://${ORG}admin:${ORG}adminpw@localhost:${PORT} \
    --caname ${CA_NAME} \
    -M ${ROOT_DIR}/organizations/${ORG_PATH}/users/Admin@${ORG_PATH}/msp \
    --tls.certfiles ${ROOT_DIR}/organizations/fabric-ca/${ORG}/tls-cert.pem
}

# Execução

start_ca_containers

# OrdererOrg
enroll_bootstrap_admin "ordererOrg" 9054 "ca-orderer" "ordererOrganizations/example.com"
register_and_enroll_orderers

# Org1
enroll_bootstrap_admin "org1" 7054 "ca-org1" "peerOrganizations/org1.example.com"
register_and_enroll_peers "org1" 7054 "ca-org1" "peerOrganizations/org1.example.com"

# Org2
enroll_bootstrap_admin "org2" 8054 "ca-org2" "peerOrganizations/org2.example.com"
register_and_enroll_peers "org2" 8054 "ca-org2" "peerOrganizations/org2.example.com"

echo "Configuração do Fabric CA concluída com sucesso!"

