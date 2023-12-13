# Blueprint for iits OTC GitOps

## Introduction

During this Workshop/Blueprint you will learn the basics about proper automation of infrastructere and how to bootstrap ArgoCD.
A similar Approach also applies to FluxCD.

If you want to use this setup without attending our workshop please do first the following step

Here is what we want to achieve:


![big-picture.png](documentation%2Fbig-picture.png)


![admin-dashboard.png](documentation%2Fadmin-dashboard.png)

The following services we will deploy later
* Admin Dashboard
* Basic Auth Gateway
* Storage Classes
* Elastic Stack (kibana/elasticsearch/filebeat)
* Kyverno

**Please keep in mind this workshop just teaches the basics. For a proper and secure production setup please contact us at kontakt@iits-consulting.de**

## Tools Requirements

* Install Terraform in the Version 1.4.6 We would recommend to use the tool [tfenv](https://github.com/tfutils/tfenv)
* Install [otc-auth](https://github.com/iits-consulting/otc-auth). We need to it to be able to login over CLI and getting the kube config
* A proper Shell. If you are using Windows please use GitBash
* [kubectl cli](https://kubernetes.io/de/docs/tasks/tools/install-kubectl)
* git
* Github Account

## Preparation & Requirements
1. First we will pull the Terraform sourcecode. Please go to this site: https://github.com/iits-consulting/otc-terraform-template
      ![clone-otc-terraform-template.png](documentation%2Fclone-otc-terraform-template.png)
  * Click on _Code_
  * Clone the repository 
2. Next step is to create a fork for the ArgoCD project. Please go to this link: https://github.com/iits-consulting/otc-infrastructure-charts-template
  * Click on _Use this template_
  * Click on _Create a new repository_ 
    * choose a repository name 
    * select _Private_ repository
3. Create now a Github Access Token of your Fork for the repo from step 2. It is needed for ArgoCD to be able to pull information from there
    * Click [here](https://github.com/settings/tokens?type=beta) to do that
    * Select _Only select repositories_ and choose your fork of the infrastructure-charts
    * Permissions
      * Contents -> Read-Only
      * Commit Status -> Read-Only
4. You should have got an E-Mail with your credentials the format looks like this

   ![credentials.png](documentation%2Fcredentials.png)
5. Docker Account 
   * To avoid the [docker rate limit problem](https://docs.docker.com/docker-hub/download-rate-limit/#:~:text=Docker%20Hub%20limits%20the%20number,pulls%20per%206%20hour%20period) you need to create a docker.io account first or use your existing credentials/token. 
       If you don't have a docker account you can create a free one [here](https://hub.docker.com/signup/)
6. Adjust the .envrc and my-secrets.sh file. The .envrc is needed to set environment variables which are used by terraform or by the otc-auth cli tool
   * replace all "REPLACE_ME" Placeholder with the correct values
   * source the updated .envrc file like this "source .envrc"

## Create the kubernetes cluster and other infrastructure components

First go into the folder otc-cloud/dev

### Create Terraform state bucket

To be able to store the state of terraform somewhere secure, we need first to create a remote tfstate backend.
THe remote tfstate backend is in this case a OBS/S3 Bucket. Within this bucket we store the current state of the OTC infrastructure which we will create.

2. Execute 
      ```shell
      terraform init
      ```
3. Execute
      ```shell
      terraform apply --target module.tf_state_bucket --auto-approve
      ```
4. Wait for completion
5. After completion we should get a output which looks like this:
   ![terraform-output-remote-state.png](documentation%2Fterraform-output-remote-state.png)
6. Copy the output and replace inside the settings.tf file the commented out section of the backend with the output
7. Execute this command
      ```shell
   terraform init
      ```
8. Type _yes_ and enter
9. remove the files _terraform.tfstate_ and _terraform.tfstate.backup_

## Execute Terraform
1. Now take a look at the main.tf and try to understand what we want to set up
    - (Optional) Add or remove some modules from main.tf if you like
        - Use https://registry.terraform.io/modules/iits-consulting/project-factory/opentelekomcloud/latest
   - Execute Terraform init and apply
       - It will take like 10-15 Minutes till everything is up

## Validate your setup is up and running
  * Check Kubernetes
    * with terraform we fetched already the kube config
    * execute inside your cli the following command:
      ```shell
      kubectl get nodes
      ```
  * Check DNS
    * execute inside your cli the following command:
    ```shell
    nslookup $TF_VAR_domain_name 
    ```
    * It should point to some 80.*.*.* Address

Congrats your infrastructure is working properly

## Bootstrap ArgoCD

Now we want to bring some life into our cluster. 
For that we will deploy everything from our Fork from the _Preparation & Requirements Step 2_

- Go into the folder ./otc-cloud/dev/kubernetes
- Repeat the steps from this point again [here](#create-terraform-state-bucket)
- Take a look at the _argo.tf_ and try to understand what we want to achieve
- Execute Terraform init and apply
- ArgoCD should slowly start to boot and after around 3-4 Minutes it should be finished

## Access ArgoCD UI

First we will access ArgoCD over a kubectl port-forward. To do that execute the following commands in your cli:

```shell
# This command will make the argo command available
source shell-helper.sh
# Opens a tunnel to your kubernetes cluster and exposes ArgoCD under http://localhost:8080/argocd
# It will print out the Username and the Password on the first line and the browser should open automatically.
argo
```

After some minutes argocd is also available over your domain like this: https://admin.${TF_VAR_context}.iits.tech

## Save the basic auth credentials

Inside otc-cloud/dev/kubernetes you see there is now a new file which is called *basic-auth-password.txt*
Inside this file you will find the credentials to be able to access your page.

## Go over to Argo and deploy some services

We are finished with the terraform part and will switch now over to this repository: https://github.com/iits-consulting/otc-infrastructure-charts-template


## Do the workshop on your tenant

If you want to do the workshop on your tenant you need to create a user first and configure the IAM. 

Please do the following steps:

1. Login into the OTC UI
2. Go to _IAM_
3. Create a new project for the workshop
4. Create a user and assign it the admin role
    * You will need the username & password
5. Go to _Agencies_ ![agencies.png](documentation%2Fagencies.png)
6. For _EVSAccessKMS_ click on _Authorize_
   * Add _KMS Administrator_ for _All resources_
7. For _cce_admin_trust_ click on _Authorize_
    * Add _Tenant Administrator (Exclude IAM)_ for _All resources_
