# shellcheck shell=bash

function main {
  cd '__argSrc__' \
    && mailmap-linter
}

main "${@}"
