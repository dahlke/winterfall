# [WIP] Winterfall
_HashiCorp SE Hackathon Project (llarsen & dahlke)_

#### Quick Links
- [Asana Project](https://app.asana.com/0/1108361432591475/1108361432591511)

#### Prerequisites
- [`terraform`](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [`aws`](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [`aws-iam-authenticator`](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/)


## Running the Project

### AWS Preparation

To prepare for the AWS environment, you need to set your AWS creds as env vars and install the aws-iam-authenticator. First, set your env vars with the following:

```
export AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID>
export AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY>
```

Then, you'll need to install `aws-iam-authenticator`. This can be done quickly with the:

```
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/darwin/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH
```

To confirm that the install went correctly, run `aws-iam-authenticator help`.


### Deploying the Infrastructure

To deploy, you'll need to `cd` into the `terraform/aws/` directory and run  your `terraform` commands. You'll be deploying two modules,  one from the public registry ([`terraform-aws-modules/eks/aws`](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/2.2.0)) and one from this repo ([`./modules/postgres`](./modules/aws/rds)).

An example flow:

```
cd terraform/aws/
terraform plan

# if everything looks good to you
terraform apply
```

### Setting DB Credential  Env Vars
At this point your infrastructure will be deployed and you should be able to get our credentials for the RDS instance you created. You should retrieve them and store them ass env vars for the next few steps.


```
TF_OUTPUT=$(terraform output -json)
export PG_DB_ADDR=$(echo $TF_OUTPUT | jq -r .db_address.value)
export PG_DB_NAME=$(echo $TF_OUTPUT | jq -r .db_name.value)
export PG_DB_UN=$(echo $TF_OUTPUT | jq -r .db_username.value)
export PG_DB_PW=$(echo $TF_OUTPUT | jq -r .db_password.value)
```

### Configuring `kubectl` and your NameSpace
You'll want to `cd` back to the top level directory of the project if you haven't already, then run:

```
# add the config for the new cluster to kubectl (will autoswitch cluster)
aws eks --region us-east-1 update-kubeconfig --name winterfall

# confirm you have connected
kubectl get nodes

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

#### Install the [Kubernetes Dashboard on the EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html)

Open up another new tab and set your AWS credential env vars again, then run.

```
kubectl apply -f kubernetes/eks-specific/service-accounts/eks-admin-sa.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
kubectl proxy
```

Once proxied, you can reach the dashboard [here](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login). Use the token from the output of the `describe secret` command above to log into the dashboard.


## Deploy the App

#### Run the Web App as a Deployment and Expose it as a Service

Open up another tab and re-set your AWS env vars one more time. Then run:

```
kubectl apply -f kubernetes/deployments/winterfall-web-deploy.yaml
kubectl apply -f kubernetes/services/winterfall-web-svc.yaml
```

#### Configure the CronJob to Scrape Snowfall Data

```
kubectl apply -f kubernetes/cronjobs/winterfall-worker-cronjob.yaml

```