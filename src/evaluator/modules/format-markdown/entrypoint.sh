# shellcheck shell=bash

function main {
  source __argTargets__/template local targets
  source __argDoctocArgs__/template local doctoc_args
  local tmp

  info Formatting Markdown code \
    && tmp=$(mktemp) \
    && for path in "${targets[@]}"; do
      info Formatting "${path}" \
        && copy "${path}" "${tmp}" \
        && doctoc "${doctoc_args[@]}" "${path}" \
        && sed -ri '/<!-- START doctoc/,/<!-- END doctoc/s/^( *)/\1\1/' "${path}" \
        && info Checking differences \
        && if git --no-pager diff --no-index "${tmp}" "${path}"; then
          info Table of contents is ok
        else
          error Table of contents does not comply the format. \
            We just formatted it if possible and now the job will fail.
        fi \
        || return 1
    done
}

main "${@}"
