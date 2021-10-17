#!/bin/bash
set -e
#apk add curl
#curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.1 1.4.9

echo "${PWD}"
#export PATH=${PWD}/fabric-samples/bin:$PATH
#export FABRIC_CFG_PATH=${PWD}

if [[ $# -ge 9 ]]; then
    CERT_ID=$1
    CERT_PASSWD=$2
    CERT_TYPE=$3
    IP=$4
    PORT=$5
    CA_NAME=$6
    DOMAIN_NAME=$7
    IS_ADMIN=$8
    ORG_NAME=$9
else
    echo "Usage: ./enroll_cert.sh CERT_ID CERT_PASSWD CERT_TYPE IP PORT CANAME DOMAIN_NAME INCLUDE_ADMIN ORG_NAME"
    exit 1
fi

export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/

set -x
fabric-ca-client enroll -u https://admin:adminpw@${IP}:${PORT} --caname ${CA_NAME} --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
{ set +x; } 2>/dev/null


echo "Registering cert"
set -x
  
fabric-ca-client register --caname ${CA_NAME} --id.name ${CERT_ID} --id.secret ${CERT_PASSWD} --id.type ${CERT_TYPE} --id.affiliation org1.department1 --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
{ set +x; } 2>/dev/null


echo "Enroll cert"
set -x
fabric-ca-client enroll -u https://${CERT_ID}:${CERT_PASSWD}@${IP}:${PORT} --caname ${CA_NAME} -M "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/${CERT_ID}/msp" --csr.hosts ${CERT_ID} --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
{ set +x; } 2>/dev/null 
echo "Enroll tls"
set -x
fabric-ca-client enroll -u https://${CERT_ID}:${CERT_PASSWD}@${IP}:${PORT} --caname ${CA_NAME} -M "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/${CERT_ID}/tls" --enrollment.profile tls --csr.hosts ${DOMAIN_NAME} --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
{ set +x; } 2>/dev/null

cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/${CERT_ID}/tls/tlscacerts/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/${CERT_ID}/tls/ca.crt"
cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/${CERT_ID}/tls/signcerts/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/${CERT_ID}/tls/server.crt"
cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/${CERT_ID}/tls/keystore/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/${CERT_ID}/tls/server.key"

if [[ $8 -eq 0 ]]; then
  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ${CA_NAME} --id.name orgadmin --id.secret orgadminpw --id.type admin --id.affliation org1.department1 --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://orgadmin:orgadminpw@${IP}:${PORT} --caname ${CA_NAME} -M "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/users/Admin@${ORG_NAME}/msp" --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

fi



