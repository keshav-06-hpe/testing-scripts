#!/bin/bash

# Retrieve namespaces with istio-injection=enabled label
namespaces=$(kubectl get ns -l istio-injection=enabled -o jsonpath='{.items[*].metadata.name}')

# Perform rollout restart for deployments and statefulsets in each namespace
for namespace in $namespaces; do
  echo "**** Performing rollout restart for namespace: $namespace ****"
  kubectl rollout restart deployment -n $namespace
  kubectl rollout restart statefulset -n $namespace
  kubectl rollout restart daemonset -n $namespace
done

echo "Rollout restart completed for all istio-injection enabled namespaces."
