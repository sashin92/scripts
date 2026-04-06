#!/usr/bin/env bash

set -e

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 [ssh options] user@host [-- port|start:end ...]"
  exit 1
fi

SSH_OPTS=""
PORT_ARGS=""
TARGET=""
PORT_MODE=false
PORT_SPECS=""
PORTS=""

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
        PORTS+=" $p"
      done
    else
      PORTS+=" $arg"
    fi
  fi
done

if [ -z "$TARGET" ]; then
  echo "Error: missing user@host"
  exit 1
fi

# 👉 중복 제거 및 경고
UNIQUE_PORTS=$(echo $PORTS | tr ' ' '\n' | sort -n | uniq)
DUPES=$(echo $PORTS | tr ' ' '\n' | sort -n | uniq -d)
[ -n "$DUPES" ] && echo -e "\033[33mWarning: duplicate ports ignored: $(echo $DUPES | tr '\n' ' ')\033[0m"

# 👉 사용 중인 포트 경고
for p in $UNIQUE_PORTS; do
  if lsof -iTCP:"$p" -sTCP:LISTEN -P -n >/dev/null 2>&1; then
    echo -e "\033[33mWarning: port $p is already in use\033[0m"
  fi
done

# 👉 포트 인자 생성
for p in $UNIQUE_PORTS; do
  PORT_ARGS+=" -L ${p}:localhost:${p}"
done

PORT_COUNT=$(echo $UNIQUE_PORTS | wc -w | tr -d ' ')

echo -e "\033[32mRunning SSH tunnel"
echo "  Target : $TARGET"
[ -n "$SSH_OPTS" ] && echo "  Options: $SSH_OPTS"
[ -n "$PORT_SPECS" ] && echo "  Ports  :$PORT_SPECS ($PORT_COUNT tunnels)"
echo -e "\033[0m"

eval ssh ${SSH_OPTS} ${PORT_ARGS} "${TARGET}"
