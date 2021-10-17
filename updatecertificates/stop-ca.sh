#!/bin/bash
docker-compose -f ./docker/ca-server.yaml -p update-ca down
rm -rf ca-config/*