# How to setup Ollama (LLM) with RAG on OpenTelekomCloud

## Introduction

During this Workshop/Blueprint you will learn the basics about proper automation of infrastructere and how to setup a gpu node cluster with Ollama.

**Please keep in mind this workshop just teaches the basics. For a proper and secure production setup please contact us at kontakt@iits-consulting.de**

## What do we want to achieve ?

https://github.com/iits-consulting/otc-terraform-template/assets/19291722/88fa3699-896d-409c-8d32-23900c38d599

In this screenshot you see a local Ollama with a custom WebUI running on OTC with Kubernetes and GPU node pool.


## Tools Requirements

* Install Terraform in the Version 1.4.6 We would recommend to use the tool [tfenv](https://github.com/tfutils/tfenv)
* Install [otc-auth](https://github.com/iits-consulting/otc-auth). We need to it to be able to login over CLI and getting the kube config
* A proper Shell. If you are using Windows please use GitBash
* [kubectl cli](https://kubernetes.io/de/docs/tasks/tools/install-kubectl)
* git

## Preparation & Requirements
1. First we will pull the Terraform sourcecode. Please go to this site: https://github.com/iits-consulting/otc-terraform-template
      ![clone-otc-terraform-template.png](documentation%2Fclone-otc-terraform-template.png)
  * Click on _Code_
  * Clone the repository 
2. You should have got an E-Mail with your credentials the format looks like this

   ![credentials.png](documentation%2Fcredentials.png)
3. Docker Account 
   * To avoid the [docker rate limit problem](https://docs.docker.com/docker-hub/download-rate-limit/#:~:text=Docker%20Hub%20limits%20the%20number,pulls%20per%206%20hour%20period) you need to create a docker.io account first or use your existing credentials/token. 
       If you don't have a docker account you can create a free one [here](https://hub.docker.com/signup/)
4. Adjust the .envrc and my-secrets.sh file. The .envrc is needed to set environment variables which are used by terraform or by the otc-auth cli tool
   * replace all "REPLACE_ME" Placeholder with the correct values
   * source the updated .envrc file like this "source .envrc"

## Create the kubernetes cluster and other infrastructure components

First go into the folder otc-cloud/dev

### Create Terraform state bucket

To be able to store the state of terraform somewhere secure, we need first to create a remote tfstate backend.
The remote tfstate backend is in this case a OBS/S3 Bucket. Within this bucket we store the current state of the OTC infrastructure which we will create.

2. Execute 
      ```shell
      terraform init
      ```
3. Execute
      ```shell
      terraform apply --auto-approve
      ```
4. Wait for completion
5. After completion we should get a output which looks like this:
   ![terraform-output-remote-state.png](documentation%2Fterraform-output-remote-state.png)
6. Copy the output and replace inside the settings.tf file the commented out section of the backend with the output

## Execute Terraform for infrastructure

1. Switch into the folder otc-cloud/dev/infrastructure
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

## Spin up Ollama UI

Now we want to bring some life into our cluster.

- Go into the folder ./otc-cloud/dev/kubernetes
- Repeat the steps from this point again [here](#create-terraform-state-bucket)
- Take a look at the _.tf_ files and try to understand what we want to achieve
- Execute Terraform init and apply
- You should be able to access your LLM now. The Url is the same as $TF_VAR_domain_name


## How to setup RAG for your LLM

The Ollama Webui should be accessible now. The question now is how we can easily chat with all of our data inside the
company?

For syncing data we let https://airbyte.com/ do the job. As a vector db we use weaviate.

The idea is the following:

![rag-with-airbyte.jpg](documentation%2Frag-with-airbyte.jpg)

1. You have multiple data storage formats and technologies where you store data
2. You install airbyte to get this data periodically
3. You save the data inside weaviate (vector db with the correct embeddings)
4. You need a custom middleware which fetches the data from the weaviate db and enriches the ollama with your custom documents


**How can we set it up ?**

- Go into the folder ./otc-cloud/dev/kubernetes
- Comment in the whole _ollama-fullstack.tf_ file
- Uncomment the whole file _ollama.tf_
- Execute Terraform init and apply
- You should have now three services online:
    - weaviate (only internally reachable)
    - airbyte (airbyte.$TF_VAR_domain_name)
    - Ollama WebUI ($TF_VAR_domain_name)

**Notes:**

- Keep in mind these are just the first steps and only a demo setup. To complete the setup you would need these things:
    - Configure the airbyte connectors
    - Configure the embeddings
    - Create a custom middleware which connects to weaviate db
    - OAuth2 Proxy and proper security mechanism

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
