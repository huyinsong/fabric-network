#!/bin/bash
docker-compose -f ./docker/bc-network.yaml -p tcsw-network down
rm -rf docker/data/*
rm -rf crypto-config/*