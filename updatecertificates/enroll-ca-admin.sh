#!/bin/bash
set -e
#apk add curl
#curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.1 1.4.9

echo "${PWD}"
#export PATH=${PWD}/fabric-samples/bin:$PATH
#export FABRIC_CFG_PATH=${PWD}

if [[ $# -ge 3 ]]; then
    ORG_NAME=$1
    IP=$2
    PORT=$3
    CA_NAME=$4
else
    echo "Usage: ./enroll.sh orgname ip port caname"
    exit 1
fi
echo "Enrolling the CA admin"
mkdir -p crypto-config/organizations/peerOrganizations/${ORG_NAME}/

export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/
set -x
fabric-ca-client enroll -u https://admin:adminpw@${IP}:${PORT} --caname ${CA_NAME} --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
{ set +x; } 2>/dev/null