
# login first? (you're probably logged in, but if not)
google auth login

# list clusters:
# note: switch default `gcloud config set project PROJECT_ID`
gcloud container clusters list  # will use default project

# list clusters for specific project:
gcloud container clusters list --project owletcare-prod

# get credentials to connect to a cluster:
gcloud container clusters get-credentials <cluster> --zone <zone-cluster-is-in> \
    --project <your GCP project-id>

# get credentials for cluster "platform" on owletcare-dev:
gcloud container clusters get-credentials platform --zone us-central1-a --project owletcare-dev

# list all your deployments
helm ls -A

# list all your namespaces
kubectl get namespace
