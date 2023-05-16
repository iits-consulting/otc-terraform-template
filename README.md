# Blueprint for iits OTC GitOps

## Introduction

During this Workshop/Blueprint you will learn the basics about proper automation of infrastructere and how to bootstrap ArgoCD.
A similar Approach also applies to FluxCD.

Here is what we want to achieve:

<img src="documentation/big-picture.png" style="width: 60%; height: 30%"/>

**Please keep in mind this workshop just teaches the basics. For a proper and secure production setup please contact us at kontakt@iits-consulting.de**

## Tools Requirements

* Install Terraform in the Version 1.3.5. We would recommend to use the tool [tfenv](https://github.com/tfutils/tfenv)
* Install [otc-auth](https://github.com/iits-consulting/otc-auth). We need to it to be able to login over CLI and getting the kube config
* A proper Shell. If you are using Windows please use GitBash
* [kubectl cli](https://kubernetes.io/de/docs/tasks/tools/install-kubectl)
* Github Account

## Preparation & Requirements
1. Please go to this site: https://github.com/iits-consulting/otc-terraform-template and click on _Use this template_
      ![github-use-template.png](documentation%2Fgithub-use-template.png)
  * Click on _Create a new repository_ and then select _Include all branches_ and _private repo_
  ![include-branches.png](documentation%2Finclude-branches.png)
2. Next step is to do the same as in Step 1 with this project: https://github.com/iits-consulting/otc-infrastructure-charts-template
3. Create now a Github Access Token of your Fork for the repo from step 2. It is needed for ArgoCD to be able to pull information from there
    * Click [here](https://github.com/settings/tokens?type=beta) to do that
    * Select _Only select repositories_ and choose your fork of the infrastructure-charts
    * The token should be able to see branches and pull from the repo
4. You should have got an E-Mail with your credentials the format looks like this

   ![credentials.png](documentation%2Fcredentials.png)
5. Login here: https://auth.otc.t-systems.com/authui/login.action and set a proper password
6. Docker Account 
   * To avoid the [docker rate limit problem](https://docs.docker.com/docker-hub/download-rate-limit/#:~:text=Docker%20Hub%20limits%20the%20number,pulls%20per%206%20hour%20period) you need to create a docker.io account first or use your existing credentials/token. 
       If you don't have a docker account you can create a free one [here](https://hub.docker.com/signup/)
7. Adjust the .envrc file. The .envrc is needed to set environment variables which are used by terraform or by the otc-auth cli tool
   * replace all "REPLACE_ME" Placeholder with the correct values
   * source the updated .envrc file like this "source .envrc"


## Create a remote state bucket

First thing we create is a remote OBS/S3 Bucket. Within this bucket we store the current state of the OTC infrastructure which we will create.

1. Go to the folder _terraform-remote-state-bucket-creation_ and execute terraform init and apply
2. The output from terraform should look like this: ![terraform-output-remote-state.png](documentation%2Fterraform-output-remote-state.png)
3. Add the remote state configuration under:
    - ./otc-cloud/dev/settings.tf
    - ./otc-cloud/dev/kubernetes/settings.tf

## Create the kubernetes cluster and other infrastructure components
1. Go into the folder otc-cloud/dev
    - Take a look at the main.tf and try to understand what we want to set up
    - (Optional) Add or remove some modules from main.tf if you like
        - Use https://registry.terraform.io/modules/iits-consulting/project-factory/opentelekomcloud/latest
   - Execute Terraform init and apply
       - It will take like 10-15 Minutes till everything is up

## Validate your setup is up and running
  * Check Kubernetes
    * source the file otc-cloud/dev/stage-dependent-env.sh
    * the output should look like this:![kubect-fetched.png](documentation%2Fkubect-fetched.png)
    
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
For that we will deploy everything from our Fork from the _Preparation & Requirements Step 5_

- Go into the folder ./otc-cloud/dev/kubernetes
- Take a look at the _main.tf_ and try to understand what we want to achieve
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

## Go over to Argo and deploy some services

We are finished with the terraform part and will switch now over to this repository: https://github.com/iits-consulting/otc-infrastructure-charts-template
