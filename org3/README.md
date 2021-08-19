Fabric network opertion steps.

Step 1. Start CA for blockchain Organization by executing follow commond
./start-ca.sh

Step 2. Generate org's certificates.
run ./enroll.sh tcsworg localhost 9054

Step3. Set peer environment
run source ./setPeerEnv.sh tcsworg TCSWOrgMSP localhost:7151 peers peer0
Step4. Transfer cert to other org manager.
Transfer orderer0 and orderer1 tls root cert and server.crt to other org manager.

Step5. Sign update envelope which was transfered from other org manager.
peer channel signconfigtx -f ./channel-artifacts/config_update_in_envelope.pb

Step6. Run orderers with new genesis block
Wait for other org manager handles the new genesis block.
Put genesis.block which transfered by other org manager to channel-artifacts directory.
Run ./start-network.sh

Step7. Sign update envelope which was transfered from other org manager.
peer channel signconfigtx -f ./channel-artifacts/config_update_in_envelope.pb

Step 8. Add peer to application channel
Put mychannel.block to channel-artifacts directory.
run `peer channel join -b ./channel-artifacts/mychannel.block`
Step 9. Update anchor peer
run ./updateAnchorPeer.sh

step 10. Deploy chaincode
First copy chaincode package from other org.
Run following commond step by step to install and instantiate chaincode:
source ./setPeerEnv.sh tcsworg TCSWOrgMSP localhost:7251 peers peer0
peer lifecycle chaincode install basic.tar.gz
source ./setPeerEnv.sh tcsworg TCSWOrgMSP localhost:8251 peers peer1
peer lifecycle chaincode install basic.tar.gz
export CC_PACKAGE_ID=$(peer lifecycle chaincode queryinstalled |grep basic_1.0 |awk -F[\ ,] '{print $3}')
peer lifecycle chaincode approveformyorg -o localhost:7250 --ordererTLSHostnameOverride orderer0.tcsworg --channelID mychannel --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/crypto-config/organizations/peerOrganizations/tcsworg/orderers/orderer0.tcsworg/tls/ca.crt

peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile ${PWD}/crypto-config/organizations/peerOrganizations/tcsworg/orderers/orderer0.tcsworg/tls/ca.crt --output json

peer lifecycle chaincode commit -o localhost:7250 --ordererTLSHostnameOverride orderer0.tcsworg --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile ${PWD}/crypto-config/organizations/peerOrganizations/tcsworg/orderers/orderer0.tcsworg/tls/ca.crt --peerAddresses localhost:7251 --tlsRootCertFiles ${PWD}/crypto-config/organizations/peerOrganizations/tcsworg/peers/peer0.tcsworg/tls/ca.crt 

step 11. Invoke chaincode

peer chaincode invoke -o localhost:7250 --ordererTLSHostnameOverride orderer0.tcsworg --channelID mychannel --name basic --tls --cafile ${PWD}/crypto-config/organizations/peerOrganizations/tcsworg/orderers/orderer0.tcsworg/tls/ca.crt --peerAddresses localhost:7251 --tlsRootCertFiles ${PWD}/crypto-config/organizations/peerOrganizations/tcsworg/peers/peer0.tcsworg/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'

peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'



