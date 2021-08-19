#!/bin/bash
set -x
docker save hyperledger/fabric-couchdb:latest -o couchdb.tar.gz
docker save hyperledger/fabric-orderer:2.2.1 -o orderer.tar.gz
docker save hyperledger/fabric-baseos:2.2 -o baseos.tar.gz
docker save hyperledger/fabric-ca:1.4.9 -o ca.tar.gz
docker save hyperledger/fabric-ccenv:2.2 -o ccenv.tar.gz
docker save hyperledger/fabric-peer:2.2.1 -o peer.tar.gz
docker save gliderlabs/logspout:latest -o logspout.tar.gz
set +x
