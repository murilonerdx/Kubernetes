#!/bin/bash

# Configurar Prometheus e Grafana
kubectl apply -f prometheus-config.yaml

# Configurar Cert-Manager
kubectl apply -f issuer.yaml

# Configurar o serviço LoadBalancer
kubectl apply -f service.yaml

# Configurar Horizontal Pod Autoscaler
kubectl apply -f hpa.yaml

# Configurar Ingress com TLS
kubectl apply -f ingress-tls.yaml

# Configurar ConfigMap
kubectl apply -f configmap.yaml

# Configurar Secret
kubectl apply -f secret.yaml
