#!/bin/bash
# Validates that every REPLACE_ME placeholder in secrets.sh / .envrc has been
# replaced and that the values look sane, before we authenticate against OTC.

_require_var() { # name value
  if [[ -z "$2" || "$2" == "REPLACE_ME" ]]; then
    _OTC_ERRORS+=("$1 is not set (still REPLACE_ME or empty)")
  fi
}

_check_otc_setup() {
  local _OTC_ERRORS=()

  _require_var TF_VAR_git_token          "$TF_VAR_git_token"
  _require_var TF_VAR_dockerhub_username "$TF_VAR_dockerhub_username"
  _require_var TF_VAR_dockerhub_password "$TF_VAR_dockerhub_password"
  _require_var OS_USERNAME               "$OS_USERNAME"
  _require_var OS_PASSWORD               "$OS_PASSWORD"
  _require_var OS_DOMAIN_NAME            "$OS_DOMAIN_NAME"
  _require_var TF_VAR_context            "$TF_VAR_context"
  _require_var TF_VAR_email              "$TF_VAR_email"
  _require_var TF_VAR_otc_user_id        "$TF_VAR_otc_user_id"
  _require_var TF_VAR_argocd_repo_url    "$TF_VAR_argocd_repo_url"

  if [[ -n "$TF_VAR_context" && "$TF_VAR_context" != "REPLACE_ME" \
        && ! "$TF_VAR_context" =~ ^[a-z0-9-]+$ ]]; then
    _OTC_ERRORS+=("TF_VAR_context must be lowercase letters, digits and hyphens only (got '$TF_VAR_context')")
  fi
  if [[ -n "$TF_VAR_email" && "$TF_VAR_email" != "REPLACE_ME" \
        && ! "$TF_VAR_email" =~ ^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$ ]]; then
    _OTC_ERRORS+=("TF_VAR_email does not look like an email address (got '$TF_VAR_email')")
  fi
  if [[ "$TF_VAR_argocd_repo_url" == "https://github.com/iits-consulting/otc-infrastructure-charts-template.git" ]]; then
    _OTC_ERRORS+=("TF_VAR_argocd_repo_url still points to the template repo — fork otc-infrastructure-charts-template and use your own repository URL")
  fi
  if [[ -n "$TF_VAR_otc_user_id" && "$TF_VAR_otc_user_id" != "REPLACE_ME" \
        && ! "$TF_VAR_otc_user_id" =~ ^[0-9a-f]{32}$ ]]; then
    _OTC_ERRORS+=("TF_VAR_otc_user_id must be a 32-character hex string (got '$TF_VAR_otc_user_id')")
  fi
  if [[ -n "$TF_VAR_git_token" && "$TF_VAR_git_token" != "REPLACE_ME" \
        && ! "$TF_VAR_git_token" =~ ^(ghp_|github_pat_) ]]; then
    _OTC_ERRORS+=("TF_VAR_git_token should start with 'ghp_' or 'github_pat_' (a GitHub access token)")
  fi

  if (( ${#_OTC_ERRORS[@]} > 0 )); then
    echo "❌ .envrc / secrets.sh validation failed:" >&2
    printf '   - %s\n' "${_OTC_ERRORS[@]}" >&2
    echo "Fix the values above and run 'source .envrc' again." >&2
    return 1
  fi
  echo "✅ .envrc and secrets.sh look good."
}

_check_otc_setup
_otc_check_rc=$?
unset -f _check_otc_setup _require_var
return $_otc_check_rc 2>/dev/null || exit $_otc_check_rc
