#!/usr/bin/env bash
kubectl -n kcm-system get secret gcp-cluster-kubeconfig -o jsonpath='{.data.value}' | base64 -d > gcloud-kc.yaml
kubectl -n kcm-system get secret ec2-cluster-kubeconfig -o jsonpath='{.data.value}' | base64 -d > aws-kc.yaml
