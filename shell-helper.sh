#!/bin/bash
LANG=en_us_88591

function argo(){
  local ARGOCD_PASSWORD=$( kubectl -n argocd get secret argocd-secret -o jsonpath="{.data['clearPassword']}" | base64 -d)
  echo "Username=admin, password=$ARGOCD_PASSWORD"


  if [[ $(uname) == "Linux" ]]; then
    xdg-open http://localhost:8080/argocd && kubectl -n argocd port-forward svc/argocd-server 8080:80
  else
    open http://localhost:8080/argocd && kubectl -n argocd port-forward svc/argocd-server 8080:80
  fi
}

function argoCredentials(){
  local ARGOCD_PASSWORD=$( kubectl -n argocd get secret argocd-secret -o jsonpath="{.data['clearPassword']}" | base64 -d)
  echo "Username=admin, password=$ARGOCD_PASSWORD"
}

alias kubens='kubectl config set-context --current --namespace '
alias deleteErrorPods="kubectl delete pods --field-selector status.phase=Failed --all-namespaces"
alias kubeEnv="kubectl config current-context"