#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <number_of_clusters>"
  exit 1
fi

N=$1
NAMESPACE="workshop"

TEMPLATE=$(cat <<'EOF'
apiVersion: kamaji.clastix.io/v1alpha1
kind: TenantControlPlane
metadata:
  name: $CLUSTER_NAME
  namespace: $NAMESPACE
spec:
  dataStore: default
  controlPlane:
    deployment:
      replicas: 1
    service:
      serviceType: LoadBalancer
  kubernetes:
    version: v1.30.2
    kubelet:
      cgroupfs: systemd
  networkProfile:
    port: $PORT
  addons:
    konnectivity:
      server:
        port: $KONN_PORT
EOF
)

echo "Ensuring namespace '$NAMESPACE' exists..."
kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"

for i in $(seq 1 "$N"); do
  export CLUSTER_NAME="cluster-$i"
  export PORT=$((8000 + i - 1))
  export KONN_PORT=$((8500 + i - 1))
  export NAMESPACE

  echo
  echo "--- Applying cluster $CLUSTER_NAME (network port: $PORT, konnectivity port: $KONN_PORT) in namespace $NAMESPACE ---"
  echo "$TEMPLATE" | envsubst | kubectl apply -f -
  echo "Cluster $CLUSTER_NAME applied successfully."
done

echo

echo "All $N clusters created successfully in namespace '$NAMESPACE'." 