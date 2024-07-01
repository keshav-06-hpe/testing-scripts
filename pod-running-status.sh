#!/bin/bash
# This script is combied with first 5 testcases made to check the status of pods if they are running properly or not and fetch the IPs.
# Define arrays to store results
not_running_pods=()

# Function to check pod status
check_pods() {
  namespace=$1
  label=$2
  grep_pattern=$3

  if [ -z "$label" ]; then
    result=$(kubectl get pods -n $namespace -o jsonpath="{range .items[*]}{.metadata.name}{\"|\"}{.status.phase}{\"|\"}{.status.podIP}{\"\n\"}{end}")
  else
    result=$(kubectl get pods -n $namespace -l $label -o jsonpath="{range .items[*]}{.metadata.name}{\"|\"}{.status.phase}{\"|\"}{.status.podIP}{\"\n\"}{end}")
  fi

  if [ -n "$grep_pattern" ]; then
    result=$(echo "$result" | grep "$grep_pattern")
  fi

  echo "$result"

  while IFS= read -r line; do
    pod_name=$(echo $line | cut -d'|' -f1)
    pod_status=$(echo $line | cut -d'|' -f2)
    pod_ip=$(echo $line | cut -d'|' -f3)
    if [[ $pod_status == "Pending" ]]; then
      not_running_pods+=("$namespace | $pod_name | $pod_status | $pod_ip")
    fi
  done <<< "$result"
}

# Print header
print_header() {
  printf "%-30s %-15s %-15s\n" "Pod Name" "Status" "Pod IP"
  printf "%-30s %-15s %-15s\n" "--------" "------" "------"
}

# Print pod details
print_pod_details() {
  while IFS= read -r line; do
    pod_name=$(echo $line | cut -d'|' -f1)
    pod_status=$(echo $line | cut -d'|' -f2)
    pod_ip=$(echo $line | cut -d'|' -f3)
    printf "%-30s %-15s %-15s\n" "$pod_name" "$pod_status" "$pod_ip"
  done <<< "$1"
}

# Check Istio Operator namespace pods
echo "Checking Istio Operator namespace pods..."
print_header
check_pods "istio-operator" "" ""
print_pod_details "$result"

# Check Istio System namespace pods
echo -e "\nChecking Istio System namespace pods..."
print_header
check_pods "istio-system" "" ""
print_pod_details "$result"

# Check Services namespace pods with Keycloak
echo -e "\nChecking Services namespace pods with Keycloak..."
print_header
check_pods "services" "" "keycloak"
print_pod_details "$result"

# Check all namespaces for Kiali
echo -e "\nChecking all namespaces for Kiali..."
print_header
kiali_result=$(kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"|"}{.metadata.name}{"|"}{.status.phase}{"|"}{.status.podIP}{"\n"}{end}' | grep kiali)
print_pod_details "$kiali_result"

while IFS= read -r line; do
  namespace=$(echo $line | cut -d'|' -f1)
  pod_name=$(echo $line | cut -d'|' -f2)
  pod_status=$(echo $line | cut -d'|' -f3)
  pod_ip=$(echo $line | cut -d'|' -f4)
  if [[ $pod_status == "Pending" ]]; then
    not_running_pods+=("$namespace | $pod_name | $pod_status | $pod_ip")
  fi
done <<< "$kiali_result"

# Check CronJobs in Services namespace
echo -e "\nChecking CronJobs in Services namespace..."
cronjobs=$(kubectl get cronjob -n services -o jsonpath='{range .items[*]}{"Name: "}{.metadata.name}{"\nSchedule: "}{.spec.schedule}{"\nConcurrency Policy: "}{.spec.concurrencyPolicy}{"\n"}{end}')
echo "$cronjobs"

# Print pods that are not running
if [ ${#not_running_pods[@]} -eq 0 ]; then
  echo -e "\nAll pods are running."
else
  echo -e "\nThe following pods are not running (Pending):"
  printf "%-15s %-30s %-15s %-15s\n" "Namespace" "Pod Name" "Status" "Pod IP"
  printf "%-15s %-30s %-15s %-15s\n" "---------" "--------" "------" "------"
  for pod in "${not_running_pods[@]}"; do
    namespace=$(echo $pod | cut -d'|' -f1)
    pod_name=$(echo $pod | cut -d'|' -f2)
    pod_status=$(echo $pod | cut -d'|' -f3)
    pod_ip=$(echo $pod | cut -d'|' -f4)
    printf "%-15s %-30s %-15s %-15s\n" "$namespace" "$pod_name" "$pod_status" "$pod_ip"
  done
fi


# Developed this as part of testing istio v1.19.10

# Overall commands covered:
# 1. kubectl get pods -n istio-operator
# 2. kubectl get pods -n istio-system
# 3. kubectl get pods -n services | grep keycloak
# 4. kubectl get pods -A | grep kiali
# 5. kubectl get cronjob -n services
