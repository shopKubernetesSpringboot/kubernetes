# Kubernetes

## Dockerhub

First steps:
- build projects (see respective readme's)
- create repositories in [dockerHub](https://hub.docker.com/repository/create):  `shop-cart`, `shop-product` & `shop-product-mongo` 

```shell script
docker login
docker tag techtests/shopcart:latest davidgfolch/shop-cart:latest
docker tag techtests/shopproduct:latest davidgfolch/shop-product:latest
docker tag mongo:latest davidgfolch/shop-product-mongo:latest
docker push davidgfolch/shop-cart
docker push davidgfolch/shop-product
docker push davidgfolch/shop-product-mongo
```

## Minikube setup
Enable [ingress addon](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/) on minikube,
 or see the generic [documentation for other platforms](https://kubernetes.github.io/ingress-nginx/deploy/)

    minikube addons enable ingress
    kubectl get pods -n kube-system

## Deploy on kubernetes

```shell script
kubectl delete all --all
kubectl delete ingress shop-ingress

kubectl create -f deployment.yml
# or
kubectl apply -f deployment.yml
```

Examine application deployment:
```shell script
kubectl get all
kubectl get ingress
kubectl describe service shop
kubectl describe pod shop-product
kubectl describe ingress shop-ingress

# see logs
kubectl logs --follow shop-cart
kubectl logs --follow shop-product
kubectl logs --follow shop-product-mongo

# execute command in container
kubectl exec -it shop-product-mongo -- WhatEverLlinuxCommand
# debugging ingress
kubectl get pods -n kube-system
kubectl logs --follow nginx-ingress-controller-6fc5bcc8c9-bcmb9 -n kube-system


minikube dashboard
```

### Debuging nginx ingress

    kubectl get pods -n kube-system
    kubectl get deployment -n kube-system nginx-ingress-controller -o yaml > nginx.tmp.yaml
    nano nginx.tmp.yaml
        spec:
          containers:
          - args:
            - --v=5
    kubectl apply -f nginx.tmp.yaml -n kube-system

## Mongo data init

Dump from existing data
    
    #dump (binary)
    kubectl exec -it product-mongo-pod -- sh -c 'exec mongodump -u admin -p password --authenticationDatabase=admin -d productDb --archive' > mongo-dump-all-collections.archive
    #export (json format)
    kubectl exec -it product-mongo-pod -- sh -c 'exec mongoexport -u admin -p password --authenticationDatabase=admin --db=productDb --collection=product --out=out.json'
    kubectl exec -it product-mongo-pod -- sh -c 'exec cat out.json' > mongo-export-all-collections.json
    kubectl exec -it product-mongo-pod -- sh -c 'exec mongoimport -u admin -p password --authenticationDatabase=admin --db=productDb --collection=product --type json --file /out.json'

    
Mongo shell:
https://docs.mongodb.com/manual/tutorial/write-scripts-for-the-mongo-shell/

    kubectl exec -it product-mongo-pod -- sh
    mongo -u admin -p password 
    show dbs
    use productDb
    show collections
    db.product.find()
    
    
## Run front-end application

Front-end is outside of kubernetes at the moment, or you can set simply `localhost`:
    
    REACT_APP_BACK_END_SERVER_IP=<ingressIp> yarn start
