# CPAS — 세션 시작 규칙

## 필수 읽기 순서
1. `current_task.md` — 사용자 현재 할 일 (최우선)
2. 필요 시 `True_Log.md`, `MasterLog/` 참조

## MasterLog 출처 신뢰도 마커
모든 MasterLog 엔트리에 출처와 신뢰도를 명시한다.
- ⚠ 사용자 판단 — 사용자가 직접 내린 판단. 검증 전.
- ⚠ 오케스트레이터 판단 — AI(오케스트레이터)가 내린 판단. 검증 전.
- ✓ 토의 검증 — 샌드박스 토의에서 양측 논거로 검증된 내용.
- ✓ 논문 인용 — WebSearch로 찾은 논문/자료를 인용한 근거.
- ✓✓ 교차 검증 — 복수 논문 또는 토의+논문으로 교차 확인된 내용.

마커는 엔트리 기록 시점에 붙이고, 이후 수정하지 않는다 (append-only 원칙 유지).
신뢰도가 올라가면 새 엔트리로 쌓는다 — 과거 엔트리를 소급 수정하지 않음.

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

## 태그 프로토콜 미출력 — 알려진 아키텍처 한계
- Advocate/Skeptic 모두 WebSearch를 많이 수행하면 첫 줄 태그(`[D-?] [R-?] [C-?] [A-?] [S-?]`)를 누락하는 경향이 있음.
- 이것은 에이전트 프롬프트 튜닝 문제가 아니라 **Cowork Agent SDK의 아키텍처 한계** — 에이전트가 도구 호출 후 출력을 재개할 때 프리앰블(사고 과정, 검색 결과 정리 등)을 먼저 쓰고 태그를 빠뜨림.
- 오케스트레이터는 태그 미출력 시 내용에서 추정하여 기록. 토의 품질 판정에서 태그 미출력 자체를 감점하지 않음.
- 근본 해결은 Agent SDK 수준의 출력 포맷 강제가 필요하며, 프롬프트 수정으로는 해결 불가.

## README.md 업데이트 금지
- `github-repo/README.md`는 **절대 수정하지 않는다.**
- 사유: 연구 중단 선언 상태 (v0.9.9에서 동결). 개발은 계속하지만 README는 포기. (⚠ current_task.md 및 cpas-manager.plugin, cpas-sandbox.plugin 이외는 절대 수정금지.)
- 최신 버전 정보는 `current_task.md` [작업 버전] 및 플러그인 plugin.json 참조.

## GitHub Push 방법 (Cowork VM 환경)
Cowork VM은 세션마다 환경이 리셋되므로 gh CLI 설치는 매번 필요.
단, 인증은 한번 완료된 채팅방(세션) 내에서는 유지됨 — **push/commit 실패 시에만 인증 절차 수행**.

```bash
# 1. gh CLI 설치 (sudo 불가 환경 — 매 세션 필요)
mkdir -p ~/.local/bin
curl -L https://github.com/cli/cli/releases/download/v2.63.2/gh_2.63.2_linux_amd64.tar.gz -o /tmp/gh.tar.gz
tar -xzf /tmp/gh.tar.gz -C /tmp
cp /tmp/gh_2.63.2_linux_amd64/bin/gh ~/.local/bin/gh
chmod +x ~/.local/bin/gh
export PATH="$HOME/.local/bin:$PATH"

# 2. Push 시도
cd github-repo
gh auth setup-git
git push origin main

# 3. push 실패 시 → 인증 절차 (사용자 브라우저 필요)
gh auth login --web
# → 화면에 one-time code 출력됨
# → 사용자가 https://github.com/login/device 에서 코드 입력
# → 인증 완료 후 gh가 credential 저장
# → 다시 push 시도
```

- repo 위치: `github-repo/` (워크스페이스 루트 내)
- remote: `https://github.com/KK1Korea/multi-agent-sandbox.git`
- push 전 워크스페이스 파일 → repo 동기화 필요 (current_task.md, logs/, docs/ 등)
