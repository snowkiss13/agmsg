#!/usr/bin/env bats

load test_helper

setup() {
  setup_test_env
  bash "$SCRIPTS/join.sh" testteam alice claude-code /tmp/project-a
  bash "$SCRIPTS/join.sh" testteam bob codex /tmp/project-b
}

teardown() {
  teardown_test_env
}

@test "lean: inbox preview then exact get" {
  local body="a deliberately long handoff body"
  bash "$SCRIPTS/send.sh" testteam bob alice "$body"
  AGMSG_CONTEXT_PREVIEW_CHARS=10 run bash "$SCRIPTS/lean.sh" inbox testteam alice
  [ "$status" -eq 0 ]
  [[ "$output" == *"a delibera…"* ]]
  [[ "$output" != *"$body"* ]]
  local id
  id="$(printf '%s' "$output" | sed -n 's/.*\[id=\([0-9][0-9]*\)\].*/\1/p')"
  run bash "$SCRIPTS/lean.sh" get testteam alice "$id"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$body"* ]]
}

@test "lean: send preserves a multiword body" {
  run bash "$SCRIPTS/lean.sh" send testteam alice bob hello from lean mode
  [ "$status" -eq 0 ]
  run bash "$SCRIPTS/api.sh" get teams testteam messages --agent bob
  [[ "$output" == *"hello from lean mode"* ]]
}

@test "lean: get rejects a nonnumeric id" {
  run bash "$SCRIPTS/lean.sh" get testteam alice nope
  [ "$status" -eq 2 ]
  [[ "$output" == *"must be numeric"* ]]
}
