#!/bin/bash

# Create Kind Cluster with one worker node & additional ports mapping
cat <<EOF | kind create cluster --name mycluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 30080
    hostPort: 80
    protocol: TCP
  - containerPort: 30443
    hostPort: 443
    protocol: TCP
networking:
  apiServerAddress: "172.16.0.65"
EOF

echo "Kind cluster created"

# Add Helm repository containing nginx-ingress controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Update local helm repositories cache
helm repo update

# Deploy Ingress NGINX Controller
helm upgrade --install ingress-nginx ingress-nginx \
--repo https://kubernetes.github.io/ingress-nginx \
--namespace ingress-nginx \
--create-namespace \
--set controller.metrics.enabled=true \
--set controller.service.type=NodePort \
--set controller.service.nodePorts.http=30080 \
--set controller.service.nodePorts.https=30443 \
--set-string controller.podAnnotations."prometheus\.io/scrape"="true" \
--set-string controller.podAnnotations."prometheus\.io/port"="10254"


echo "NGINX Ingress deployed"

# Deploy prom
kubectl apply --kustomize github.com/kubernetes/ingress-nginx/deploy/prometheus/