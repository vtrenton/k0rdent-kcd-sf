#!/bin/sh
helm upgrade --install argo-cd oci://ghcr.io/k0rdent/catalog/charts/kgst --set "chart=argo-cd:7.8.0" -n kcm-system
helm upgrade --install ingress-nginx oci://ghcr.io/k0rdent/catalog/charts/kgst --set "chart=ingress-nginx:4.13.0" -n kcm-system
helm upgrade --install kube-prometheus-stack oci://ghcr.io/k0rdent/catalog/charts/kgst --set "chart=kube-prometheus-stack:72.6.2" -n kcm-system
helm upgrade --install kyverno oci://ghcr.io/k0rdent/catalog/charts/kgst --set "chart=kyverno:3.4.4" -n kcm-system
echo "get your service templates from the k0rdent catalog: https://catalog.k0rdent.io/latest/"
