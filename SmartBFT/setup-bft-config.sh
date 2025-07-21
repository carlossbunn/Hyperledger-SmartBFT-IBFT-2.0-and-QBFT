#!/bin/bash

set -e

ROOT_DIR=${PWD}
CHANNEL_NAME="mychannel"
GENESIS_BLOCK_OUTPUT="${ROOT_DIR}/${CHANNEL_NAME}.block"

echo "Gerando configtx.yaml com configuração BFT..."

cat > ${ROOT_DIR}/configtx.yaml <<EOF
Organizations:
    - &OrdererOrg
        Name: OrdererOrg
        ID: OrdererMSP
        MSPDir: ${ROOT_DIR}/organizations/ordererOrganizations/example.com/msp
        Policies:
            Readers:
                Type: Signature
                Rule: "OR('OrdererMSP.admin')"
            Writers:
                Type: Signature
                Rule: "OR('OrdererMSP.member')"
            Admins:
                Type: Signature
                Rule: "OR('OrdererMSP.admin')"

    - &Org1
        Name: Org1MSP
        ID: Org1MSP
        MSPDir: ${ROOT_DIR}/organizations/peerOrganizations/org1.example.com/msp
        Policies:
            Readers:
                Type: Signature
                Rule: "OR('Org1MSP.admin')"
            Writers:
                Type: Signature
                Rule: "OR('Org1MSP.member')"
            Admins:
                Type: Signature
                Rule: "OR('Org1MSP.admin')"

    - &Org2
        Name: Org2MSP
        ID: Org2MSP
        MSPDir: ${ROOT_DIR}/organizations/peerOrganizations/org2.example.com/msp
        Policies:
            Readers:
                Type: Signature
                Rule: "OR('Org2MSP.admin')"
            Writers:
                Type: Signature
                Rule: "OR('Org2MSP.member')"
            Admins:
                Type: Signature
                Rule: "OR('Org2MSP.admin')"

Orderer:
    OrdererType: BFT
    Addresses:
        - orderer1.example.com:7050
        - orderer2.example.com:7050
        - orderer3.example.com:7050
        - orderer4.example.com:7050
    BatchTimeout: 2s
    BatchSize:
        MaxMessageCount: 500
        AbsoluteMaxBytes: 10 MB
        PreferredMaxBytes: 2 MB
    SmartBFT:
        RequestBatchMaxInterval: 200ms
        RequestForwardTimeout: 5s
        RequestComplainTimeout: 20s
        RequestAutoRemoveTimeout: 3m
        ViewChangeResendInterval: 5s
        ViewChangeTimeout: 20s
        LeaderHeartbeatTimeout: 1m
        LeaderHeartbeatCount: 10
        IncomingMessageBufferSize: 200
        RequestPoolSize: 100000
        CollectTimeout: 1s
        ConsenterMapping:
            - ID: 1
              Host: orderer1.example.com
              Port: 7050
              MSPID: OrdererMSP
              Identity: ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/signcerts/cert.pem
              ClientTLSCert: ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer1.example.com/tls/server.crt
              ServerTLSCert: ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer1.example.com/tls/server.crt
            - ID: 2
              Host: orderer2.example.com
              Port: 7050
              MSPID: OrdererMSP
              Identity: ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/signcerts/cert.pem
              ClientTLSCert: ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.crt
              ServerTLSCert: ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.crt
            - ID: 3
              Host: orderer3.example.com
              Port: 7050
              MSPID: OrdererMSP
              Identity: ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/signcerts/cert.pem
              ClientTLSCert: ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.crt
              ServerTLSCert: ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.crt
            - ID: 4
              Host: orderer4.example.com
              Port: 7050
              MSPID: OrdererMSP
              Identity: ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer4.example.com/msp/signcerts/cert.pem
              ClientTLSCert: ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer4.example.com/tls/server.crt
              ServerTLSCert: ${ROOT_DIR}/organizations/ordererOrganizations/example.com/orderers/orderer4.example.com/tls/server.crt

Capabilities:
    Channel: &ChannelCapabilities
        V2_0: true
    Orderer: &OrdererCapabilities
        V2_0: true
    Application: &ApplicationCapabilities
        V2_0: true

Application:
    Organizations:

Profiles:
    MyChannelBFTProfile:
        Orderer:
            <<: *Orderer
            Organizations:
                - *OrdererOrg
        Application:
            Organizations:
                - *Org1
                - *Org2
            Capabilities:
                <<: *ApplicationCapabilities
EOF

echo "Arquivo configtx.yaml gerado com sucesso."

echo "Gerando bloco gênese com configtxgen..."

export FABRIC_CFG_PATH=${ROOT_DIR}

configtxgen -profile MyChannelBFTProfile \
    -channelID ${CHANNEL_NAME} \
    -outputBlock ${GENESIS_BLOCK_OUTPUT}

echo "Bloco gênese criado em: ${GENESIS_BLOCK_OUTPUT}"

