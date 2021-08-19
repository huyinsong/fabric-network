#!/bin/bash
#rm -rf ca-config/*
#rm -rf crypto-config/*
docker-compose -f ./docker/bc-network.yaml -p sgsw-network up -d