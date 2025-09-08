#!/bin/sh
helm install kcm oci://ghcr.io/k0rdent/kcm/charts/kcm --version 1.3.0 -n kcm-system --create-namespace
