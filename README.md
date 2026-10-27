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
