## Getting Started

# get credentials for a cluster
gcloud container clusters get-credentials platform --project owletcare-dev --region us-central1

# use kubectx to set a nickname
kubectx dev=gke_owletcare-dev_us-central1_platform

# Or just run my script: kubernetes-setup-credentials

## Misc

# ssh into a box
kubectl exec --stdin --tty device-registration-v1-redis-master-0 -- /bin/bash

## Standard Operations

# see what pods exist
kubectl get pods

# create a pod
    ---
    somepodspec.yaml
    ---
    apiVersion: v1
    kind: Pod
    metadata:
      name: basicpod
    spec:
      containers:
      - name: webcont
        image: nginx
    ---

kubectl create -f somepodspec.yaml

# create a tmp pod and ssh into it for work in that enviroment

kubectl run tmp-debug --image=ubuntu -o yaml --command -- sleep 1200
kubectl run tmp-debug --image=ubuntu -o yaml --command -- sleep infinity
kubectl exec -it tmp-debug  -- bash

# login to a pod

## default container:
kubectl exec -it <Pod_Name>  -- /bin/bash

# specific container:
kubectl exec -it <Pod_Name> -c <Container_Name> -- /bin/bash

# logs

## get the logs for a pod (you really want events in most cases!)
kubernetes-get-events [deployment_name|pod_name]
kubectl get event --field-selector involvedObject.name=accounts-v1-5cdcbc56bd-hc25s

# get pods associated with a deployment (called a "release" in the output)
kubectl get pods --selector release=<deployment_name> --no-headers=true --output name
# outputs pod/<podname> and <podname> is what you want

# get secrets
kubectl get secrets

# grab specific secret:
kubectl get secret device-replicator-v1-basic-auth -oyaml | yq -r ".data.username" | base64 -d
kubectl get secret device-replicator-v1-basic-auth -oyaml | yq -r ".data.passwordProd" | base64 -d
