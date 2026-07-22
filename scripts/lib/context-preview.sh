#!/usr/bin/env bash

# Shared automatic-delivery preview policy. Manual inbox/history remain full.
# AGMSG_CONTEXT_PREVIEW_CHARS=0 restores the legacy full-body behavior.

agmsg_context_preview_chars() {
  local script_dir="$1"
  local value="${AGMSG_CONTEXT_PREVIEW_CHARS:-}"
  if [ -z "$value" ]; then
    value="$("$script_dir/config.sh" get delivery.context_preview_chars 160 2>/dev/null || printf '160')"
  fi
  case "$value" in
    ''|*[!0-9]*) value=160 ;;
  esac
  printf '%s' "$value"
}

agmsg_context_preview_body() {
  local body="$1" limit="$2"
  if [ "$limit" -eq 0 ] || [ "${#body}" -le "$limit" ]; then
    printf '%s' "$body"
  else
    printf '%s…' "${body:0:limit}"
  fi
}

agmsg_context_body_is_truncated() {
  local body="$1" limit="$2"
  [ "$limit" -gt 0 ] && [ "${#body}" -gt "$limit" ]
}
