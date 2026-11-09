#!/bin/bash
# 사용법: umount-ssh.sh <host>   (mount-ssh.sh로 마운트한 host)

HOST="$1"
if [ -z "$HOST" ]; then
  echo "사용법: $(basename "$0") <host>"
  exit 1
fi

MOUNT_POINT="/Volumes/ssh-$HOST"
LINK="$HOME/ssh-$HOST"

if mount | grep -q " on $MOUNT_POINT "; then
  umount "$MOUNT_POINT" || { echo "언마운트 실패 (사용 중인 파일이 있는지 확인)"; exit 1; }
  echo "언마운트 완료: $MOUNT_POINT"
else
  echo "마운트되어 있지 않음: $MOUNT_POINT"
fi

if [ -L "$LINK" ]; then rm "$LINK"; fi
