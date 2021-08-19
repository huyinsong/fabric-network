#!/bin/bash
docker-compose -f ./docker/bc-network.yaml -p sgsw-network down
rm -rf docker/data/*
rm -rf crypto-config/*