#!/bin/bash

###################
### Infra Setup ###
###################

kind create cluster \
  --name futurestack-oss \
  --config ./helpers/kind-config.yaml
  # --image=kindest/node:v1.24.0
