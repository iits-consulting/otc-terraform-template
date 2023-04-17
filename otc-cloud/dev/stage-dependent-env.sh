#Auto login into OTC with the new user
export TF_VAR_stage="dev"
export CLUSTER_NAME="${TF_VAR_context}-${TF_VAR_stage}"

otc-auth cce get-kube-config