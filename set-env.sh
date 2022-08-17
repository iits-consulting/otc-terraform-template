# Either your ACCESS_KEY and SECRET_KEY or from a serviceaccount

#### OTC CREDENTIALS #####
export OS_DOMAIN_NAME="REPLACE_ME"
export OS_ACCESS_KEY="REPLACE_ME"
export OS_SECRET_KEY="REPLACE_ME"
export AWS_ACCESS_KEY_ID=$OS_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$OS_SECRET_KEY
export TF_VAR_region="eu-de"

##### PROJECT CONFIGURATION #####
#Current Context you are working on can be customer name or cloud name etc.
export TF_VAR_context="iits"
export TF_VAR_domain_name="showcase.iits.tech"
export TF_VAR_stage="showcase"
#Example OS_PROJECT_NAME="${TF_VAR_region}_myproject"
export OS_PROJECT_NAME="${TF_VAR_region}"

# ArgoCD/K8s config
export TF_VAR_dockerhub_username="REPLACE_ME"
export TF_VAR_dockerhub_password="REPLACE_ME"
export TF_VAR_git_token="REPLACE_ME"

#### TERRAFORM LOCAL PLUGIN CACHING #####
mkdir -p ${HOME}/Terraform/plugins
export TF_PLUGIN_CACHE_DIR=${HOME}/Terraform/plugins