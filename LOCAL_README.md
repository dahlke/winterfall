# [WIP] Winterfall
_HashiCorp SE Hackathon Project (llarsen & dahlke)_

#### Quick Links
- [Asana Project](https://app.asana.com/0/1108361432591475/1108361432591511)

#### Deployment Prerequisitess
- `minikube` ([install guide](https://kubernetes.io/docs/tasks/tools/install-minikube/))
- `docker` ([install guide](https://docs.docker.com/install/))
- `postgres` ([install guide](https://www.postgresql.org/download/), [MacOS specific](http://exponential.io/blog/2015/02/21/install-postgresql-on-mac-os-x-via-brew/))
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

#### Development Prerequisites
- `python` ([install guide](https://www.python.org/downloads/))
- `npm` ([install guide](https://www.npmjs.com/get-npm))


## Running the Project

### Setting DB Credential  Env Vars

At this point it is assumed that you have started both `minikube` and have `postgres` running on the default port (5432).

```
MINIKUBE_HOST_IP="10.0.2.2";  # VBox default gateway addr to host machine
echo $MINIKUBE_HOST_IP

export PG_DB_ADDR=$MINIKUBE_HOST_IP
export PG_DB_NAME="winterfall"
export PG_DB_UN="postgres"
export PG_DB_PW="postgres"
```

### Configuring `kubectl` and your NameSpace
In the top level directory of the project, run:

```
# create the namespace for the project
kubectl apply -f kubernetes/namespaces/winterfall-ns.yaml

# update the namespace for your new contexts
kubectl config set-context $(kubectl config current-context) --namespace=winterfall

# store the DB env vars in our new context and namespace as a Kubernetes Secret
kubectl create secret generic winterfall-pg-creds \
    --from-literal=PG_DB_ADDR=$PG_DB_ADDR \
    --from-literal=PG_DB_NAME=$PG_DB_NAME \
    --from-literal=PG_DB_UN=$PG_DB_UN \
    --from-literal=PG_DB_PW=$PG_DB_PW
```

Open up a separate tab, set your AWS env vars and run `watch kubectl get svc,ep,deploy,ns,cronjob,pods` to monitor your Kubernetes activity for the next few steps.

## Deploy the App

#### Run the Web App as a Deployment and Expose it as a Service

```
kubectl apply -f kubernetes/deployments/winterfall-web-deploy.yaml
kubectl apply -f kubernetes/services/winterfall-web-svc.yaml

minikube service winterfall-web
```

#### Configure the CronJob to Scrape Snowfall Data

```
kubectl apply -f kubernetes/cronjobs/winterfall-worker-cronjob.yaml
```
