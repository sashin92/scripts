#!/usr/bin/env bash

set -e

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 [ssh options] user@host -- [port|start:end]..."
  exit 1
fi

SSH_OPTS=""
PORT_ARGS=""
TARGET=""
PORT_MODE=false
PORT_SPECS=""

for arg in "$@"; do
  if [[ "$arg" == "--" ]]; then
    PORT_MODE=true
    continue
  fi

  if ! $PORT_MODE; then
    if [[ "$arg" == *@* ]]; then
      TARGET="$arg"
    else
      SSH_OPTS+=" $arg"
    fi
  else
    # 👉 입력값 그대로 저장
    PORT_SPECS+=" $arg"

    if [[ "$arg" == *:* ]]; then
      START="${arg%%:*}"
      END="${arg##*:}"

      for ((p=START; p<=END; p++)); do
        PORT_ARGS+=" -L ${p}:localhost:${p}"
      done
    else
      PORT_ARGS+=" -L ${arg}:localhost:${arg}"
    fi
  fi
done

if [ -z "$TARGET" ]; then
  echo "Error: missing user@host"
  exit 1
fi

# 👉 포트 개수 계산
PORT_COUNT=$(grep -o -- "-L" <<< "$PORT_ARGS" | wc -l | tr -d ' ')

echo "Running SSH tunnel"
echo "  Target : $TARGET"
[ -n "$SSH_OPTS" ] && echo "  Options: $SSH_OPTS"
[ -n "$PORT_SPECS" ] && echo "  Ports  :$PORT_SPECS ($PORT_COUNT tunnels)"
echo

eval ssh ${SSH_OPTS} ${PORT_ARGS} "${TARGET}"
