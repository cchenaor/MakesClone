# shellcheck shell=bash

function main {
  local access_key_id_name='__argAccessKeyId__'
  local default_region_name='__argDefaultRegion__'
  local secret_access_key_name='__argSecretAcessKey__'
  local session_token_name='__argSessionToken__'

  true \
    && require_env_var "${access_key_id_name}" \
    && require_env_var "${secret_access_key_name}" \
    && export AWS_ACCESS_KEY_ID="${!access_key_id_name}" \
    && export AWS_DEFAULT_REGION="${!default_region_name:-us-east-1}" \
    && export AWS_SECRET_ACCESS_KEY="${!secret_access_key_name}" \
    && export AWS_SESSION_TOKEN="${!session_token_name:-}"
}

main "${@}"
