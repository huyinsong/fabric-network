#!/bin/bash
set -x
docker load -i couchdb.tar.gz
docker load -i orderer.tar.gz
docker load -i baseos.tar.gz
docker load -i ca.tar.gz
docker load -i ccenv.tar.gz
docker load -i peer.tar.gz
docker load -i logspout.tar.gz
set +x