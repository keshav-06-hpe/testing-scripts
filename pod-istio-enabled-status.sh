#!/bin/bash

# Define a list of namespaces (change or add as needed)
namespaces=(argo dvs hnc-system nexus pki-operator services slurm-operator spire tapms-operator uas vault)

# Loop through each namespace
for namespace in "${namespaces[@]}"; do
  echo "** Namespace: $namespace **"

  # Loop through each pod name retrieved using get pods
  for pod_name in $(kubectl get pods -n "$namespace" -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'); do
    # Get pod status for each pod name using separate kubectl call
    pod_status=$(kubectl get pod -n "$namespace" "$pod_name" -o go-template='{{.status.phase}}')

    # Extract the container image using kubectl get pod -o jsonpath
    image=$(kubectl get pod -n "$namespace" "$pod_name" -o jsonpath='{.spec.containers[*].image}')

    # Check if the image name contains "istio" (adjust if your Istio image name pattern differs)
    if [[ "$image" =~ istio ]]; then
      echo "Pod: $pod_name - Status: $pod_status - Istio Image: $image"
    fi
  done

  echo ""  # Add an empty line between namespaces
done
