#!/usr/bin/env bash
kubectl -n kcm-system get secret my-gcp-cluster-kubeconfig -o jsonpath='{.data.value}' | base64 -d > downstream-kc.yaml
