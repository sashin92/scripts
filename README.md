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
