# CPAS — 세션 시작 규칙

## 필수 읽기 순서
1. `current_task.md` — 사용자 현재 할 일 (최우선)
2. `.context/index.md` — 프로젝트 구조 + 주석 인덱스
3. 필요 시 `True_Log.md`, `MasterLog/` 참조

## 핵심 규칙
- 분기점 감지 시 토글 ON (index-agent 발동)
  - 트리거: 새 기능 추가 / 아키텍처 변경 / [폐기] 재등장 / Phase 전환
- 모든 작업은 MasterLog 기록 + 태그 필수
- 충돌/누락 감지 시 사용자에게 즉시 전달
  - "이전에 이 루트 폐기 판정됐는데, 다시 살리려는 건가요?"
  - "MasterLog [N]에서 유사한 문제가 있었는데 확인해볼까요?"
- 태스크 완료/변경 시 current_task.md 자동 갱신

## 상태 태그 5종
- [구상] — 아이디어 단계, 검증 전
- [진행] — 현재 작업 중
- [보류] — 조건부 중단 (부활 조건 명시)
- [폐기] — 근거 기반 종료 (폐기 사유 명시)
- [확정] — 검증 완료, 실행 확정

## MasterLog 기록 포맷
- 증상 → 원인 → 해결 → 교훈 구조
- 넘버링: [섹션-서브섹션] (예: [1-1], [1-2])
- 쌓기만 하고 수정하지 않는 영구 기록
- 누락/압축/요약 절대 금지

## MasterLog 정리 규칙
- cpas-manager 플러그인의 project-review 스킬이 수행 (/review 커맨드)
- 사용자가 사용 중인 모델이 그대로 실행 (모델 고정 없음)
- True_Log 잔류 기준: 핵심 검증사항 + 계속 참조 가능한 것만. 구버전/대체된 항목 → Dummy, 실패 확인 → Fail
- current_task.md의 [작업 버전] 히스토리 기반으로 구형 데이터 탐지

## GitHub Push 방법 (Cowork VM 환경)
Cowork VM은 세션마다 환경이 리셋되므로 gh CLI를 매번 설치 + 인증해야 함.

```bash
# 1. gh CLI 설치 (sudo 불가 환경)
mkdir -p ~/.local/bin
curl -L https://github.com/cli/cli/releases/download/v2.63.2/gh_2.63.2_linux_amd64.tar.gz -o /tmp/gh.tar.gz
tar -xzf /tmp/gh.tar.gz -C /tmp
cp /tmp/gh_2.63.2_linux_amd64/bin/gh ~/.local/bin/gh
chmod +x ~/.local/bin/gh
export PATH="$HOME/.local/bin:$PATH"

# 2. GitHub 웹 인증 (사용자 브라우저 필요)
gh auth login --web
# → 화면에 one-time code 출력됨
# → 사용자가 https://github.com/login/device 에서 코드 입력
# → 인증 완료 후 gh가 credential 저장

# 3. Push
cd github-repo
gh auth setup-git   # git credential helper 설정
git push origin main
```

- repo 위치: `github-repo/` (워크스페이스 루트 내)
- remote: `https://github.com/KK1Korea/multi-agent-sandbox.git`
- push 전 워크스페이스 파일 → repo 동기화 필요 (current_task.md, logs/, docs/ 등)
