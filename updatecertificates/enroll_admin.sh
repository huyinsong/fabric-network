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
else
    echo "Usage: ./enroll_cert.sh ORG_NAME IP PORT"
    exit 1
fi

export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/organizations/${ORG_NAME}/

set -x
fabric-ca-client enroll -u https://admin:adminpw@${IP}:${PORT} --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
{ set +x; } 2>/dev/null


echo "Registering cert"
set -x
echo "Registering the org admin"
set -x
fabric-ca-client register --id.name orgadmin --id.secret orgadminpw --id.type admin --id.affliation org1.department1 --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
{ set +x; } 2>/dev/null

echo "Generating the org admin msp"
set -x
fabric-ca-client enroll -u https://orgadmin:orgadminpw@${IP}:${PORT} -M "${PWD}/crypto-config/organizations/${ORG_NAME}/admin/msp" --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
{ set +x; } 2>/dev/null


