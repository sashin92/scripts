#!/usr/bin/env bash

set -e

PROMPT="Hi. Reply with OK only."
MODEL="haiku"
DEFAULT_TIMES=("06:00" "11:05") # KST
MARKER="# claude-cron"
SCRIPT="$(readlink -f "$0")"
LOG_FILE="$HOME/.local/state/claude-cron/claude-cron.log"

usage() {
  cat <<EOF
Usage: $(basename "$0") <command>

Run 'claude -p "$PROMPT" --model $MODEL' every day via cron.

Commands:
  on [HH:MM ...]
               Register daily cron jobs at the given KST times (default: ${DEFAULT_TIMES[*]})
               Running it again replaces the existing schedule.
  off          Remove the cron job
  status       Show the cron job and recent log
  run          Run claude once now (this is what cron calls)
  -h, --help   Show this help

Examples:
  $(basename "$0") on          # every day at 06:00 and 11:05 KST
  $(basename "$0") on 06:30    # every day at 06:30 KST
  $(basename "$0") on 06:00 11:05
  $(basename "$0") off

Log: $LOG_FILE
EOF
}

current_entry() {
  crontab -l 2>/dev/null | grep -F "$MARKER" || true
}

cmd_on() {
  local times=("$@")
  if [ "${#times[@]}" -eq 0 ]; then
    times=("${DEFAULT_TIMES[@]}")
  fi
  local kst
  for kst in "${times[@]}"; do
    if [[ ! "$kst" =~ ^([01]?[0-9]|2[0-3]):[0-5][0-9]$ ]]; then
      echo -e "\033[31mError: invalid time '$kst' (expected HH:MM)\033[0m"
      exit 1
    fi
  done

  # 👉 cron은 서버 타임존 기준이므로 KST 시각을 서버 시각으로 변환
  local min hour
  local lines=()
  for kst in "${times[@]}"; do
    read -r min hour < <(date -d "TZ=\"Asia/Seoul\" $kst" '+%-M %-H')
    lines+=("$min $hour * * * /bin/bash \"$SCRIPT\" run >> \"$LOG_FILE\" 2>&1 $MARKER KST=$kst")
  done

  mkdir -p "$(dirname "$LOG_FILE")"
  { crontab -l 2>/dev/null | grep -vF "$MARKER" || true; printf '%s\n' "${lines[@]}"; } | crontab -

  echo -e "\033[32mEnabled: every day at ${times[*]} KST\033[0m"
}

cmd_off() {
  if [ -z "$(current_entry)" ]; then
    echo -e "\033[33mAlready disabled\033[0m"
    return
  fi
  { crontab -l 2>/dev/null | grep -vF "$MARKER" || true; } | crontab -
  echo -e "\033[32mDisabled\033[0m"
}

cmd_status() {
  local entry
  entry="$(current_entry)"
  if [ -n "$entry" ]; then
    while IFS= read -r line; do
      echo -e "\033[32mEnabled: every day at ${line##*KST=} KST\033[0m"
      echo "  Cron: $line"
    done <<< "$entry"
  else
    echo -e "\033[33mDisabled\033[0m"
  fi

  if [ -f "$LOG_FILE" ]; then
    echo "  Log : $LOG_FILE (last 5)"
    tail -n 5 "$LOG_FILE" | sed 's/^/    /'
  fi
}

cmd_run() {
  # 👉 cron 환경은 PATH가 최소한이라 claude 설치 경로를 추가
  export PATH="$HOME/.local/bin:$PATH"
  local now out
  now="$(TZ=Asia/Seoul date '+%F %T KST')"
  if out="$(claude -p "$PROMPT" --model "$MODEL" 2>&1)"; then
    echo "[$now] OK: $out"
  else
    echo "[$now] FAILED (exit $?): $out"
    exit 1
  fi
}

case "${1:-}" in
  on) cmd_on "${@:2}" ;;
  off) cmd_off ;;
  status) cmd_status ;;
  run) cmd_run ;;
  -h|--help) usage ;;
  *) usage; exit 1 ;;
esac
