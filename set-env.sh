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
export TF_VAR_context="showcase"
# Current Stage you are working on for example dev,qa, prod etc.
export TF_VAR_stage="dev"
export OS_PROJECT_NAME="eu-de"

# ArgoCD/K8s config
export TF_VAR_registry_credentials_dockerconfig_username="REPLACE_ME"
export TF_VAR_registry_credentials_dockerconfig_password="REPLACE_ME"
export TF_VAR_argocd_git_access_token="REPLACE_ME"

#### TERRAFORM LOCAL PLUGIN CACHING #####
mkdir -p ${HOME}/Terraform/plugins
export TF_PLUGIN_CACHE_DIR=${HOME}/Terraform/plugins