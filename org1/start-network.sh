#!/bin/bash
#rm -rf ca-config/*
#rm -rf crypto-config/*
docker-compose -f ./docker/bc-network.yaml -p cnsw-network up -d