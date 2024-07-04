#!/bin/bash
# Gitlab requires PostgreSQL
sudo apt-get -y install postgresql
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm install my-release oci://registry-1.docker.io/bitnamicharts/postgresql
# DNS: my-release-postgresql.default.svc.cluster.local
# PORT: 5432
helm install my-release-redis oci://registry-1.docker.io/bitnamicharts/redis
helm upgrade --install gitlab gitlab/gitlab \
  --timeout 600s \
  --set global.hosts.domain=practice.com \
  --set global.hosts.externalIP=172.16.0.1 \
  --set global.ingress.configureCertmanager=false