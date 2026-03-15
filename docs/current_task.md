# current_task.md

## [작업 버전]
v0.9.11 : 내부 데이터 무결성 검사(Internal Data Integrity Check). 교환 간 {FILTERED_DATA} 대비 내부 인용 존재 여부 확인. 양방향 대칭 + 자정작용 우선 + 내용 불간섭. 원인: v0.9.4 Accept→Redirect→Propose가 Advocate의 인용 검증 능력 약화 → Skeptic 환각(Episode) Type-X 미감지 ([33]). Haiku 필터 무관 확인.
v0.9.10 : Skeptic/Advocate 태그 프리앰블 누락 수정. O-2-1에 "CRITICAL — NO PREAMBLE" 강제 + "Your first character must be [" 리마인더. 원인: 도구 호출(WebSearch) 후 프리앰블이 태그를 밀어냄 — Skeptic 메타 질문으로 진단. 양쪽 에이전트 적용.
v0.9.9 : 태그 비대칭화 + D-temperature 1-13축 표준화. Advocate R 1-19 확장 (주제 추적 세분화), Skeptic C 1-19 확장 (반증/검증 범위 확장), Skeptic A 앵커 역할 맞춤 재정의 (Rebuttal Intensity), Advocate A 앵커 유지 (Assertion Strength). 역할별 태그 프로토콜 분리. D-temperature 1-13축 표준화: 상승형(R,A) 1~5/3~9/7~13, 하강형(C) 9~13/5~11/1~7 — M구간 7칸으로 넓혀 좁은 스케일 표현력 확보. D-Q 공세 추격 단계 추가 (세션당 ≤1회, 최후의 진술 전용). 한글 프롬프트 v0.9.9 동기화 완료.
v0.9.8 : 2세션 16턴 구조 (탐색전 8T + 공방전 8T), 최후의 진술 세션당 2턴, 세션 1 결론→세션 2 주입, S≤4 불균형 감지 1턴으로 강화, Skeptic O-1-2 WebSearch 필수 명시
v0.9.7 : 8턴 포맷 (6T+최후의진술 2T), Output Example→Condition 포맷, Skeptic WebSearch Condition 강화, 한글 프롬프트 v0.9.7 동기화
v0.9.6 : Skeptic 태그 미출력 수정 완료 (OUTPUT FORMAT 주입), plugin.json 누락 방지 (build-plugin.sh + plugin-meta-backup.json), GitHub repo v0.9.6 동기화
v0.9.5 : Skeptic 필수 WebSearch(턴당 1+), research_queue 자동 업데이트, Fail_Log 비대칭 폐기, v0.9.4 벤치마크 완료
v0.9.4 : Advocate 재설계 — 방향 앵커({CURRENT_DIRECTION}), Partial Acceptance Protocol(Accept→Redirect→Propose), 프로젝트 추진자 역할
v0.9.3 : cpas-manager 플러그인 분리, masterlog-review → project-review 독립, 불균형 개입 사용자 승인, stale check, current_task 버전 추적
v0.9.2 : Data-Filter 3분할, Opus 벤치마크 2회 완료 (388K/524K 토큰), 볼륨 분할 규칙, API 비용 추산
v0.9.1 : Data-Filter 3분할 초안, 기존 data-filter.md 레거시 보존
v0.9.0 : Observer 제거, 2-level 아키텍처, Cowork_CPAS 분리, 서브에이전트 도구 실증
v0.6.0 : Observer 루프 제어 첫 벤치마크 → 실패 (미스폰 [17])
v0.5.0 : 열세 감지, 메모리 경계 주입
v0.4.0 : Haiku 데이터 필터, masterlog-review 스킬, workspace-init
v0.3.0 : 시스템 개입 제거, 고정 섹션 구조
v0.2.0 : 태그 스펙트럼 확장 (R,C,A:1-13 / S:1-19), D Ref 태그
v0.1.0 : 초기 플러그인 — Advocate/Skeptic/Observer 프롬프트, 5축 태그 시스템

## [현재 상황]
Phase A — Cowork_CPAS v0.9.11 [구상]. 6대 쟁점 통합 토의([37]) + 지식 결정화 파이프라인 재토의([38]) 완료. [37]은 합의 미달(S-7 동등), [38]은 부분 수렴 달성 — Skeptic이 TERMINATE에서 "조건부 진행"으로 전환. Track A→B→C 순서 합의, noise floor 독립성만 미합의. 태그 프리앰블 누락 지속 확인 (Skeptic 대부분 미출력). 지식 결정화 파이프라인 발견 → CPAS = RAG/CAG + MAD + 지식 환류 순환 프레이밍 확립. MeMAD 대비 차별점: episodic vs iterative-crystalline.

## [지금 해야 할 일]
1. [RQ-1] 4차 실험 + Opus 단독 비교 완료 (MasterLog [33]). **양측 합의: 양방향 교차 교정은 구조적 속성**. **미합의: 충분성 범위**. 3-track 테스트 설계 합의(Track A/B/C). CPAS 고유 가치 최종: (1) R축 수렴 강제력, (2) 양방향 교차 교정(구조적 확정), (3) 반론 검증 robustness, (4) Type-X 자기발견. (HIGH — 구조적 속성 확정, 충분성 미해결)
2. [RQ-2] mixed→clear 전환 가능성 — 전환 증거 3건 전부 성공, 자연 축적 데이터로 전환율 정밀화 필요 (HIGH)
3. [RQ-7] Path B (사후 블랙박스 모니터링) 확정. 남은 과제: n=5 실증, between-episode 피드백 검증. (MEDIUM — 방향 확정, 실증 미완)
3-1. [RQ-9] 3-track 테스트 설계 합의 + v0.9.11 내부 데이터 무결성 검사 적용 완료. 사용자 확인 필요: 테스트 규모, salience flags 포함 여부. (HIGH)
4. [RQ-4] 하위 모델(Sonnet/Haiku) 토의 에이전트 품질 하한선 벤치마크 (MEDIUM)
5. [RQ-5] Choice B 기본 경로, 20주 순차 계획 ($99K) 합의 (MEDIUM)
6. **[MasterLog [38] 사용자 결정 대기]**:
   - Track C gate에 held-out clean reference set 감사 추가 여부? (Skeptic 수렴 조건)
   - 반증 기준: 15% vs 20% incremental precision?
   - Track A 예산/일정 확정 ($15K, 4주)?
   - MasterLog [27]-[37] 방법론 논문 출판 병행?
7. [태그 누락] v0.9.10 수정 적용했으나 실전 검증에서 Skeptic 대부분 미출력 지속. 프리앰블 문제 근본 해결 미달 — 추가 대책 필요. (MEDIUM)
8. ~~[v0.9.6] Skeptic 태그 미출력 수정~~ — 완료 (DONE)
9. ~~[D-3] ASMR 토의~~ — 취소 (CANCELLED)

## [로그 현황]
- True_Log: [1][2][3][4][5][7][10][11][13][14][15][17][19][20][21][22][23][24][27][31][32][34] (22건)
- Fail_Log: [16][18] (2건)
- Dummy_Log: [6][8][9][12][29][30] (6건) — [29][30]은 D-5/D-2 토의 상세 원본 (TTS 외부 데이터)
- MasterLog: [25][26][28][29→RQ-2종합][30][31][33][34][35][36][37][38] (12건 — 전부 [구상]) — [35] v0.9.11 설계, [36] 6대 쟁점 입력 메모, [37] 6대 쟁점 통합 토의 결과+메타 관찰, [38] 지식 결정화 파이프라인 재토의 결과
- Research Queue: RQ-1~RQ-9 (9건 — HIGH 3, MEDIUM 4) + RQ-10~RQ-13 후보 + RQ-14~RQ-15 후보

## [진행도]
Phase A: ████████████████████ 98%
  - 설계: ████████████████████ 100% (Cowork_CPAS v0.9.11 — 데이터 무결성 검사, NO PREAMBLE, 2세션 16턴, 비대칭 태그, D-temperature 표준화, D-Q)
  - 플러그인 패키징: ████████████████████ 100% (cpas-sandbox v0.9.11 + cpas-manager v1.0)
  - 벤치마크: ████████████████████ 100% (10회 완료 — 외부1, 내부1, v0.9.4 비교1, RQ-1 비교3, RQ-7 토의1, RQ-1+9 토의1, 6대 쟁점1, 재토의1)
  - 데이터 품질: ████████████████░░░░ 80% (True_Log 감사 완료, project-review 분리)
  - 튜닝: ███████████████░░░░░ 75% (불균형 보고 사용자 승인, Advocate 재설계, Skeptic WebSearch, 태그 프리앰블 수정, 데이터 무결성 검사 — 하위 모델 미착수, 태그 프리앰블 근본 해결 미달)
  - 검증: ██████████████████░░ 85% (RQ-1 4차 완료, RQ-2 완료+D-3 취소, RQ-5 부분 해결, RQ-7 Path B 확정, RQ-9 3-track+v0.9.11, [37]+[38] 존속 토의 2회 완료, RQ-4 미착수)

## [최종 갱신] 2026-03-15 세션 #18 (MasterLog [38] — 지식 결정화 파이프라인 재토의, 부분 수렴)
