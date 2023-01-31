#!/bin/bash

#####################
### Set variables ###
#####################

repoName="futurestack-istanbul"

# proxy
declare -A proxy
proxy["name"]="proxy"
proxy["tag"]="oss-proxy"
proxy["imageName"]="${repoName}:oss-${proxy[name]}"
proxy["namespace"]="apps"
proxy["replicas"]=2
proxy["port"]=8080

####################
### Build & Push ###
####################

# proxy
docker build \
  --tag "${DOCKERHUB_NAME}/${proxy[imageName]}" \
  "../../apps/proxy/."
docker push "${DOCKERHUB_NAME}/${proxy[imageName]}"

###################
### Deploy Helm ###
###################

# proxy
helm upgrade ${proxy[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --set dockerhubName=$DOCKERHUB_NAME \
  --set imageName=${proxy[imageName]} \
  --set name=${proxy[name]} \
  --set namespace=${proxy[namespace]} \
  --set replicas=${proxy[replicas]} \
  --set port=${proxy[port]} \
  --set otelServiceName=${proxy[name]} \
  --set otelExporterOtlpEndpoint=${otelcollector[grpcEndpoint]} \
  "../helm/proxy"
