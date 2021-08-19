#!/bin/bash
peer channel fetch config ./channel-artifacts/config_block.pb -o localhost:7150 --ordererTLSHostnameOverride orderer0.sgsworg -c mychannel --tls --cafile ${PWD}/crypto-config/organizations/peerOrganizations/sgsworg/orderers/orderer0.sgsworg/tls/ca.crt
configtxlator proto_decode --input ./channel-artifacts/config_block.pb --type common.Block --output ./channel-artifacts/config_block.json
jq '.data.data[0].payload.data.config' ./channel-artifacts/config_block.json > ./channel-artifacts/config.json
cp ./channel-artifacts/config.json ./channel-artifacts/config_copy.json
jq '.channel_group.groups.Application.groups.SGSWOrgMSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.sgsworg","port": 7151}]},"version": "0"}}' ./channel-artifacts/config_copy.json > ./channel-artifacts/modified_config.json
configtxlator proto_encode --input ./channel-artifacts/config.json --type common.Config --output ./channel-artifacts/config.pb
configtxlator proto_encode --input ./channel-artifacts/modified_config.json --type common.Config --output ./channel-artifacts/modified_config.pb
configtxlator compute_update --channel_id mychannel --original ./channel-artifacts/config.pb --updated ./channel-artifacts/modified_config.pb --output ./channel-artifacts/config_update.pb
configtxlator proto_decode --input ./channel-artifacts/config_update.pb --type common.ConfigUpdate --output ./channel-artifacts/config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat ./channel-artifacts/config_update.json)'}}}' | jq . > ./channel-artifacts/config_update_in_envelope.json
configtxlator proto_encode --input ./channel-artifacts/config_update_in_envelope.json --type common.Envelope --output ./channel-artifacts/config_update_in_envelope.pb
peer channel update -f channel-artifacts/config_update_in_envelope.pb -c mychannel -o localhost:7150  --ordererTLSHostnameOverride orderer0.sgsworg --tls --cafile ${PWD}/crypto-config/organizations/peerOrganizations/sgsworg/orderers/orderer0.sgsworg/tls/ca.crt