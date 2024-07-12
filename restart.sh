#!/bin/bash

# List of namespaces
namespaces=(argo dvs hnc-system nexus pki-operator services slurm-operator spire tapms-operator uas vault)

# Loop through each namespace and perform a rollout restart for all deployments
for namespace in "${namespaces[@]}"; do
  echo "\n\n**** Performing rollout restart for namespace: $namespace ****"
  kubectl rollout restart all -n $namespace
done

echo "Rollout restart completed for all istio-injection enabled namespaces."
