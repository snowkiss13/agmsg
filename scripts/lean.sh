#!/usr/bin/env bash
set -euo pipefail

# Low-context entry point for agents that already know team/name.
# It avoids loading the full agmsg skill and keeps automatic inbox output small.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ACTION="${1:?Usage: lean.sh inbox|get|send ...}"
shift

case "$ACTION" in
  inbox)
    TEAM="${1:?Usage: lean.sh inbox <team> <agent>}"
    AGENT="${2:?Missing agent}"
    AGMSG_CONTEXT_PREVIEW_CHARS="${AGMSG_CONTEXT_PREVIEW_CHARS:-160}" \
      "$SCRIPT_DIR/inbox.sh" "$TEAM" "$AGENT" --quiet
    ;;
  get)
    TEAM="${1:?Usage: lean.sh get <team> <agent> <message_id>}"
    AGENT="${2:?Missing agent}"
    MESSAGE_ID="${3:?Missing message_id}"
    case "$MESSAGE_ID" in
      ''|*[!0-9]*) echo "message_id must be numeric" >&2; exit 2 ;;
    esac
    "$SCRIPT_DIR/api.sh" get teams "$TEAM" messages --agent "$AGENT" --id "$MESSAGE_ID"
    ;;
  send)
    TEAM="${1:?Usage: lean.sh send <team> <from> <to> <message>}"
    FROM="${2:?Missing from}"
    TO="${3:?Missing to}"
    shift 3
    MESSAGE="${*:?Missing message}"
    "$SCRIPT_DIR/send.sh" "$TEAM" "$FROM" "$TO" "$MESSAGE"
    ;;
  *)
    echo "Unknown action: $ACTION (use inbox|get|send)" >&2
    exit 2
    ;;
esac
