#!/bin/bash
set -e
function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        template/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        template/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

if [[ $# -ge 3 ]]; then
    ORG_NAME=$1
    P0PORT=$2
    CAPORT=$3
else
    echo "Usage: ./generate-ccp.sh orgname P0POrt P1Port"
    exit 1
fi
set -x

PEERPEM=crypto-config/organizations/peerOrganizations/${ORG_NAME}/tlsca/tlsca.${ORG_NAME}-cert.pem
CAPEM=crypto-config/organizations/peerOrganizations/${ORG_NAME}/ca/ca.${ORG_NAME}-cert.pem

echo "$(json_ccp $ORG_NAME $P0PORT $CAPORT $PEERPEM $CAPEM)" > crypto-config/organizations/peerOrganizations/${ORG_NAME}/connection-${ORG_NAME}.json
echo "$(yaml_ccp $ORG_NAME $P0PORT $CAPORT $PEERPEM $CAPEM)" > crypto-config/organizations/peerOrganizations/${ORG_NAME}/connection-${ORG_NAME}.yaml
{ set +x; } 2>/dev/null
