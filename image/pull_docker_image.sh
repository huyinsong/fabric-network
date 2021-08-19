#!/bin/bash
set -x
docker pull hyperledger/fabric-couchdb:latest
docker pull hyperledger/fabric-orderer:2.2.1
docker pull hyperledger/fabric-baseos:2.2
docker pull hyperledger/fabric-ca:1.4.9
docker pull hyperledger/fabric-ccenv:2.2
docker pull hyperledger/fabric-peer:2.2.1
docker pull gliderlabs/logspout:latest
set +x
