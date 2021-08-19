#!/bin/bash
#rm -rf ca-config/*
#rm -rf crypto-config/*
cp ./config/fabric-ca-server-config.yaml ./ca-config/
docker-compose -f ./docker/ca-server.yaml -p cnsw-ca up -d