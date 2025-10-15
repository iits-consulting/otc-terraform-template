#!/bin/bash
LANG=en_us_88591

function argoCredentials(){
  local ARGOCD_PASSWORD=$( kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data['password']}" | base64 -d)
  echo "Username=admin, password=$ARGOCD_PASSWORD"
}

function argo(){
  argoCredentials

  if [[ $(uname) == "Linux" ]]; then
    xdg-open http://localhost:8080/argocd && kubectl -n argocd port-forward svc/argocd-server 8080:80
  else
    open http://localhost:8080/argocd && kubectl -n argocd port-forward svc/argocd-server 8080:80
  fi
}


alias kubens='kubectl config set-context --current --namespace '
alias deleteErrorPods="kubectl delete pods --field-selector status.phase=Failed --all-namespaces"
alias kubeEnv="kubectl config current-context"
