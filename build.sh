#!/bin/bash

# add SSH key to clone private repo
SSH_KEY=$(cat ~/.ssh/id_rsa)
docker build --build-arg SSH_KEY="$SSH_KEY" --tag docker-zoobc-ledger .
# docker rmi -f $(docker images -q --filter label=stage=intermediate)

# docker build --tag docker-zoobc-ledger .
