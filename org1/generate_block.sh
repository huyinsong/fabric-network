#!/bin/bash
if [[ $# -ge 3 ]]; then
    PROFILE_NAME=$1
    CHANEL_NAME=$2
else
    echo "Usage: ./generate-block.sh prifile channel isGenesisBlock"
    exit 1
fi
if [[ $3 -eq 1 ]]; then 
    configtxgen -profile ${PROFILE_NAME} -outputBlock ./channel-artifacts/${CHANEL_NAME}.block -channelID ${CHANEL_NAME}
else 
    configtxgen -profile ${PROFILE_NAME} -outputCreateChannelTx ./channel-artifacts/${CHANEL_NAME}.tx -channelID ${CHANEL_NAME}
fi
