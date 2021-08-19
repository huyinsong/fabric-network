#!/bin/bash
set -e
#apk add curl
#curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.1 1.4.9

echo ${PWD}
#export PATH=${PWD}/fabric-samples/bin:$PATH
#export FABRIC_CFG_PATH=${PWD}

if [[ $# -ge 3 ]]; then
    ORG_NAME=$1
    IP=$2
    PORT=$3
else
    echo "Usage: ./enroll.sh orgname ip port"
    exit 1
fi
echo "Enrolling the CA admin"
mkdir -p crypto-config/organizations/peerOrganizations/${ORG_NAME}/

export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/

  fabric-ca-client enroll -u https://admin:adminpw@${IP}:${PORT} --caname ca-${ORG_NAME} --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/${IP}-${PORT}-ca-${ORG_NAME}.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/${IP}-${PORT}-ca-${ORG_NAME}.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/${IP}-${PORT}-ca-${ORG_NAME}.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/${IP}-${PORT}-ca-${ORG_NAME}.pem
    OrganizationalUnitIdentifier: orderer" > "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/msp/config.yaml"

  echo "Registering peer0"
  set -x
  
  fabric-ca-client register --caname ca-${ORG_NAME} --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  fabric-ca-client register --caname ca-${ORG_NAME} --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  fabric-ca-client register --caname ca-${ORG_NAME} --id.name orderer0 --id.secret orderer0pw --id.type orderer --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  fabric-ca-client register --caname ca-${ORG_NAME} --id.name orderer1 --id.secret orderer1pw --id.type orderer --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-${ORG_NAME} --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  fabric-ca-client register --caname ca-${ORG_NAME} --id.name orderer2 --id.secret orderer2pw --id.type orderer --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null
  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-${ORG_NAME} --id.name ${ORG_NAME}admin --id.secret ${ORG_NAME}adminpw --id.type admin --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@${IP}:${PORT} --caname ca-${ORG_NAME} -M "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer0.${ORG_NAME}/msp" --csr.hosts peer0.${ORG_NAME} --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/msp/config.yaml" "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer0.${ORG_NAME}/msp/config.yaml"

  echo "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@${IP}:${PORT} --caname ca-${ORG_NAME} -M "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer0.${ORG_NAME}/tls" --enrollment.profile tls --csr.hosts peer0.${ORG_NAME} --csr.hosts ${IP} --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer0.${ORG_NAME}/tls/tlscacerts/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer0.${ORG_NAME}/tls/ca.crt"
  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer0.${ORG_NAME}/tls/signcerts/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer0.${ORG_NAME}/tls/server.crt"
  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer0.${ORG_NAME}/tls/keystore/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer0.${ORG_NAME}/tls/server.key"

  mkdir -p "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/msp/tlscacerts"
  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer0.${ORG_NAME}/tls/tlscacerts/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/tlsca"
  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer0.${ORG_NAME}/tls/tlscacerts/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/tlsca/tlsca.${ORG_NAME}-cert.pem"

  mkdir -p "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/ca"
  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer0.${ORG_NAME}/msp/cacerts/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/ca/ca.${ORG_NAME}-cert.pem"

  echo "Generating the peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@${IP}:${PORT} --caname ca-${ORG_NAME} -M "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer1.${ORG_NAME}/msp" --csr.hosts peer1.${ORG_NAME} --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/msp/config.yaml" "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer1.${ORG_NAME}/msp/config.yaml"

  echo "Generating the peer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@${IP}:${PORT} --caname ca-${ORG_NAME} -M "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer1.${ORG_NAME}/tls" --enrollment.profile tls --csr.hosts peer1.${ORG_NAME} --csr.hosts ${IP} --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer1.${ORG_NAME}/tls/tlscacerts/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer1.${ORG_NAME}/tls/ca.crt"
  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer1.${ORG_NAME}/tls/signcerts/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer1.${ORG_NAME}/tls/server.crt"
  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer1.${ORG_NAME}/tls/keystore/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/peers/peer1.${ORG_NAME}/tls/server.key"
  
  echo "Generating the orderer0 msp"
  set -x
  fabric-ca-client enroll -u https://orderer0:orderer0pw@${IP}:${PORT} --caname ca-${ORG_NAME} -M "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer0.${ORG_NAME}/msp" --csr.hosts orderer0.${ORG_NAME} --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/msp/config.yaml" "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer0.${ORG_NAME}/msp/config.yaml"

  echo "Generating the orderer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer0:orderer0pw@${IP}:${PORT} --caname ca-${ORG_NAME} -M "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer0.${ORG_NAME}/tls" --enrollment.profile tls --csr.hosts orderer0.${ORG_NAME} --csr.hosts ${IP} --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer0.${ORG_NAME}/tls/tlscacerts/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer0.${ORG_NAME}/tls/ca.crt"
  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer0.${ORG_NAME}/tls/signcerts/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer0.${ORG_NAME}/tls/server.crt"
  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer0.${ORG_NAME}/tls/keystore/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer0.${ORG_NAME}/tls/server.key"
  
  echo "Generating the orderer1 msp"
  set -x
  fabric-ca-client enroll -u https://orderer1:orderer1pw@${IP}:${PORT} --caname ca-${ORG_NAME} -M "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer1.${ORG_NAME}/msp" --csr.hosts orderer1.${ORG_NAME} --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/msp/config.yaml" "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer1.${ORG_NAME}/msp/config.yaml"

  echo "Generating the orderer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer1:orderer1pw@${IP}:${PORT} --caname ca-${ORG_NAME} -M "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer1.${ORG_NAME}/tls" --enrollment.profile tls --csr.hosts orderer1.${ORG_NAME} --csr.hosts ${IP} --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer1.${ORG_NAME}/tls/tlscacerts/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer1.${ORG_NAME}/tls/ca.crt"
  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer1.${ORG_NAME}/tls/signcerts/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer1.${ORG_NAME}/tls/server.crt"
  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer1.${ORG_NAME}/tls/keystore/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer1.${ORG_NAME}/tls/server.key"
  
  echo "Generating the orderer2 msp"
  set -x
  fabric-ca-client enroll -u https://orderer2:orderer2pw@${IP}:${PORT} --caname ca-${ORG_NAME} -M "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer2.${ORG_NAME}/msp" --csr.hosts orderer2.${ORG_NAME} --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/msp/config.yaml" "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer2.${ORG_NAME}/msp/config.yaml"

  echo "Generating the orderer2-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer2:orderer2pw@${IP}:${PORT} --caname ca-${ORG_NAME} -M "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer2.${ORG_NAME}/tls" --enrollment.profile tls --csr.hosts orderer2.${ORG_NAME} --csr.hosts ${IP} --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer2.${ORG_NAME}/tls/tlscacerts/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer2.${ORG_NAME}/tls/ca.crt"
  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer2.${ORG_NAME}/tls/signcerts/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer2.${ORG_NAME}/tls/server.crt"
  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer2.${ORG_NAME}/tls/keystore/"* "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/orderers/orderer2.${ORG_NAME}/tls/server.key"
  
  echo "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@${IP}:${PORT} --caname ca-${ORG_NAME} -M "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/users/User1@${ORG_NAME}/msp" --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/msp/config.yaml" "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/users/User1@${ORG_NAME}/msp/config.yaml"

  echo "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://${ORG_NAME}admin:${ORG_NAME}adminpw@${IP}:${PORT} --caname ca-${ORG_NAME} -M "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/users/Admin@${ORG_NAME}/msp" --tls.certfiles "${PWD}/ca-config/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/msp/config.yaml" "${PWD}/crypto-config/organizations/peerOrganizations/${ORG_NAME}/users/Admin@${ORG_NAME}/msp/config.yaml"
  cp -R ./crypto-config ./config/