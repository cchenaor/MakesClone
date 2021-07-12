#! __argShell__
# shellcheck shell=bash

source __argBuiltinShellOptions__

function running_in_ci_cd_provider {
  # Non-empty on Gitlab, Github, Travis
  export CI

  test -n "${CI:-}"
}

function setup {
  export HOME
  export HOME_IMPURE
  export SSL_CERT_FILE='__argCaCert__/etc/ssl/certs/ca-bundle.crt'
  export STATE

  source __argSearchPathsEmpty__ \
    && source __argSearchPathsBase__ \
    && if test -z "${HOME_IMPURE:-}"; then
      HOME_IMPURE="${HOME:-}" \
        && HOME="$(mktemp -d)"
    fi \
    && STATE="${HOME_IMPURE}/.makes/state/__argName__" \
    && rm -rf "${STATE}" \
    && mkdir -p "${STATE}" \
    && source __argBuiltinShellCommands__ \
    && source __argSearchPaths__
}

setup
