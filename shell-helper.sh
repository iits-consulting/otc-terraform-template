#!/bin/bash
LANG=en_us_88591

function argoCredentials(){
  # Tofu sets the admin password to TF_VAR_admin_website_password, so ArgoCD never
  # creates argocd-initial-admin-secret. The secret is only there for older setups.
  local ARGOCD_PASSWORD="$TF_VAR_admin_website_password"
  if [[ -z "$ARGOCD_PASSWORD" ]]; then
    ARGOCD_PASSWORD=$( kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data['password']}" | base64 -d)
  fi
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

# kubectl tab completion, for this shell only
if command -v kubectl >/dev/null 2>&1; then
  if [[ -n "$ZSH_VERSION" ]]; then
    autoload -Uz compinit && compinit
    source <(kubectl completion zsh)
  else
    if ! declare -F _get_comp_words_by_ref >/dev/null; then
      for f in /usr/share/bash-completion/bash_completion /etc/bash_completion; do
        [[ -r "$f" ]] && source "$f" && break
      done
    fi
    if declare -F _get_comp_words_by_ref >/dev/null; then
      source <(kubectl completion bash)
    fi
  fi
fi
