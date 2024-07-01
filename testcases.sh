#!/bin/bash

# Get pods in the istio-operator namespace
kubectl get pods -n istio-operator

# Get pods in the istio-system namespace
kubectl get pods -n istio-system

# Get pods in the services namespace filtered by keycloak
kubectl get pods -n services | grep keycloak

# Get kiali pods across all namespaces
kubectl get pods -A | grep kiali

# Get cronjobs in the services namespace
kubectl get cronjob -n services

# Get the image name of the istio-operator deployment in the istio-operator namespace
kubectl -n istio-system get pods -l "name=istio-operator" -o json | jq -r '.items[].spec.containers[] | select(.name == "istio-operator") | .image'

# Get the image name of the istiod deployment in the istio-system namespace
kubectl -n istio-system get pods -l "istio=pilot" -o json | jq -r '.items[].spec.containers[] | select(.name == "discovery") | .image'

# Get the image name of the istio-ingressgateway deployment in the istio-system namespace
kubectl -n istio-system get pods -l "istio=ingressgateway" -o json | jq -r '.items[].spec.containers[] | select(.name == "istio-proxy") | .image'

# Get the image name of the istio-ingressgateway-customer-admin deployment in the istio-system namespace
kubectl -n istio-system get pods -l "istio=ingressgateway-customer-admin" -o json | jq -r '.items[] | select(.spec.containers[].name == "istio-proxy") | "\(.metadata.name) | \(.status.phase) | \(.spec.containers[] | select(.name == "istio-proxy") | .image)"'

# Get the image name of the istio-ingressgateway-customer-user deployment in the istio-system namespace
kubectl -n istio-system get pods -l "istio=ingressgateway-customer-user" -o json | jq -r '.items[] | select(.spec.containers[].name == "istio-proxy") | "\(.metadata.name) | \(.status.phase) | \(.spec.containers[] | select(.name == "istio-proxy") | .image)"'

# Get the image name of the istio-ingressgateway-hmn deployment in the istio-system namespace
kubectl -n istio-system get pods -l "istio=ingressgateway-hmn" -o json | jq -r '.items[] | select(.spec.containers[].name == "istio-proxy") | "\(.metadata.name) | \(.status.phase) | \(.spec.containers[] | select(.name == "istio-proxy") | .image)"'

# Get the image name of the cray-keycloak-0 deployment in the services namespace
kubectl -n services get pods -l "app.kubernetes.io/name=keycloak" -o json | jq -r '.items[].spec.containers[] | select(.name == "istio-proxy") | .image'

# Get the image name of the kiali deployment in the operators namespace
kubectl get deployment -n operators cray-kiali-kiali-operator-oyaml | grep image

# Get the image name of the kiali deployment in the istio-system namespace
kubectl get deployment -n istio-system kiali -oyaml | grep image

# Get Istio service for Kiali
kubectl -n istio-system get sve kiali

# Port forward the Kiali service (replace with your desired port)
kubectl port-forward svc/kiali 8080:20001 -n istio-system

# Verify if cer-manager is deployed
kubectl get pods --namespace cert-manager

# Checking via helm
helm ls -n cert-manager
