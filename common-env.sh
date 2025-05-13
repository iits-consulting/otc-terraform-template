source ./secrets.sh

export TF_VAR_email="replace_me@iits-consulting.de" # example: mymail@mail.de
export TF_VAR_context="REPLACE_ME" # See E-Mail with credentials (TF_VAR_context)
export TF_VAR_dockerhub_username="iits"

#informations from the credentials e-mail
export OS_DOMAIN_NAME="REPLACE_ME" # See E-Mail with credentials (OS_DOMAIN_NAME)
export OS_PROJECT_NAME="eu-de_${TF_VAR_context}" # See E-Mail with credentials (OS_PROJECT_NAME)
export TF_VAR_otc_user_id="REPLACE_ME" # See E-Mail with credentials (OTC_USER_ID)

export TF_VAR_region="eu-de"
export REGION=$TF_VAR_region
export TF_VAR_domain_name="${TF_VAR_context}.iits.tech"

# OTC auth
otc-auth login iam -o

echo "create temp AK/SK"
#Terraform temp AK/SK
otc-auth temp-access-token create --duration-seconds 86390
source ./ak-sk-env.sh
export TF_VAR_ak_sk_security_token=$AWS_SESSION_TOKEN
rm ./ak-sk-env.sh

unset OS_USERNAME
unset OS_PASSWORD

export TF_VAR_argocd_bootstrap_project_url="https://github.com/iits-consulting/otc-infrastructure-charts-template.git"
