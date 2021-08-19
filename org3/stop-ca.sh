#!/bin/bash
docker-compose -f ./docker/ca-server.yaml -p tcsw-ca down
rm -rf ca-config/*
rm -rf crypto-config/*
rm -rf config/crypto-config