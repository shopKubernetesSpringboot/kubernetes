#!/bin/bash
namespace='default'
echo "Using namespace=$namespace"

ingress() {
  echo "Ingress delete and create..."
  kubectl delete ingress shop-ingress
  kubectl create -f ingressDeploy.yml
}

backend() {
#  kubectl delete all --all
  echo "Backend delete and create..."
  deletePods 'product-pod|cart.*'
  deleteServices 'product-svc|cart.*'
  kubectl create -f productBackendDeploy.yml
  kubectl create -f cartBackendDeploy.yml
}

cart() {
  echo "Cart delete and create..."
  deletePods 'cart.*'
  deleteServices 'cart.*'
  kubectl create -f cartBackendDeploy.yml
}

product() {
  echo "Product delete and create..."
  deletePods 'product-pod'
  deleteServices 'product-svc'
  kubectl create -f productBackendDeploy.yml
}

mongo() {
  echo "Mongo delete and create..."
  deletePods '.*mongo.*'
  deleteServices '.*mongo.*'
  kubectl create -f mongoDeploy.yml
}

deletePodsAndSvc() {
  deletePods $1
  deleteServices $1
}

deletePods() { # 'pattern1|pattern2'
  kubectl get pods -n $namespace --no-headers=true | awk -v pat="$1" '//$0~pat{print $1}' | xargs  kubectl delete -n $namespace pod
}
deleteServices() { # 'pattern1|pattern2'
  kubectl get svc -n $namespace --no-headers=true | awk -v pat="$1" '//$0~pat{print $1}' | xargs  kubectl delete -n $namespace svc
}


if [ "$1" == "" ]; then
  echo "./publish.sh all|ingress|backend|product|cart|mongo"
else
#  set -o xtrace
  cd "$(dirname "$0")"
  case "$1" in
  "all")
    echo "Redeploying all..."
    mongo
    ingress
    backend
    ;;
  "ingress")
    echo "Redeploying ingress..."
    ingress
    ;;
  "backend")
    backend
    ;;
  "product")
    product
    ;;
  "cart")
    cart
    ;;
  "mongo")
    mongo
    ;;
  esac
  cd -
fi
