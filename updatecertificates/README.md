# Start single organization blockchain network
## Step 1. Start CA for blockchain Organization by executing follow commond
* Run `./start-ca.sh`
## Step 2. Generate org's certificates.
* Run `./enroll.sh cnsworg localhost 7054`
## Step 3. Generate GenesisBlock.
* Run `source ./setPeerEnv.sh cnsworg CNSWOrgMSP localhost:7051 peers peer0`
* Run `./generate_block.sh GenesisBlock syschannel 1`
> Notice: 
`./generate_block profile` channelName type
>1. profile: You can find profile in configtx.yaml
>2. channelName: the blockchain network system channel name.
>3. Type: there are 2 types. 1: genesisblock 2:application channel block. You must set type as 1 or 2 when using this script.
## Step 4. Start up fabric network
Run `./start-network.sh`
## Step 5. Set peer environment
* Run `source ./setPeerEnv.sh cnsworg CNSWOrgMSP localhost:7051 peers peer0`
## Step 6. Generate application channel block
* Run `./generate_block.sh ChannelBlock mychannel 2`
## Step 7. Create application channel
* Run `peer channel create -o localhost:7050  --ordererTLSHostnameOverride orderer0.cnsworg -c mychannel -f ./channel-artifacts/mychannel.tx --outputBlock ./channel-artifacts/mychannel.block --tls --cafile ${PWD}/crypto-config/organizations/peerOrganizations/cnsworg/orderers/orderer0.cnsworg/tls/ca.crt`

## Step 8. Add peer0 and peer1 to application channel
* Run following commonds step by step:
    >* `peer channel join -b ./channel-artifacts/mychannel.block`
    >* `source ./setPeerEnv.sh cnsworg CNSWOrgMSP localhost:8051 peers peer1`
    >* `peer channel join -b ./channel-artifacts/mychannel.block`
## Step 9. Update anchor peer
* Run following commands step by step:
    >* `peer channel fetch config ./channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer0.cnsworg -c mychannel --tls --cafile ${PWD}/crypto-config/organizations/peerOrganizations/cnsworg/orderers/orderer0.cnsworg/tls/ca.crt`
    >* `configtxlator proto_decode --input ./channel-artifacts/config_block.pb --type common.Block --output ./channel-artifacts/config_block.json`
    >* `jq '.data.data[0].payload.data.config' ./channel-artifacts/config_block.json > ./channel-artifacts/config.json`
    >* `cp ./channel-artifacts/config.json ./channel-artifacts/config_copy.json`
    >* `jq '.channel_group.groups.Application.groups.CNSWOrgMSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.cnsworg","port": 7051}]},"version": "0"}}' ./channel-artifacts/config_copy.json > ./channel-artifacts/modified_config.json`
    >* `configtxlator proto_encode --input ./channel-artifacts/config.json --type common.Config --output ./channel-artifacts/config.pb`
    >* `configtxlator proto_encode --input ./channel-artifacts/modified_config.json --type common.Config --output ./channel-artifacts/modified_config.pb`
    >* `configtxlator compute_update --channel_id mychannel --original ./channel-artifacts/config.pb --updated ./channel-artifacts/modified_config.pb --output ./channel-artifacts/config_update.pb`
    >* `configtxlator proto_decode --input ./channel-artifacts/config_update.pb --type common.ConfigUpdate --output ./channel-artifacts/config_update.json`
    >* `echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat ./channel-artifacts/config_update.json)'}}}' | jq . > ./channel-artifacts/config_update_in_envelope.json`
    >* `configtxlator proto_encode --input ./channel-artifacts/config_update_in_envelope.json --type common.Envelope --output ./channel-artifacts/config_update_in_envelope.pb`
    >* `peer channel signconfigtx -f ./channel-artifacts/config_update_in_envelope.pb`
    >* `peer channel update -f channel-artifacts/config_update_in_envelope.pb -c mychannel -o localhost:7050  --ordererTLSHostnameOverride orderer0.cnsworg --tls --cafile ${PWD}/crypto-config/organizations/peerOrganizations/cnsworg/orderers/orderer0.cnsworg/tls/ca.crt`
## Step 10. Deploy chaincode
### Using following commands to initialize chaincode with vendor(Optional):
* GO111MODULE=on
* go mod init github.com/chaincodedir
* go mod vendor
### Install chaincode by running following commands step by step:

>* `source ./setPeerEnv.sh cnsworg CNSWOrgMSP localhost:7051 peers peer0`
>* `peer lifecycle chaincode package basic.tar.gz --path ./chaincode/asset-transfer-basic/chaincode-go/ --lang golang --label basic_1.0`
>* `peer lifecycle chaincode install basic.tar.gz`
>* `source ./setPeerEnv.sh cnsworg CNSWOrgMSP localhost:8051 peers peer1`
>* `peer lifecycle chaincode install basic.tar.gz`
>* `peer lifecycle chaincode queryinstalled`
>* `peer lifecycle chaincode queryinstalled |grep basic_1.0 |awk -F[\ ,] '{print $3}'`
>* `export CC_PACKAGE_ID=basic_1.0:0788b09dbb0681d835dad50a770a6f51aabdf53f0ad5da4135d776ad585ea48d`
>* `peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer0.cnsworg --channelID mychannel --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/crypto-config/organizations/peerOrganizations/cnsworg/orderers/orderer0.cnsworg/tls/ca.crt`
>* `peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile ${PWD}/crypto-config/organizations/peerOrganizations/cnsworg/orderers/orderer0.cnsworg/tls/ca.crt --output json`
>* `peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer0.cnsworg --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile ${PWD}/crypto-config/organizations/peerOrganizations/cnsworg/orderers/orderer0.cnsworg/tls/ca.crt --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/crypto-config/organizations/peerOrganizations/cnsworg/peers/peer0.cnsworg/tls/ca.crt`

## step 11. Invoke chaincode
Make sure that chaincode has successfully installed on peer and run following commands to invoke chaincode.
>* `peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer0.cnsworg --channelID mychannel --name basic --tls --cafile ${PWD}/crypto-config/organizations/peerOrganizations/cnsworg/orderers/orderer0.cnsworg/tls/ca.crt --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/crypto-config/organizations/peerOrganizations/cnsworg/peers/peer0.cnsworg/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'`
>* `peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'`

## Step 12 Update network. Add new orgs and orderers.

Get System channel configuration
>* Run `peer channel fetch config ./addOrderer/config_block.pb -o localhost:7050  --ordererTLSHostnameOverride orderer0.cnsworg -c syschannel --tls --cafile ./crypto-config/organizations/peerOrganizations/cnsworg/orderers/orderer0.cnsworg/tls/ca.crt`
>* Run `configtxlator proto_decode --input ./addOrderer/config_block.pb --type common.Block --output ./addOrderer/config_block.json`
>* Run `jq '.data.data[0].payload.data.config' ./addOrderer/config_block.json > ./addOrderer/config.json`
>* Run `cp ./addOrderer/config.json ./addOrderer/config_copy.json`

Modify config_copy.json. Add new OrdererMSP Info
>* Start up org2 ca server. Generate Org2 ca files.
>* Open config_copy.json and edit it with any json editor. Add new Orderer group info and Consortium info. Do not add consensters and Orderer address info. We need to put new orgs's orderer tls root ca in config_copy.json.
>* Run `cp ./addOrderer/config_copy.json ./addOrderer/modified_config.json`
>* Run `configtxlator proto_encode --input ./addOrderer/config.json --type common.Config --output ./addOrderer/original_config.pb`
>* Run `configtxlator proto_encode --input ./addOrderer/modified_config.json --type common.Config --output ./addOrderer/modified_config.pb`
>* Run `configtxlator compute_update --channel_id syschannel --original ./addOrderer/original_config.pb --updated ./addOrderer/modified_config.pb --output ./addOrderer/config_update.pb`
>* Run `configtxlator proto_decode --input ./addOrderer/config_update.pb --type common.ConfigUpdate --output ./addOrderer/config_update.json`
>* Run `echo "{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"syschannel\", \"type\":2}},\"data\":{\"config_update\":"$(cat addOrderer/config_update.json)"}}}" | jq . > ./addOrderer/config_update_in_envelope.json`
>* Run `configtxlator proto_encode --input ./addOrderer/config_update_in_envelope.json --type common.Envelope --output ./addOrderer/config_update_in_envelope.pb`
>* Run `peer channel signconfigtx -f ../org1/addOrderer/config_update_in_envelope.pb
peer channel update -f ./addOrderer/config_update_in_envelope.pb -c syschannel -o localhost:7050  --ordererTLSHostnameOverride orderer0.cnsworg --tls --cafile ${PWD}/crypto-config/organizations/peerOrganizations/cnsworg/orderers/orderer0.cnsworg/tls/ca.crt`

Add consenters
>* Run `peer channel fetch config ./addOrderer/config_block.pb -o localhost:7050  --ordererTLSHostnameOverride orderer0.cnsworg -c syschannel --tls --cafile ./crypto-config/organizations/peerOrganizations/cnsworg/orderers/orderer0.cnsworg/tls/ca.crt
>* Run `configtxlator proto_decode --input ./addOrderer/config_block.pb --type common.Block --output ./addOrderer/config_block.json
jq '.data.data[0].payload.data.config' ./addOrderer/config_block.json > ./addOrderer/config.json
cp ./addOrderer/config.json ./addOrderer/config_consenters.json

Modify config_consenters.json. Add new orderer add Info
>* Open config_copy.json and edit it with any json editor. Add new Orderer group info and Consortium info. Do not add consensters and Orderer address info. We need to put new orderers' tls server.crt in config_copy.json. Do not mismatch server.crt with orderer name. The orderers' server.crt are different with each other.
>* Run `cp ./addOrderer/config_consenters.json ./addOrderer/modified_config.json`
>* Run `configtxlator proto_encode --input ./addOrderer/config.json --type common.Config --output ./addOrderer/original_config.pb`
>* Run `configtxlator proto_encode --input ./addOrderer/modified_config.json --type common.Config --output ./addOrderer/modified_config.pb`
>* Run `configtxlator compute_update --channel_id syschannel --original ./addOrderer/original_config.pb --updated ./addOrderer/modified_config.pb --output ./addOrderer/config_update.pb`
>* Run `configtxlator proto_decode --input ./addOrderer/config_update.pb --type common.ConfigUpdate --output ./addOrderer/config_update.json`
>* Run `echo "{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"syschannel\", \"type\":2}},\"data\":{\"config_update\":"$(cat addOrderer/config_update.json)"}}}" | jq . > ./addOrderer/config_update_in_envelope.json`
>* Run `configtxlator proto_encode --input ./addOrderer/config_update_in_envelope.json --type common.Envelope --output ./addOrderer/config_update_in_envelope.pb`
>* Run `peer channel signconfigtx -f ../org1/addOrderer/config_update_in_envelope.pb`
>* Run `peer channel update -f ./addOrderer/config_update_in_envelope.pb -c syschannel -o localhost:7050  --ordererTLSHostnameOverride orderer0.cnsworg --tls --cafile ${PWD}/crypto-config/organizations/peerOrganizations/cnsworg/orderers/orderer0.cnsworg/tls/ca.crt`

Add org to application channel
>* Run `peer channel fetch config ./addChannel/config_block.pb -o localhost:7050  --ordererTLSHostnameOverride orderer0.cnsworg -c mychannel --tls --cafile ./crypto-config/organizations/peerOrganizations/cnsworg/orderers/orderer0.cnsworg/tls/ca.crt
>* Run `configtxlator proto_decode --input ./addChannel/config_block.pb --type common.Block --output ./addChannel/config_block.json
>* Run `jq '.data.data[0].payload.data.config' ./addChannel/config_block.json > ./addChannel/config.json
>* Run `cp ./addChannel/config.json ./addChannel/config_copy.json

Modify config_copy.json. Add new Org Info
>* Run `cp ./addChannel/config_copy.json ./addChannel/modified_config.json
>* Run `configtxlator proto_encode --input ./addChannel/config.json --type common.Config --output ./addChannel/original_config.pb
>* Run `configtxlator proto_encode --input ./addChannel/modified_config.json --type common.Config --output ./addChannel/modified_config.pb
>* Run `configtxlator compute_update --channel_id mychannel --original ./addChannel/original_config.pb --updated ./addChannel/modified_config.pb --output ./addChannel/config_update.pb
>* Run `configtxlator proto_decode --input ./addChannel/config_update.pb --type common.ConfigUpdate --output ./addChannel/config_update.json
>* Run `echo "{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"mychannel\", \"type\":2}},\"data\":{\"config_update\":"$(cat addChannel/config_update.json)"}}}" | jq . > ./addChannel/config_update_in_envelope.json
>* Run `configtxlator proto_encode --input ./addChannel/config_update_in_envelope.json --type common.Envelope --output ./addChannel/config_update_in_envelope.pb
>* Run `peer channel signconfigtx -f ../org1/addChannel/config_update_in_envelope.pb
peer channel update -f ./addChannel/config_update_in_envelope.pb -c mychannel -o localhost:7050  --ordererTLSHostnameOverride orderer0.cnsworg --tls --cafile ${PWD}/crypto-config/organizations/peerOrganizations/cnsworg/orderers/orderer0.cnsworg/tls/ca.crt

Add consenters to application channel
>* Run `peer channel fetch config ./addChannel/config_block.pb -o localhost:7050  --ordererTLSHostnameOverride orderer0.cnsworg -c mychannel --tls --cafile ./crypto-config/organizations/peerOrganizations/cnsworg/orderers/orderer0.cnsworg/tls/ca.crt
>* Run `configtxlator proto_decode --input ./addChannel/config_block.pb --type common.Block --output ./addChannel/config_block.json
>* Run `jq '.data.data[0].payload.data.config' ./addChannel/config_block.json > ./addChannel/config.json
>* Run `cp ./addChannel/config.json ./addChannel/config_consenters.json

Modify config_consenters.json. Add new orderer add Info
>* Run `cp ./addChannel/config_consenters.json ./addChannel/modified_config.json
>* Run `configtxlator proto_encode --input ./addChannel/config.json --type common.Config --output ./addChannel/original_config.pb
>* Run `configtxlator proto_encode --input ./addChannel/modified_config.json --type common.Config --output ./addChannel/modified_config.pb
>* Run `configtxlator compute_update --channel_id mychannel --original ./addChannel/original_config.pb --updated ./addChannel/modified_config.pb --output ./addChannel/config_update.pb
>* Run `configtxlator proto_decode --input ./addChannel/config_update.pb --type common.ConfigUpdate --output ./addChannel/config_update.json
>* Run `echo "{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"mychannel\", \"type\":2}},\"data\":{\"config_update\":"$(cat addChannel/config_update.json)"}}}" | jq . > ./addChannel/config_update_in_envelope.json
>* Run `configtxlator proto_encode --input ./addChannel/config_update_in_envelope.json --type common.Envelope --output ./addChannel/config_update_in_envelope.pb
>* Run `peer channel signconfigtx -f ../org1/addChannel/config_update_in_envelope.pb
>* Run `peer channel update -f ./addChannel/config_update_in_envelope.pb -c mychannel -o localhost:7050  --ordererTLSHostnameOverride orderer0.cnsworg --tls --cafile ${PWD}/crypto-config/organizations/peerOrganizations/cnsworg/orderers/orderer0.cnsworg/tls/ca.crt

## Step 13. add new peer to application channel

Run `peer channel fetch 0 ./addChannel/mychannel.block -o localhost:7050  --ordererTLSHostnameOverride orderer0.cnsworg -c mychannel --tls --cafile ./crypto-config/organizations/peerOrganizations/cnsworg/orderers/orderer0.cnsworg/tls/ca.crt`

> Notice: Using command above to get the genesis block of application channel. Pass the genesis block to new org manager. Then run command to join peer.


