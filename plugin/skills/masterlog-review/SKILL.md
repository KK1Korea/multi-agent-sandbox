---
name: masterlog-review
description: >
  MasterLog 항목을 True(실증 성공), Dummy(저가치/중복), Fail(실패 입증)로 분류하고
  해당 로그로 자동 이동한다. 세션 마무리 시 데이터 품질 유지를 위해 실행.
  Sonnet + 확장사고 사용.
version: 0.2.0
model: sonnet
---

# MasterLog Review & Auto-Classification

MasterLog 항목을 분류하고 해당 로그로 **자동 이동**하는 스킬.
사용자 승인 없이 분류 기준에 따라 즉시 처리한다.

## When to Use

- 샌드박스 토의 기록 후
- 프로젝트 주요 마일스톤 후
- 사용자가 MasterLog 정리 요청 시
- 세션 마무리 시 새 항목이 추가된 경우

## Prerequisites

Read the following files:
- `MasterLog.md` — 미분류 항목 (스테이징 영역)
- `True_Log.md` — 실증 검증된 사실
- `Dummy_Log/Dummy_Log_*.md` — 최신 Dummy 로그 파일
- `Fail_Log.md` — 실패 입증된 항목
- `current_task.md` — 현재 프로젝트 상태

## 파일 구조

```
CPAS/
├── MasterLog.md          ← 미분류 항목만 (스테이징 영역)
├── True_Log.md           ← 실증 성공 항목 (자동 승격)
├── Fail_Log.md           ← 실패 입증 항목 (자동 이동)
└── Dummy_Log/
    ├── Dummy_Log_1.md    ← 저가치/중복 항목 (1000줄 로테이션)
    ├── Dummy_Log_2.md    ← 1000줄 초과 시 새 파일
    └── ...
```

## Classification Protocol

### Step 1 — 전체 항목 스캔

MasterLog.md의 모든 항목을 읽는다. 각 항목에 대해 평가:
1. **실증 여부**: 벤치마크, 테스트, 로그 검증 등 경험적 검증이 있는가?
2. **결론의 성패**: 항목이 기술한 접근법/결론이 실제로 성공했는가, 실패했는가?
3. **현재 유효성**: 후속 항목에 의해 대체/무효화되었는가?
4. **정보 밀도**: 실질적 교훈이 있는가, 단순 기록에 불과한가?

### Step 2 — 분류

**★★★ 핵심 판정 기준: "기록이 정확한가?"가 아니라 "결론이 실증으로 검증됐는가?" ★★★**

#### True — 실증 성공만 (자동 → True_Log.md)

항목이 다음을 **모두** 충족:
  - 결론이 **경험적 증거**(벤치마크, 테스트, 로그 검증)로 **성공이 입증**됨
  - 후속 항목에 의해 모순되지 않음
  - 다른 항목과 중복이 아님
  - 현재 프로젝트 상태에서 여전히 유효

→ **자동 처리**: True_Log.md에 추가 + MasterLog.md에서 제거

**True 판정 금지 사례:**
  - 단순히 문서화가 정확한 것 (기록 정확성 ≠ 결론 검증)
  - 설계 결정이지만 아직 테스트 안 된 것
  - 실패를 기록한 항목 (실패 진단이 정확해도 → 진단의 실증이 별도로 필요)

#### Fail — 실패 입증 (자동 → Fail_Log.md)

항목이 다음 중 **하나라도** 해당:
  - 항목이 기술한 접근법이 후속 테스트/벤치마크에서 **실패**함
  - 결론이 후속 증거에 의해 **틀린 것으로 입증**됨
  - 기반 가정이 **거짓으로 판명**됨
  - 사실 오류가 포함됨

→ **자동 처리**: Fail_Log.md에 추가 + MasterLog.md에서 제거
→ Fail_Log 항목에는 **실패 사유 + 어떤 후속 항목이 실패를 입증했는지** 반드시 기재

**★ 중요: 실패 진단 항목 vs 실패한 접근법 항목 ★**
  - "X가 실패했다"는 진단 기록 → 진단 자체의 실증이 있으면 True 후보
  - "X를 하자"고 확정한 원본 항목 → 후속에서 X가 실패하면 Fail
  - 예시:
    · [16]이 "Observer가 루프 제어" 확정 → [17]에서 실패 입증 → [16]은 Fail
    · [17]이 "Observer가 에이전트 미스폰" 진단 → 트랜스크립트 로그로 검증됨 → [17]은 True 후보
  - 핵심: **실패한 접근법을 제안/확정한 항목이 Fail. 실패를 정확히 진단한 항목은 별개.**

#### Dummy — 저가치/중복 (자동 → Dummy_Log/)

항목이 다음 중 **하나라도** 해당:
  - 다른 항목과 중복 (어떤 항목인지 명시)
  - 결론이 자명/사소함
  - 정보 밀도가 낮음 (많은 텍스트, 적은 실질 내용)
  - 후속 항목에 의해 완전히 대체됨 (대체 항목 명시)

→ **자동 처리**: 최신 Dummy_Log 파일에 추가 + MasterLog.md에서 제거
→ Dummy_Log 파일이 1000줄 초과 시 새 파일 생성 (Dummy_Log_2.md, Dummy_Log_3.md...)

#### 미분류 — MasterLog에 잔류

  - 아직 실증 증거가 없는 설계 결정
  - 판단 근거가 불충분한 항목
  - 최근 추가되어 검증 시간이 부족한 항목

→ **처리 없음**: MasterLog.md에 그대로 유지
→ **경과 규칙**: 3세션 이상 미분류 상태로 남은 항목 → Dummy 후보로 플래그

### Step 3 — True_Log 교차 참조

True로 분류된 항목에 대해:
- 이미 True_Log에 있는가? → "이미 기록됨"으로 스킵
- True_Log 기존 항목과 충돌하는가? → **경고 출력** (둘 중 하나가 잘못됨)
- 신규 + 검증됨 → True_Log에 추가

### Step 4 — 자동 이동 실행

**이 단계가 핵심 — 분류 후 실제 파일 조작을 수행한다.**

1. True 항목: True_Log.md에 **원본 그대로** 추가 (누락/압축/요약 절대 금지)
2. Fail 항목: Fail_Log.md에 **원본 그대로** 추가 + 실패 사유 헤더 부착
3. Dummy 항목: 최신 Dummy_Log 파일에 **원본 그대로** 추가
4. MasterLog.md에서 이동된 항목 제거 (미분류 항목만 잔류)
5. 각 로그 파일의 헤더/메타데이터 갱신

### Step 5 — 결과 보고

```
=== MasterLog Review Report ===
Date: {date}
Entries reviewed: {total count}

── AUTO-MOVED TO TRUE_LOG ({count}) ──
[N] {entry title} — {실증 근거 1줄}

── AUTO-MOVED TO FAIL_LOG ({count}) ──
[N] {entry title} — {실패 사유 1줄} — 입증: [M]

── AUTO-MOVED TO DUMMY_LOG ({count}) ──
[N] {entry title} — {사유 1줄}
  → Superseded by / Redundant with: [M]

── REMAINS IN MASTERLOG ({count}) ──
[N] {entry title} — {미분류 사유 1줄}

=== Actions Taken ===
- True_Log: {N}건 추가
- Fail_Log: {N}건 추가
- Dummy_Log_{X}: {N}건 추가
- MasterLog: {N}건 잔류
=== END REPORT ===
```

## Important Rules

- **원본 보존 절대 원칙**: 항목 이동 시 내용을 누락/압축/요약하지 않는다. 글자 하나 바꾸지 않는다.
- **자동 이동**: 분류 즉시 해당 로그로 이동한다. 사용자 승인 불필요.
- **Dummy_Log 로테이션**: 현재 Dummy_Log 파일이 1000줄 초과 시 새 번호 파일 생성.
- **MasterLog = 스테이징**: 미분류 항목만 남긴다. 분류된 항목은 반드시 이동.
- **경과 규칙**: 3세션 이상 미분류 → Dummy 후보 플래그 (다음 리뷰에서 재평가).
- **MasterLog 용량 제한**: 최대 ~1500줄. 초과 시 가장 오래된 미분류 항목부터 Dummy로 강제 이동.
- **Fail ≠ True**: 실패한 접근법은 절대 True로 보내지 않는다. "기록이 정확하다"와 "결론이 성공했다"는 다르다.

## 볼륨 분할 규칙 (1500줄 제한)

모든 로그 파일은 **1파일 = 최대 1500줄** 규칙을 따른다.
항목 이동 전에 대상 파일의 줄 수를 확인하고, 초과 시 새 볼륨에 기록한다.

- **True_Log 분할**:
  - True_Log.md가 1500줄 초과 → True_Log.md를 True_Log_1.md로 이름 변경
  - 새 항목은 True_Log_2.md에 기록 (동일 헤더 포맷)
  - 이후 True_Log_2.md도 1500줄 초과 → True_Log_3.md 생성
  - 기존 True_Log.md가 이미 True_Log_1.md, True_Log_2.md... 으로 분할된 경우 → 가장 마지막 번호 파일에 추가

- **Fail_Log 분할**:
  - Fail_Log.md가 1500줄 초과 → 동일 패턴 (Fail_Log_1.md, Fail_Log_2.md...)

- **Dummy_Log 분할**:
  - 기존 규칙 유지 (1000줄 로테이션)

- **MasterLog**:
  - 볼륨 분할 안 함. 초과분 → Dummy로 강제 이동 (기존 규칙).

### 분할 시 확인 사항

1. 이동 전: `wc -l` 등으로 대상 파일의 현재 줄 수 확인
2. 1500줄 초과 예상 시: 새 볼륨 파일 생성 후 거기에 기록
3. 새 볼륨 파일 헤더: 원본 파일 헤더 복사 + "Volume N" 표기
4. 분할 사실을 결과 보고(Step 5)에 포함

### 범위 제한

- 이 스킬의 작업 범위는 **로그 파일 분류 및 이동만** 해당한다.
- GitHub push, 플러그인 재패키징, 외부 동기화 등은 이 스킬의 범위 밖이다.
- 범위 밖 작업이 필요하면 결과 보고에 "추가 작업 필요" 항목으로 명시하고 **실행하지 않는다.**
