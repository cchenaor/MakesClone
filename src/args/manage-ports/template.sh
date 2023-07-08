# shellcheck shell=bash

function _kill_port {
  local pids
  local port="${1}"

  pids="$(mktemp)" \
    && if ! lsof -t "-i:${port}" > "${pids}"; then
      echo "[INFO] Nothing listening on port: ${port}" \
        && return 0
    fi \
    && while read -r pid; do
      if kill -9 "${pid}"; then
        if timeout 5 tail --pid="${pid}" -f /dev/null; then
          echo "[INFO] Killed pid: ${pid}, listening on port: ${port}"
        else
          echo "[WARNING] kill timeout pid: ${pid}, listening on port: ${port}"
        fi
      else
        echo "[ERROR] Unable to kill pid: ${pid}, listening on port: ${port}"
      fi
    done < "${pids}"
}
function kill_port {
  for port in "${@}"; do
    _kill_port "${port}" \
      || return 1
  done
}

function done_port {
  local host="${1}"
  local port="${2}"

  kill_port "${port}" \
    && echo "[INFO] Done at ${host}:${port}" \
    && nc -kl "${host}" "${port}"
}

function wait_for_tcp {
  local elapsed='1'
  local timeout="${1}"
  local host="${2%:*}"
  local port="${2#*:}"

  while true; do
    if timeout 1s nc -z "${host}" "${port}"; then
      return 0
    elif test "${elapsed}" -gt "${timeout}"; then
      echo "[ERROR] Timeout while waiting for ${host}:${port} to open" \
        && return 1
    else
      echo "[INFO] Waiting 1 second for ${host}:${port} to open, ${elapsed} seconds in total" \
        && sleep 1 \
        && elapsed="$(("${elapsed}" + 1))" \
        && continue
    fi
  done
}

function wait_port {
  local pids=()
  local timeout="${1}"

  for address in "${@:2}"; do
    { wait_for_tcp "${timeout}" "${address}" & } \
      && pids+=("${!}")
  done \
    && for pid in "${pids[@]}"; do
      wait "${pid}" \
        || return 1
    done
}
