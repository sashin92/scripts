# scripts

개인용 CLI 유틸리티 스크립트 모음. alias로 등록하여 사용합니다.

## 스크립트 목록

### ssh-tunnel.sh

SSH 포트 포워딩을 간편하게 설정하는 스크립트. 여러 포트를 한 번에 지정하거나, 범위로 지정할 수 있습니다.

**사용법:**

```bash
ssh-tunnel [ssh options] user@host -- [port|start:end]...
```

**예시:**

```bash
# 단일 포트
ssh-tunnel user@server -- 8080

# 여러 포트
ssh-tunnel user@server -- 3000 5432 6379

# 포트 범위
ssh-tunnel user@server -- 8080:8085

# SSH 옵션과 함께
ssh-tunnel -i ~/.ssh/mykey user@server -- 3000 5432
```

**alias 설정:**

```bash
alias ssh-tunnel='~/scripts/ssh-tunnel.sh'
```

### claude-cron.sh

`claude -p "Hi. Reply with OK only." --model haiku` 를 매일 정해진 시각(KST)에 실행하는 cron 배치를 켜고 끄는 스크립트. 서버 타임존이 달라도 KST 기준으로 변환해서 등록합니다.

**사용법:**

```bash
claude-cron on [HH:MM]   # cron 등록 (기본: 07:00 KST, 다시 실행하면 시각 변경)
claude-cron off          # cron 해제
claude-cron status       # 등록 현황 + 최근 실행 로그
claude-cron run          # 지금 한 번 실행 (cron이 호출하는 명령)
claude-cron --help
```

로그: `~/.local/state/claude-cron/claude-cron.log`

**alias 설정:**

```bash
alias claude-cron='~/scripts/claude-cron.sh'
```

### mount-ssh.sh / umount-ssh.sh

`~/.ssh/config`에 등록된 호스트의 원격 홈 디렉토리를 sshfs로 마운트/언마운트하는 스크립트. 접속 정보(주소, 계정, 키)는 모두 `~/.ssh/config`에서 가져옵니다.

**사용법:**

```bash
mount-ssh <host>     # 마운트 (이미 마운트돼 있으면 건너뜀)
umount-ssh <host>    # 언마운트 + 링크 삭제
```

| 항목 | 위치 |
|---|---|
| 마운트 위치 | `/Volumes/ssh-<host>` |
| 홈 바로가기 | `~/ssh-<host>` (심볼릭 링크) |
| 로그 | `~/Library/Logs/sshfs-<host>.log` |

**요구사항:**

- macOS 26 이상, macFUSE 5 이상 (`brew install --cask macfuse`), sshfs (`brew install gromgit/fuse/sshfs-mac`)
- 시스템 설정 → 일반 → 로그인 항목 및 확장 프로그램 → 파일 시스템 확장 프로그램에서 macFUSE 켜기
- 커널 확장 없이 FSKit 백엔드(`-o backend=fskit`)로 동작하므로 보안 수준을 낮출 필요가 없습니다.

**alias 설정:**

```bash
alias mount-ssh='~/scripts/mount-ssh.sh'
alias umount-ssh='~/scripts/umount-ssh.sh'
```
