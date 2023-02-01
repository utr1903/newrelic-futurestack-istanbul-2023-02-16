#!/bin/bash

#####################
### Set variables ###
#####################

repoName="futurestack-istanbul"
clusterName="mytestcluster"

# cert-manager
declare -A certmanager
certmanager["name"]="cert-manager"
certmanager["namespace"]="cert-manager"

# otel-operator
declare -A oteloperator
oteloperator["name"]="otel-operator"
oteloperator["namespace"]="monitoring"

# otel-collector
declare -A otelcollector
otelcollector["name"]="otel-collector"
otelcollector["namespace"]="monitoring"
otelcollector["mode"]="daemonset"

# nodeexporter
declare -A nodeexporter
nodeexporter["name"]="nodeexporter"
nodeexporter["namespace"]="monitoring"

# prometheus
declare -A prometheus
prometheus["name"]="prometheus"
prometheus["namespace"]="monitoring"

# mysql
declare -A mysql
mysql["name"]="mysql"
mysql["namespace"]="apps"
mysql["username"]="root"
mysql["password"]="verysecretpassword"
mysql["port"]=3306
mysql["database"]="futurestack"

# proxy
declare -A proxy
proxy["name"]="proxy-oss"
proxy["imageName"]="${repoName}:${proxy[name]}"
proxy["namespace"]="apps"
proxy["replicas"]=2
proxy["port"]=8080

# persistence
declare -A persistence
persistence["name"]="persistence-oss"
persistence["imageName"]="${repoName}:${persistence[name]}"
persistence["namespace"]="apps"
persistence["replicas"]=2
persistence["port"]=8080

####################
### Build & Push ###
####################

# proxy
docker build \
  --tag "${DOCKERHUB_NAME}/${proxy[imageName]}" \
  "../../apps/proxy/."
docker push "${DOCKERHUB_NAME}/${proxy[imageName]}"

# persistence
docker build \
  --tag "${DOCKERHUB_NAME}/${persistence[imageName]}" \
  "../../apps/persistence/."
docker push "${DOCKERHUB_NAME}/${persistence[imageName]}"

###################
### Deploy Helm ###
###################

# Add helm repos
helm repo add jetstack https://charts.jetstack.io
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo add newrelic-prometheus https://newrelic.github.io/newrelic-prometheus-configurator
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
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

# otel-collector
helm upgrade ${otelcollector[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace ${otelcollector[namespace]} \
  --set name=${otelcollector[name]} \
  --set mode=${otelcollector[mode]} \
  --set newrelicOtlpEndpoint="otlp.eu01.nr-data.net:4317" \
  --set newrelicLicenseKey=$NEWRELIC_LICENSE_KEY \
  "../helm/otelcollector"

# node-exporter
helm upgrade ${nodeexporter[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace ${nodeexporter[namespace]} \
  --set tolerations[0].effect="NoSchedule" \
  --set tolerations[0].operator="Exists" \
  "prometheus-community/prometheus-node-exporter"

# prometheus
helm upgrade ${prometheus[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace ${prometheus[namespace]} \
  --set cluster=$clusterName \
  --set licenseKey=$NEWRELIC_LICENSE_KEY \
  -f "../helm/prometheus/values.yaml" \
  "newrelic-prometheus/newrelic-prometheus-agent"

# mysql
helm upgrade ${mysql[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace=${mysql[namespace]} \
  --set auth.rootPassword=${mysql[password]} \
  --set auth.database=${mysql[database]} \
    "bitnami/mysql"

# proxy
helm upgrade ${proxy[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace=${proxy[namespace]} \
  --set dockerhubName=$DOCKERHUB_NAME \
  --set imageName=${proxy[imageName]} \
  --set imagePullPolicy="Always" \
  --set name=${proxy[name]} \
  --set replicas=${proxy[replicas]} \
  --set port=${proxy[port]} \
  --set endpoints.otelcollector="http://${otelcollector[name]}-collector.${otelcollector[namespace]}.svc.cluster.local:4317" \
  --set endpoints.persistence="http://${persistence[name]}.${persistence[namespace]}.svc.cluster.local:${persistence[port]}/persistence" \
  "../helm/proxy"

# persistence
helm upgrade ${persistence[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace=${persistence[namespace]} \
  --set dockerhubName=$DOCKERHUB_NAME \
  --set imageName=${persistence[imageName]} \
  --set imagePullPolicy="Always" \
  --set name=${persistence[name]} \
  --set replicas=${persistence[replicas]} \
  --set port=${persistence[port]} \
  --set endpoints.otelcollector="http://${otelcollector[name]}-collector.${otelcollector[namespace]}.svc.cluster.local:4317" \
  --set mysql.server="${mysql[name]}.${mysql[namespace]}.svc.cluster.local" \
  --set mysql.username=${mysql[username]} \
  --set mysql.password=${mysql[password]} \
  --set mysql.port=${mysql[port]} \
  --set mysql.database=${mysql[database]} \
  "../helm/persistence"
