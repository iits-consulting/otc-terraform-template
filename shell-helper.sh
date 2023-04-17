#!/bin/bash
LANG=en_us_88591

function getStageSecretsBucket(){
  if [[ -z "${OS_PROJECT_NAME}" ]]; then
    echo "Mandatory Env Variable \"OS_PROJECT_NAME\" not found. Please switch to a directory with a suitable \".envrc\" file and run \"direnv allow\" before executing again."
    return 1
  fi
  PROJECT=${OS_PROJECT_NAME/"_"/"-"}
  CONTEXT=${TF_VAR_context/"_"/"-"}
  BUCKET_NAME=$PROJECT-$CONTEXT-$TF_VAR_stage-stage-secrets
  secretspath="/terraform-secrets"
  current_date=$(date +'%a, %d %b %Y %H:%M:%S %z')
  request_string="GET\n\n\n${current_date}\n/${BUCKET_NAME}${secretspath}"
  signed_reqest=$(echo -en "${request_string}" | openssl sha1 -hmac "${AWS_SECRET_ACCESS_KEY}" -binary | base64)
  curl -s -H "Host: ${BUCKET_NAME}.obs.${TF_VAR_region}.otc.t-systems.com" \
       -H "Date: ${current_date}" \
       -H "x-obs-security-token:gQVldS1kZY7Fse_zxB_LZgzPGd73uYCJnKhFX5I8T_hlZi0GN_LbeA0IR-aAEyNA8JiEqQd2_xuTF0jjgOHlUYU6ETgnY5ju9zzM2EqPknUgIG0SGE1b2LzsjP8zQaAzFUCJQH7bP8hnyFA-VHHNbls7KYNEVrfBJG29cbRDSTr61K6qmFP71Tz0b9lY6IaVLhQTRS0J9YV-h3FrcSUaNGl8YAwaoraRVdP64K6QCb0GE4Gdk_Dxtr3mSUp1zQrLLU5SiMVvvXlLBOp4XkMV12G9x9h07Qcv20YoLHm_KvYRIQjjYKB_woj2ceH9yD7TUUw-N9bv0868iiaNQmRrL-Sn0oLUYfab_jCOAZi2lnKdtix9DPRXmPR6b5MLdUjCq5VXHro6rDr5lSXRkabt6rL_eiqHro2hc7DmdQjF0C3AcrenVDADKivWuzBAEzbF1kquaDlPFrjQi0iH2dvSTF4AHFZ4hqCtUNAo4_5xuPJ-POcu7mfEUoq73y2KiINtMc7weS9_lN7cfTaKAgdxbjEam2bRYlZO55ay-lG2uS5s3QMK-Fo-WmRJYMNMxlCM4I-ulgk30bBxxDNiuf0kGSCAjLPGo7JXcKtsCpJkWil4-awDGOw5P3emtqICj7CmrRhxBbgJ6mwFaICwETTEZHdGpX7Chq1JAFOmJVXgrjlQ9YL_UR3kRKw6Im2WnuDy3R2Rv8SePHgoKiADD6fwbv5nA8wpJfiotGs5KtDLx53Qd4RVdOlpL28KsYwPS5pb1VxkBk4X8V_tEnwaY1Z0AcgKSoDjEmx3vXBwWfIULe-09Yh3a_rGKLpMNjPN2Rkar2cOxMdyOr9CNGdXcNaz-eq4HtMQxOk0ob6tGql3vDdirTxJ-trnLVQ5ggsOC885oK-DsSfTRCFqzVZYT4Zv8F7-WhtYpVWUCLRWTIfuegw1oeuvwwchpqpjMMZsuUAMPjxjhdnnIeo=" \
       -H "Authorization: AWS ${AWS_ACCESS_KEY_ID}:${signed_reqest}" \
       "https://${BUCKET_NAME}.obs.${TF_VAR_region}.otc.t-systems.com${secretspath}"
}

function getKubectlConfig() {
  export CLUSTER_NAME="${TF_VAR_context}_${TF_VAR_stage}"
  otc-auth cce get-kube-config
}

function getElbPublicIp(){
    elbPublicIp=$(getStageSecretsBucket | jq -r ."elb_public_ip")
    echo "ELB-PUBLIC-IP: $elbPublicIp"
}

function getElbId() {
    elbID=$(getStageSecretsBucket | jq -r ."elb_id")
    echo "ELB-ID: $elbID"
}

function argo(){
  local ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
  echo "Username=admin, password=$ARGOCD_PASSWORD"


  if [[ $(uname) == "Linux" ]]; then
    xdg-open http://localhost:8080/argocd && kubectl -n argocd port-forward svc/argocd-server 8080:80
  else
    open http://localhost:8080/argocd && kubectl -n argocd port-forward svc/argocd-server 8080:80
  fi
}

function traefik() {
  local localhost_port="9000"
  echo "Open \"http://localhost:${localhost_port}/dashboard/#/\" to see your treafik dashboard"
  kubectl -n routing port-forward $(kubectl get pod -n routing -o jsonpath="{.items[0].metadata.name}") ${localhost_port}:9000

}

alias kubens='kubectl config set-context --current --namespace '
alias deleteErrorPods="kubectl delete pods --field-selector status.phase=Failed --all-namespaces"
alias kubeEnv="kubectl config current-context"