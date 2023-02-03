#!/bin/bash

#####################
### Set variables ###
#####################

repoName="futurestack-istanbul"
clusterName="mytestclusternr"

# nribundle
declare -A nribundle
nribundle["name"]="nri-bundle"
nribundle["namespace"]="monitoring"
nribundle["privileged"]=true
nribundle["lowDataMode"]=false
nribundle["ksm"]=true
nribundle["kubeEvents"]=true
nribundle["logging"]=true

# kafka
declare -A kafka
kafka["name"]="kafka"
kafka["namespace"]="apps"

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
proxy["name"]="proxy-nr"
proxy["imageName"]="${repoName}:${proxy[name]}"
proxy["namespace"]="apps"
proxy["replicas"]=2
proxy["port"]=8080

# persistence
declare -A persistence
persistence["name"]="persistence-nr"
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
helm repo add newrelic https://helm-charts.newrelic.com
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# nribundle
helm upgrade ${nribundle[name]} \
  --install \
  --wait \
  --debug \
  --set global.licenseKey=$NEWRELIC_LICENSE_KEY \
  --set global.cluster=$clusterName \
  --create-namespace \
  --namespace=${nribundle[namespace]} \
  --set newrelic-infrastructure.privileged=${nribundle[privileged]} \
  --set global.lowDataMode=${nribundle[lowDataMode]} \
  --set ksm.enabled=${nribundle[ksm]} \
  --set kubeEvents.enabled=${nribundle[kubeEvents]} \
  --set logging.enabled=${nribundle[logging]} \
  newrelic/nri-bundle

# kafka
helm upgrade ${kafka[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace=${kafka[namespace]} \
  "bitnami/kafka"

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
  --set kafka.address="${kafka[name]}-0.${kafka[name]}-headless.${kafka[namespace]}.svc.cluster.local:9092" \
  --set kafka.topic="create" \
  --set newrelic.appName=${proxy[name]} \
  --set newrelic.licenseKey=$NEWRELIC_LICENSE_KEY \
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
  --set kafka.address="${kafka[name]}.${kafka[namespace]}.svc.cluster.local:9092" \
  --set kafka.topic="create" \
  --set kafka.groupId=${persistence[name]} \
  --set newrelic.appName=${persistence[name]} \
  --set newrelic.licenseKey=$NEWRELIC_LICENSE_KEY \
  --set mysql.server="${mysql[name]}.${mysql[namespace]}.svc.cluster.local" \
  --set mysql.username=${mysql[username]} \
  --set mysql.password=${mysql[password]} \
  --set mysql.port=${mysql[port]} \
  --set mysql.database=${mysql[database]} \
  "../helm/persistence"
