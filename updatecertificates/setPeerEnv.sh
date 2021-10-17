#!/bin/bash
set -e
if [[ $# -ge 3 ]]; then
    ORG_NAME=$1
    MSPID=$2
    ADDRESS=$3
    PEER_TYPE=$4
    PEER_NAME=$5
else
    echo "Usage: ./setNodeEnv.sh orgname mspid peerAddress peer_type peer_name "
    set +e
    exit 1
fi
set -x
export CORE_PEER_TLS_ENABLED=true
export FABRIC_CFG_PATH=./config/
export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/users/Admin@${ORG_NAME}/msp
export CORE_PEER_ADDRESS=${ADDRESS}
export CORE_PEER_LOCALMSPID="${MSPID}"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/${PEER_TYPE}/${PEER_NAME}.${ORG_NAME}/tls/ca.crt
set +x
set +e