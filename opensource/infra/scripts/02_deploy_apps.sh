#!/bin/bash

#####################
### Set variables ###
#####################

repoName="futurestack-istanbul"

# cert-manager
declare -A certmanager
certmanager["name"]="cert-manager"
certmanager["namespace"]="cert-manager"

# otel-operator
declare -A oteloperator
oteloperator["name"]="otel-operator"
oteloperator["namespace"]="monitoring"

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

# # proxy
# docker build \
#   --tag "${DOCKERHUB_NAME}/${proxy[imageName]}" \
#   "../../apps/proxy/."
# docker push "${DOCKERHUB_NAME}/${proxy[imageName]}"

###################
### Deploy Helm ###
###################

# Add helm repos
helm repo add jetstack https://charts.jetstack.io
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

# cert-manager
helm upgrade ${certmanager[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace ${certmanager[namespace]} \
  --version v1.11.0 \
  --set installCRDs=true \
  "jetstack/cert-manager"

# otel-operator
helm upgrade ${oteloperator[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace ${oteloperator[namespace]} \
  "open-telemetry/opentelemetry-operator"

# # proxy
# helm upgrade ${proxy[name]} \
#   --install \
#   --wait \
#   --debug \
#   --create-namespace \
#   --set dockerhubName=$DOCKERHUB_NAME \
#   --set imageName=${proxy[imageName]} \
#   --set name=${proxy[name]} \
#   --set namespace=${proxy[namespace]} \
#   --set replicas=${proxy[replicas]} \
#   --set port=${proxy[port]} \
#   --set otelServiceName=${proxy[name]} \
#   --set otelExporterOtlpEndpoint=${otelcollector[grpcEndpoint]} \
#   "../helm/proxy"
