#!/bin/bash
# 사용법: mount-ssh.sh <host>   (<host>는 ~/.ssh/config의 Host 이름)
# 원격 계정의 홈 디렉토리를 /Volumes/ssh-<host>에 마운트하고 ~/ssh-<host> 링크 생성

HOST="$1"
if [ -z "$HOST" ]; then
  echo "사용법: $(basename "$0") <host>"
  exit 1
fi

MOUNT_POINT="/Volumes/ssh-$HOST"
LINK="$HOME/ssh-$HOST"
LOG="$HOME/Library/Logs/sshfs-$HOST.log"

if [ -e "$LINK" ] && [ ! -L "$LINK" ]; then
  echo "$LINK 가 이미 있고 링크가 아님. 확인 필요"
  exit 1
fi

is_mounted() { mount | grep -q " on $MOUNT_POINT "; }

if is_mounted; then
  echo "이미 마운트됨: $MOUNT_POINT"
else
  # FSKit 백엔드는 마운트 후 fork를 지원하지 않으므로 -f(포그라운드)로 띄우고 nohup으로 백그라운드 실행
  nohup sshfs "$HOST:" "$MOUNT_POINT" -o backend=fskit -f > "$LOG" 2>&1 &
  for _ in $(seq 20); do
    is_mounted && break
    sleep 0.5
  done
  if ! is_mounted; then
    echo "마운트 실패. 로그: $LOG"
    exit 1
  fi
fi

ln -sfn "$MOUNT_POINT" "$LINK"
echo "마운트 완료: $LINK -> $MOUNT_POINT"
