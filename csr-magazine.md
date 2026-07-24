---
name: csr-magazine
description: 카카오톡 대화 파일을 읽어서 올댓CSR 매거진 HTML을 생성합니다
argument-hint: [카카오톡 대화 파일 또는 폴더 경로]
allowed-tools: Read, Glob, Write, Bash
---

아래 경로의 카카오톡 대화 파일을 읽어서 올댓CSR 매거진 HTML을 생성해주세요.

파일 경로: $ARGUMENTS

## 중요 주의사항
- **같은 폴더의 매거진 업데이트 요청 시 기존 파일을 Edit으로 수정할 것.** 이미 생성된 매거진을 덮어쓰거나 새로 Write하지 않는다. (새로운 주차 매거진은 당연히 Write로 생성)
- **큐레이션 그룹 수를 줄이지 말 것.** 기존 매거진에 3개 그룹이 있으면 3개 유지. 콘텐츠가 적더라도 그룹을 삭제하지 않는다.
- **채팅방별 색상은 큐레이션 카드와 기여자 칩에서 반드시 동일하게 적용할 것.** (아래 '채팅방별 색상 체계' 참조)
- **정책 브리핑은 단일 `<details>`로 전체 기간을 감쌀 것.** 날짜별 개별 `<details>` 금지.

## 작업 순서
1. 경로가 폴더인 경우 Glob으로 파일 목록을 확인하세요
2. **날짜 필터링**: 사용자에게 "몇 일부터 몇 일까지의 대화를 매거진으로 만들까요?" 라고 물어보세요. 답변을 받으면 `chat_filter.py` 스크립트로 해당 날짜 범위만 추출합니다:
   ```
   python3 ~/all_that_csr/chat_filter.py [폴더경로] [시작일 YYYY-MM-DD] [종료일 YYYY-MM-DD]
   ```
   필터링 후 `[폴더경로]/filtered/` 폴더의 파일을 사용합니다. 이후 작업은 모두 filtered 폴더 기준으로 진행하세요.
3. 폴더 안의 **모든 PDF 파일**을 Read 도구로 읽어서 요약 품질 향상에 활용하세요 (HWP는 읽을 수 없으니 PDF 변환 요청). PDF는 원본 폴더에서 읽으세요.
4. 폴더 안의 **모든 JPG/PNG 이미지 파일**도 Read 도구로 읽으세요. 대화에서 "사진 N장"으로 공유된 이미지(정책 브리핑, 포스터 등)가 포함되어 있으며, 매거진 콘텐츠에 반영해야 합니다.
5. 필터링된 카카오톡 대화 파일(.txt)을 Read 도구로 읽으세요
6. 대화 내용을 분석해서 ESG·CSR 관련 주요 콘텐츠를 추출하세요
7. 아래 규칙에 따라 HTML을 생성하세요
8. 생성된 HTML은 `매거진_[시작일]_[종료일].html` 파일명으로 **원본 폴더**에 Write 도구로 저장하세요
9. 아래 썸네일 템플릿을 사용하여 `thumbnail.html` 파일도 같은 폴더에 함께 생성하세요 (헤드라인·호수·배경이미지는 매거진과 동일하게)

## 대화 파싱 규칙
- 형식: "날짜/시간, 이름(소속) : 메시지"
- 제외: `<사진 읽지 않음>`, 입장/퇴장 시스템 메시지, 방장봇 안내, "메시지가 삭제되었습니다"
- 포함: 행사/공모전 안내, 채용 공고, 뉴스 기사 링크, 보고서·연구자료, 커뮤니티 활동 공유

## 콘텐츠 분류
- **중복 링크 제거**: 여러 채팅방에서 같은 URL이 공유된 경우 1번만 노출 (먼저 공유된 채팅방 기준)
- **주간 하이라이트**: 후속 대화(댓글/반응)가 가장 많은 기사 2개 → 히어로 카드
- **커뮤니티 큐레이션**: 나머지 링크/콘텐츠 → 큐레이션 카드 (URL이 있는 기사만)
  - **15개 이하**: 플랫 리스트로 출력
  - **15개 초과**: 채팅방별 `<details>/<summary>` 그룹핑 적용 (JS 없이 HTML 네이티브, 채팅방 이름은 대화 파일 첫 줄에서 추출). 전체방(1500명+ 메인 채팅방)은 "올댓CSR 전체"로 표기하고 **반드시 첫 번째 그룹**으로 배치. 나머지 소그룹은 사회공헌 → 지속가능경영 → 임팩트투자 순서로 고정.
- **놓치지 마세요**: 공모전, 채용, 행사, 캠페인 등 비기사 콘텐츠 → 액션 카드 (URL이 있는 항목만 포함, URL 없는 항목은 제외)
- **공유된 자료**: PDF 파일 기반 콘텐츠 → 큐레이션에 넣지 않고, 놓치지 마세요 아래에 별도 배치
- **주간 정책 브리핑**: 이미지(JPG/PNG) 또는 PDF로 공유된 정부 브리핑 자료(행정안전부 지방행정 여론·동향, 정책보도 일일종합 등) → 텍스트만 요약하여 별도 코너로 배치 (놓치지 마세요와 공유된 자료 사이). PDF로 공유된 정책 브리핑은 공유된 자료 섹션에 중복 노출하지 않는다.

## 통계 수집
대화에서 다음을 직접 세어 헤더에 표시하세요:
- 총 메시지 수 (시스템 메시지 제외)
- 링크(URL) 포함 메시지 수
- 큐레이션 카드 개수

## 채팅방별 색상 체계 (큐레이션 카드 + 기여자 칩 공통)
큐레이션 카드의 배경·테두리·원문읽기 링크 색상과 기여자 칩의 dot·배경·테두리 색상은 **동일한 채팅방 색상**을 사용한다. 반드시 아래 매핑을 따를 것.

| 채팅방 | 테마색 | 카드 배경 | 카드 border | 원문읽기/summary | 칩 배경 rgba | 칩 border rgba |
|--------|--------|-----------|-------------|-----------------|-------------|---------------|
| 올댓CSR 전체 | #71c168 (초록) | #f7faf7 | #d4e8d4 | #71c168 | rgba(113,193,104,0.08) | rgba(113,193,104,0.25) |
| 사회공헌 | #0195df (파랑) | #f5f9fd | #d7e8f5 | #0195df | rgba(1,149,223,0.08) | rgba(1,149,223,0.25) |
| 지속가능경영 | #e6be00 (노랑) | #fefcf3 | #f0e4b8 | #e6be00 | rgba(230,190,0,0.08) | rgba(230,190,0,0.3) |
| 임팩트투자 | #FF5C35 (주황) | #fef5f2 | #f5ddd5 | #FF5C35 | rgba(255,92,53,0.08) | rgba(255,92,53,0.25) |

**적용 위치:**
- 큐레이션 그룹 `<summary>`: `style="color: [테마색];"` 인라인 적용
- 큐레이션 그룹 토글 버튼: `style="background: [테마색];"` 인라인 적용
- 큐레이션 카드 div: `background: [카드 배경]; border: 1px solid [카드 border]` 인라인 적용
- "원문 읽기 →" 링크: `color: [테마색]` 인라인 적용
- 기여자 칩: dot `background: [테마색]`, 칩 `background: [칩 배경 rgba]; border-color: [칩 border rgba]`

## 공유자(Contributors) 수집
콘텐츠를 공유한 사람들의 이름과 소속을 추출해서 함께 해주신 분들 섹션에 표시하세요.
각 공유자는 해당 콘텐츠가 공유된 채팅방의 색상을 부여하세요 (위 채팅방별 색상 체계 참조).

## 이미지 규칙
- 히어로 카드 썸네일: Unsplash URL 사용 (`https://images.unsplash.com/photo-[ID]?w=640&h=400&fit=crop`), 요약 내용과 연관된 이미지 매칭
- 큐레이션 카드 썸네일: Unsplash URL 사용 (`https://images.unsplash.com/photo-[ID]?w=640&h=360&fit=crop`), 요약 내용과 연관된 이미지 매칭
- 헤더 배경 이미지: 해당 주차 콘텐츠 주제와 연관된 Unsplash 이미지 사용
- 로고: `https://raw.githubusercontent.com/all-that-csr/asset/main/logo/logo-typeB.png`
- PDF 자료: 중요한 PDF는 GitHub 레포에 push 후 다운로드 URL 생성
  - 레포: `all-that-csr/asset` (gh auth로 all-that-csr 계정 활성 상태여야 함)
  - 폴더 구조: `[YYMMDD]/pdf/[파일명]`
  - URL 패턴: `https://raw.githubusercontent.com/all-that-csr/asset/main/[YYMMDD]/pdf/[URL인코딩된 파일명]`
  - push 전 `gh auth status`로 all-that-csr 계정 활성 확인, 아니면 `gh auth switch --user all-that-csr`

## 섹션별 색상 체계 (로고 C·S·R 색상 순서)
| 섹션 | 테마색 | 카드 배경 | 카드 border | 원문읽기/강조 |
|------|--------|-----------|-------------|--------------|
| 주간 하이라이트 | #0195df (파랑) | #f5f9fd | #d7e8f5 | #0195df |
| 커뮤니티 큐레이션 | #e6be00 (노랑) | #fefcf3 | #f0e4b8 | #e6be00 |
| 놓치지 마세요 | #71c168 (초록) | #f7f9f7 | #e2ece2 | #71c168 |
| 주간 정책 브리핑 | #5a6a7a (회색) | #f4f6f8 | #dde2e8 | #5a6a7a |
| 함께 해주신 분들 | #FF5C35 (주황) | — | — | #FF5C35 |

## 디자인 — v2 카카오풍 (표준, Vol.17~)

**디자인 원본은 `~/all_that_csr/templates/v2_kakao/` 이다.** 이 폴더의 빌더 스크립트로 생성한다. (기존 에디토리얼 디자인 대체)
- `assemble.py` — CSS + 전체 레이아웃 + 콘텐츠 조립 (**source of truth**)
- `build_curation.py` — 큐레이션 카드 데이터 빌더
- `example_260724.html` — 완성 레퍼런스 · `design.css` — CSS만 · `README.md` — 상세 설명

### 생성 방법
1. `build_curation.py`, `assemble.py`를 이번 세션 스크래치패드로 복사한다.
2. 두 스크립트 상단의 절대경로 상수(OUT, CUR 및 스크래치패드 경로)를 이번 세션 경로로 수정한다.
3. 콘텐츠 데이터를 이번 호 내용으로 교체한다:
   - `build_curation.py`: `G_ALL` / `G_SOC` / `G_SUS` / `G_IMP` — 채팅방별 큐레이션 카드. 각 항목 `(kind, span, tag, title, summary, who, url, img)`. kind: v(세로)·h(전폭)·f(채움). `normalize()`가 6칸 그리드 빈칸을 막으므로 전폭카드 위치(hpos)만 지정.
   - `assemble.py`: `HERO`(히어로2 + 카톡 말풍선2), `CHOICE`(대화요약 4), `ACTIONS` + `SPECIAL_MISS`(놓치지 마세요), `FILES`(공유된 자료), `POLICY_DAYS`(정책 브리핑), `CONTRIB`(기여자), 마스트헤드 통계·Vol·기간, 커버 헤드라인·이미지.
4. `python3 build_curation.py && python3 assemble.py` 실행 → 매거진 HTML 생성.
5. 검증: 태그 균형(div/a/details open==close), Unsplash 이미지 200, 그리드 빈칸 0, 큐레이션/자료 URL 정합성(전수 fetch).

### 디자인 핵심
- **폰트**: 제목·숫자 = 나눔스퀘어라운드(NanumSquareRound EB/B, jsdelivr), 본문 = Pretendard Variable **동적 서브셋**. 세리프(Noto Serif) 금지.
- 흰 배경 + 연회색(#f5f6fa~#f7f8fb) **라운드 카드**(radius 14~18), 부드러운 그림자, **좌측 색띠 없음**.
- **채팅방 4색 유지**: 올댓전체 #71c168 / 사회공헌 #0195df / 지속가능경영 #e6be00 / 임팩트투자 #FF5C35. 카드 틴트·태그 pill·아바타·꼬리에 사용 (ROOM 딕셔너리 참조).
- **섹션 헤딩 중앙정렬**: 영문 kicker(색) 위 + 한글 제목. 상단 괘선 없음.
- **컨테이너 max-width: 800px** (클랩 게시 폭). 반응형 3단계: **≥820px 3열 / 521~819px 2열 / ≤520px 1열** + 모바일 본문 폰트 확대(어르신 가독성).

### 구조 순서 (위 → 아래)
1. **커버(키비주얼)** — 맨 위, 풀블리드. 헤드라인 + 서브카피.
2. **헤더 카드** — 로고 + 제목 + 태그라인 / 구분선 / 통계(좌) · 발행정보(우). **단일 배경**.
3. **주간 하이라이트** — 히어로 모자이크(리드 카드 2 + 카톡 **말풍선** 타일 2). 말풍선은 채팅방색 틴트 + 꼬리(좌우/모바일 위아래).
4. **이번 주 대화 요약** — 채팅방 4색 틴트 카드 + 흰 말풍선 인용.
5. **커뮤니티 큐레이션** — 모자이크(세로/전폭/채움 카드 혼합), details 4그룹.
6. **놓치지 마세요** — 2열 카드형(상/하 레이아웃), 모바일 1열. 첫 카드 초록 채움.
7. **공유된 자료** — 가로 리스트 row.
8. **주간 정책 브리핑** — 단일 details. **공유된 자료 아래**.
9. **함께 해주신 분들** — 칩.
10. **푸터** — 밝은 회색.

### 전체 CSS (자립 참고용 — 빌더가 없을 때 이 CSS로 재현)

```css

@import url('https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.css');
@font-face {
  font-family: 'NSquareRound';
  src: url('https://cdn.jsdelivr.net/gh/fonts-archive/NanumSquareRound/NanumSquareRoundEB.woff2') format('woff2');
  font-weight: 800; font-style: normal; font-display: swap;
}
@font-face {
  font-family: 'NSquareRound';
  src: url('https://cdn.jsdelivr.net/gh/fonts-archive/NanumSquareRound/NanumSquareRoundB.woff2') format('woff2');
  font-weight: 700; font-style: normal; font-display: swap;
}

.atcsr-wrap * { box-sizing: border-box; margin: 0; padding: 0; }
.atcsr-wrap {
  font-family: 'Pretendard Variable', Pretendard, 'Noto Sans KR', sans-serif;
  background: #ffffff; color: #1f2024; letter-spacing: -0.2px;
  overflow-wrap: break-word; word-break: keep-all;
}
.atcsr-wrap a { text-decoration: none; color: inherit; }
.atcsr-wrap img { display: block; max-width: 100%; object-fit: cover; }
.atcsr-inner { max-width: 800px; margin: 0 auto; background: #ffffff; }
.atcsr-body { padding: 0 20px 30px; }
.atcsr-round { font-family: 'NSquareRound', 'Pretendard Variable', sans-serif; }

/* ── 마스트헤드 ── */
.atcsr-mast { background: #f7f8fb; border-radius: 16px; margin: 18px 18px 0; padding: 18px 20px; }
.atcsr-mast-top { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
.atcsr-mast-brand { display: flex; align-items: center; gap: 11px; }
.atcsr-mast-logo { width: 46px; height: auto; flex-shrink: 0; }
.atcsr-mast-word { font-family: 'NSquareRound', sans-serif; font-weight: 800; font-size: 18px; letter-spacing: 0.3px; color: #1f2024; }
.atcsr-mast-sub { font-size: 11.5px; color: #9096a4; margin-top: 3px; }
.atcsr-mast-issue { text-align: right; flex-shrink: 0; }
.atcsr-issue-vol { font-family: 'NSquareRound', sans-serif; font-weight: 800; font-size: 16px; color: #FF5C35; letter-spacing: 0.5px; }
.atcsr-issue-date { font-size: 11px; color: #9096a4; margin-top: 3px; }
.atcsr-mast-line { height: 1px; background: #e6e8ef; margin: 15px 0; }
.atcsr-mast-stats { display: flex; align-items: center; justify-content: center; gap: 18px; }
.atcsr-stat { display: flex; flex-direction: column; align-items: center; }
.atcsr-stat b { font-family: 'NSquareRound', sans-serif; font-weight: 800; font-size: 19px; line-height: 1; }
.atcsr-stat span { font-size: 10px; color: #9096a4; margin-top: 5px; }
.atcsr-stat-div { width: 1px; align-self: stretch; background: #e2e5ec; margin: 2px 0; }

/* ── 커버 ── */
.atcsr-cover { position: relative; height: 215px; overflow: hidden; }
.atcsr-cover img { width: 100%; height: 100%; }
.atcsr-cover-shade { position: absolute; inset: 0; background: linear-gradient(180deg, rgba(0,0,0,0.2) 0%, rgba(0,0,0,0.28) 45%, rgba(0,0,0,0.78) 100%); }
.atcsr-cover-cap { position: absolute; left: 0; right: 0; bottom: 0; padding: 26px 26px 24px; text-align: center; }
.atcsr-cover-h1 { font-family: 'NSquareRound', sans-serif; font-weight: 800; font-size: 36px; line-height: 1.42; letter-spacing: -1px; color: #fff; text-shadow: 0 2px 14px rgba(0,0,0,0.4); }
.atcsr-cover-lede { font-size: 14px; color: rgba(255,255,255,0.82); line-height: 1.75; margin-top: 13px; }

/* ── 섹션 헤딩 (중앙정렬) ── */
.atcsr-sec { text-align: center; margin-top: 62px; margin-bottom: 24px; }
.atcsr-sec-en { font-size: 12px; font-weight: 700; letter-spacing: 2px; margin-bottom: 9px; }
.atcsr-sec-ko { font-family: 'NSquareRound', sans-serif; font-weight: 800; font-size: 28px; line-height: 1.35; letter-spacing: -0.9px; color: #1f2024; }
.atcsr-sec-desc { font-size: 14.5px; color: #8b90a0; margin-top: 10px; line-height: 1.65; }

/* ── 공통 ── */
.atcsr-tag { display: inline-flex; align-items: center; gap: 4px; font-size: 12.5px; font-weight: 700; border-radius: 20px; padding: 5px 12px; line-height: 1.5; }
.atcsr-c-f .atcsr-tag { color: #fff; background: rgba(255,255,255,0.22); }
.atcsr-btn { display: inline-block; font-size: 12.5px; font-weight: 700; color: #fff; border-radius: 20px; padding: 7px 16px; white-space: nowrap; }
.atcsr-arrow { font-size: 12px; font-weight: 700; white-space: nowrap; flex-shrink: 0; border-radius: 20px; padding: 5px 11px; }

/* ── 모자이크 그리드 ── */
.atcsr-grid { display: grid; grid-template-columns: repeat(6, 1fr); gap: 15px; }
.s2 { grid-column: span 2; } .s3 { grid-column: span 3; } .s4 { grid-column: span 4; } .s6 { grid-column: span 6; }

/* ── 카드 ── */
.atcsr-c { background: #fff; border-radius: 18px; box-shadow: 0 2px 14px rgba(24,28,45,0.07); display: flex; flex-direction: column; }
.atcsr-c > a, .atcsr-c > div { display: flex; flex-direction: column; flex: 1; padding: 12px; }
.atcsr-wrap img.atcsr-c-img { width: 100%; height: 138px; border-radius: 12px; }
.atcsr-c-body { padding: 14px 6px 4px; display: flex; flex-direction: column; flex: 1; }
.atcsr-c-title { font-family: 'NSquareRound', sans-serif; font-weight: 700; font-size: 17px; line-height: 1.52; letter-spacing: -0.5px; color: #1f2024; margin: 9px 0 8px; }
.atcsr-c-sum { font-size: 14px; color: #7a7f8d; line-height: 1.85; margin-bottom: 13px; flex: 1; }
.atcsr-c-sum strong { color: #3d4250; font-weight: 700; }
.atcsr-c-meta { display: flex; align-items: center; justify-content: space-between; gap: 8px; font-size: 12px; color: #a9adb9; }
/* 가로 피처 */
.atcsr-c-h > a, .atcsr-c-h > div { flex-direction: row; gap: 4px; }
.atcsr-wrap .atcsr-c-h img.atcsr-c-img { width: 220px; min-width: 220px; height: auto; align-self: stretch; }
.atcsr-c-h .atcsr-c-body { padding: 8px 10px 6px 16px; }
.atcsr-c-h .atcsr-c-title { font-size: 21px; }
/* 채움 */
.atcsr-c-f { box-shadow: 0 4px 18px rgba(24,28,45,0.16); }
.atcsr-c-f .atcsr-c-title { color: #fff; }
.atcsr-c-f .atcsr-c-sum { color: rgba(255,255,255,0.85); }
.atcsr-c-f .atcsr-c-sum strong { color: #fff; }
.atcsr-c-f .atcsr-c-meta { color: rgba(255,255,255,0.7); }

/* ── 히어로 ── */
.atcsr-h-img { position: relative; height: 186px; overflow: hidden; border-radius: 12px; }
.atcsr-h-img img { width: 100%; height: 100%; }
.atcsr-h-shade { position: absolute; inset: 0; background: linear-gradient(0deg, rgba(0,0,0,0.72) 0%, rgba(0,0,0,0.08) 62%, rgba(0,0,0,0) 100%); }
.atcsr-h-cap { position: absolute; left: 0; right: 0; bottom: 0; padding: 16px 17px; }
.atcsr-h-title { font-family: 'NSquareRound', sans-serif; font-weight: 800; font-size: 21.5px; line-height: 1.45; letter-spacing: -0.7px; color: #fff; margin-top: 9px; text-shadow: 0 1px 8px rgba(0,0,0,0.45); }
.atcsr-h-sum { font-size: 15px; color: #7a7f8d; line-height: 1.9; padding: 16px 6px 13px; flex: 1; }
.atcsr-h-sum strong { color: #3d4250; font-weight: 700; }
/* 대화 말풍선 타일 — 박스 자체가 말풍선(꼬리 달림) */
.atcsr-q { position: relative; border-radius: 18px; }
.atcsr-q > div { padding: 16px 17px 15px; }
.atcsr-q::after { content: ''; position: absolute; top: 17px; width: 0; height: 0; border-top: 7px solid transparent; border-bottom: 7px solid transparent; }
/* 꼬리 왼쪽 위 — 왼쪽 박스를 가리킴 */
.atcsr-q-tl { border-top-left-radius: 6px; }
.atcsr-q-tl::after { left: -9px; border-right: 10px solid var(--tail); }
/* 꼬리 오른쪽 위 — 오른쪽 박스를 가리킴 */
.atcsr-q-tr { border-top-right-radius: 6px; }
.atcsr-q-tr::after { right: -9px; border-left: 10px solid var(--tail); }
.atcsr-q-in { display: flex; flex-direction: column; flex: 1; }
.atcsr-q-top { display: flex; align-items: center; gap: 9px; margin-bottom: 13px; }
.atcsr-q-av { width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-family: 'NSquareRound', sans-serif; font-size: 16px; font-weight: 800; color: #fff; flex-shrink: 0; }
.atcsr-q-who { display: flex; flex-direction: column; line-height: 1.4; min-width: 0; }
.atcsr-q-who b { font-family: 'NSquareRound', sans-serif; font-size: 14px; font-weight: 800; color: #2b2f38; }
.atcsr-q-who span { font-size: 11.5px; color: #8b90a0; }
.atcsr-q-text { font-size: 14px; line-height: 1.8; color: #3d4250; flex: 1; }
.atcsr-q-time { font-size: 11.5px; color: #a9adb9; margin-top: 13px; }

/* ── 대화 요약 ── */
.atcsr-choice { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
.atcsr-choice-card { border-radius: 18px; box-shadow: 0 2px 12px rgba(24,28,45,0.05); padding: 20px 20px 18px; }
.atcsr-choice-head { display: flex; gap: 13px; align-items: center; margin-bottom: 14px; }
.atcsr-av-lg { width: 56px; height: 56px; border-radius: 50%; flex-shrink: 0; display: flex; align-items: center; justify-content: center; font-family: 'NSquareRound', sans-serif; font-size: 20px; font-weight: 800; color: #fff; }
.atcsr-choice-name { font-size: 13.5px; font-weight: 700; color: #3d4250; margin-top: 7px; }
.atcsr-choice-q { position: relative; font-size: 14.5px; color: #3d4250; line-height: 1.85; background: #fff; border-radius: 14px; padding: 13px 15px; box-shadow: 0 1px 5px rgba(24,28,45,0.07); }
.atcsr-choice-q::before { content: ''; position: absolute; top: -6px; left: 20px; width: 0; height: 0; border-left: 6px solid transparent; border-right: 6px solid transparent; border-bottom: 7px solid #fff; }
.atcsr-choice-p { font-size: 13px; color: #8b90a0; line-height: 1.8; margin-top: 13px; }
.atcsr-choice-p strong { color: #5a5f6d; font-weight: 700; }

/* ── 그룹 ── */
.atcsr-group { margin-bottom: 10px; }
.atcsr-group summary { display: flex; align-items: center; gap: 9px; cursor: pointer; list-style: none; font-family: 'NSquareRound', sans-serif; font-weight: 800; font-size: 17px; padding: 14px 18px; background: #f5f6fa; border-radius: 16px; }
.atcsr-group summary::-webkit-details-marker { display: none; }
.atcsr-gdot { width: 9px; height: 9px; border-radius: 50%; flex-shrink: 0; }
.atcsr-group summary .count { font-family: 'Pretendard Variable', sans-serif; font-size: 12.5px; font-weight: 500; color: #a9adb9; }
.atcsr-gtoggle { margin-left: auto; }
.atcsr-gtoggle .atcsr-lc { display: none; }
.atcsr-group[open] .atcsr-gtoggle .atcsr-lo { display: none; }
.atcsr-group[open] .atcsr-gtoggle .atcsr-lc { display: inline; }

/* ── 2단 split ── */
.atcsr-split { display: grid; grid-template-columns: 200px 1fr; gap: 26px; align-items: start; }
.atcsr-miss-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.atcsr-miss-card { display: flex; flex-direction: column; background: #fff; border-radius: 16px; box-shadow: 0 2px 12px rgba(24,28,45,0.06); padding: 16px 17px; }
.atcsr-miss-kicker { font-size: 11px; font-weight: 700; margin-bottom: 8px; }
.atcsr-miss-title { font-family: 'NSquareRound', sans-serif; font-weight: 700; font-size: 15px; line-height: 1.5; letter-spacing: -0.4px; color: #1f2024; flex: 1; }
.atcsr-miss-sub { font-size: 11.5px; color: #9096a4; line-height: 1.6; margin-top: 9px; }
.atcsr-miss-go { align-self: flex-start; font-size: 11.5px; font-weight: 700; border-radius: 20px; padding: 5px 12px; margin-top: 13px; white-space: nowrap; }
.atcsr-miss-links { display: flex; gap: 7px; flex-wrap: wrap; margin-top: 13px; }
.atcsr-miss-links .atcsr-miss-go { margin-top: 0; }
.atcsr-miss-lead { background: #71c168; box-shadow: 0 4px 16px rgba(113,193,104,0.32); }
.atcsr-miss-lead .atcsr-miss-kicker { color: rgba(255,255,255,0.88); }
.atcsr-miss-lead .atcsr-miss-title { color: #fff; }
.atcsr-miss-lead .atcsr-miss-sub { color: rgba(255,255,255,0.82); }
.atcsr-split-head { text-align: left; }
.atcsr-rows { display: flex; flex-direction: column; gap: 9px; }
.atcsr-row { display: flex; align-items: center; gap: 13px; background: #fff; border-radius: 16px; box-shadow: 0 2px 12px rgba(24,28,45,0.06); padding: 15px 18px; }
.atcsr-row-lead { background: #71c168; box-shadow: 0 4px 16px rgba(113,193,104,0.32); }
.atcsr-row-lead .atcsr-row-title { color: #fff; }
.atcsr-row-lead .atcsr-row-sub, .atcsr-row-lead .atcsr-row-kicker { color: rgba(255,255,255,0.82); }
.atcsr-row-kicker { font-size: 11.5px; font-weight: 700; margin-bottom: 5px; }
.atcsr-row-title { font-family: 'NSquareRound', sans-serif; font-weight: 700; font-size: 16px; line-height: 1.5; letter-spacing: -0.4px; color: #1f2024; }
.atcsr-row-sub { font-size: 12.5px; color: #9096a4; margin-top: 4px; line-height: 1.6; }

/* ── 정책 브리핑 ── */
.atcsr-policy summary { display: flex; align-items: center; gap: 9px; cursor: pointer; list-style: none; font-family: 'NSquareRound', sans-serif; font-weight: 800; font-size: 16.5px; color: #5a6a7a; padding: 16px 20px; background: #f5f6fa; border-radius: 16px; }
.atcsr-policy summary::-webkit-details-marker { display: none; }
.atcsr-ptoggle { margin-left: auto; }
.atcsr-ptoggle .atcsr-lc { display: none; }
.atcsr-policy[open] summary { border-radius: 16px 16px 0 0; }
.atcsr-policy[open] .atcsr-ptoggle .atcsr-lo { display: none; }
.atcsr-policy-box { background: #fafbfd; border-radius: 0 0 16px 16px; padding: 24px 22px 6px; }
.atcsr-policy[open] .atcsr-ptoggle .atcsr-lc { display: inline; }
.atcsr-policy-day { font-family: 'NSquareRound', sans-serif; font-weight: 800; font-size: 15px; color: #5a6a7a; margin-bottom: 11px; }
.atcsr-policy-txt { font-size: 14px; color: #5a5f6d; line-height: 1.85; }
.atcsr-policy-txt span { color: #8b90a0; padding-left: 12px; display: inline-block; }

/* ── 기여자 ── */
.atcsr-chip { display: inline-flex; align-items: center; gap: 6px; border-radius: 20px; padding: 7px 14px; margin: 0 4px 6px 0; font-size: 13.5px; font-weight: 700; color: #3d4250; background: #f5f6fa; }
.atcsr-dot { width: 7px; height: 7px; border-radius: 50%; flex-shrink: 0; }
.atcsr-chip-org { font-size: 12px; font-weight: 500; color: #a1a6b3; margin-left: 1px; }

.atcsr-cover-wrap { }
.atcsr-split .atcsr-sec-en { margin-bottom: 8px; }
.atcsr-split .atcsr-sec-ko { font-size: 26px; }
.atcsr-split .atcsr-sec-desc { margin-top: 11px; }

.atcsr-src { background: #f2f4f8; color: #8b90a0; border-radius: 20px; padding: 5px 11px; font-size: 12px; font-weight: 500; }

/* ── 반응형 ── */
@media (max-width: 520px) {
  .atcsr-body { padding: 0 14px 22px; }
  .s2, .s3, .s4 { grid-column: span 6; }
  .atcsr-c-h > a, .atcsr-c-h > div { flex-direction: column; }
  .atcsr-wrap .atcsr-c-h img.atcsr-c-img { width: 100%; min-width: 100%; height: 158px; }
  .atcsr-c-h .atcsr-c-body { padding: 14px 6px 4px; }
  /* 모바일: 위/아래로 쌓이므로 꼬리도 위/아래로 */
  .atcsr-q { border-radius: 18px; }
  .atcsr-q-tl, .atcsr-q-tr { border-radius: 18px; }
  .atcsr-q-tl::after, .atcsr-q-tr::after { top: auto; left: 24px; right: auto; border: 0; }
  .atcsr-q-tl { border-top-left-radius: 6px; }
  .atcsr-q-tl::after { top: -9px; bottom: auto; border-left: 7px solid transparent; border-right: 7px solid transparent; border-bottom: 10px solid var(--tail); }
  .atcsr-q-tr { border-bottom-left-radius: 6px; }
  .atcsr-q-tr::after { bottom: -9px; top: auto; border-left: 7px solid transparent; border-right: 7px solid transparent; border-top: 10px solid var(--tail); }
  .atcsr-choice { grid-template-columns: 1fr; }
  .atcsr-split { grid-template-columns: 1fr; gap: 16px; }
  .atcsr-miss-grid { grid-template-columns: 1fr; }
  .atcsr-sec { margin-top: 46px; }
  .atcsr-sec-ko { font-size: 22px; }
  .atcsr-cover { height: 195px; }

  .atcsr-split .atcsr-sec-ko { font-size: 22px; }
  .atcsr-cover-h1 { font-size: 27px; }
  .atcsr-mast { margin: 14px 14px 0; padding: 16px; }
  .atcsr-mast-top { flex-direction: column; align-items: flex-start; gap: 11px; }
  .atcsr-mast-logo { width: 42px; }
  .atcsr-mast-word { font-size: 17px; }
  .atcsr-mast-sub { font-size: 10.5px; }
  .atcsr-mast-issue { text-align: left; }
  .atcsr-mast-line { margin: 13px 0; }
  .atcsr-mast-stats { gap: 13px; justify-content: flex-start; }
  .atcsr-stat b { font-size: 17px; }
  .atcsr-issue-vol { font-size: 15px; }
  .atcsr-issue-date { font-size: 10px; }
  /* 어르신 가독성 — 모바일 본문 글자 확대 */
  .atcsr-sec-desc { font-size: 15.5px; }
  .atcsr-cover-lede { font-size: 15px; }
  .atcsr-tag { font-size: 13px; }
  .atcsr-c-title { font-size: 18px; }
  .atcsr-c-sum { font-size: 15.5px; line-height: 1.9; }
  .atcsr-c-meta { font-size: 13px; }
  .atcsr-c-h .atcsr-c-title { font-size: 20px; }
  .atcsr-h-title { font-size: 21px; }
  .atcsr-h-sum { font-size: 16.5px; line-height: 1.9; }
  .atcsr-q-text { font-size: 15.5px; }
  .atcsr-q-by { font-size: 13px; }
  .atcsr-choice-name { font-size: 14.5px; }
  .atcsr-choice-q { font-size: 16px; }
  .atcsr-choice-p { font-size: 14.5px; }
  .atcsr-miss-kicker { font-size: 12.5px; }
  .atcsr-miss-title { font-size: 16.5px; }
  .atcsr-miss-sub { font-size: 13px; }
  .atcsr-miss-go { font-size: 12.5px; }
  .atcsr-row-title { font-size: 17px; }
  .atcsr-row-sub { font-size: 13.5px; }
  .atcsr-policy summary { font-size: 16px; }
  .atcsr-policy-day { font-size: 16px; }
  .atcsr-policy-txt { font-size: 15.5px; line-height: 1.9; }
  .atcsr-group summary { font-size: 17px; }
  .atcsr-chip { font-size: 14.5px; }
  .atcsr-chip-org { font-size: 13px; }
  .atcsr-foot-inner { flex-direction: column; align-items: center; gap: 16px; text-align: center; }
  .atcsr-foot-text { text-align: center; }
}
@media (min-width: 680px) {
  .atcsr-inner { margin: 30px auto; border-radius: 24px; box-shadow: 0 4px 40px rgba(24,28,45,0.09); }
}
@media (min-width: 820px) {
  .atcsr-body { padding: 0 30px 40px; }
  .s3 { grid-column: span 2; }
  .atcsr-grid { gap: 17px; }
  .atcsr-mast { margin: 22px 22px 0; padding: 22px 26px; }
  .atcsr-mast-logo { width: 56px; }
  .atcsr-mast-word { font-size: 22px; letter-spacing: 0.5px; }
  .atcsr-mast-sub { font-size: 13px; }
  .atcsr-mast-line { margin: 18px 0; }
  .atcsr-mast-stats { gap: 26px; }
  .atcsr-stat b { font-size: 23px; }
  .atcsr-stat span { font-size: 11px; }
  .atcsr-issue-vol { font-size: 18px; }
  .atcsr-issue-date { font-size: 12px; }
  .atcsr-cover { height: 280px; }

  .atcsr-split .atcsr-sec-ko { font-size: 30px; }
  .atcsr-cover-cap { padding: 34px 34px 32px; }
  .atcsr-cover-h1 { font-size: 44px; }
  .atcsr-cover-lede { font-size: 15px; margin-top: 16px; }
  .atcsr-sec { margin-top: 78px; margin-bottom: 30px; }
  .atcsr-sec-ko { font-size: 32px; }
  .atcsr-sec-desc { font-size: 15.5px; }
  .atcsr-h-img { height: 228px; }
  .atcsr-h-title { font-size: 24px; }
  .atcsr-h-sum { font-size: 16px; }
  .atcsr-wrap img.atcsr-c-img { height: 158px; }
  .atcsr-wrap .atcsr-c-h img.atcsr-c-img { width: 264px; min-width: 264px; }
  .atcsr-c-title { font-size: 17.5px; }
  .atcsr-c-h .atcsr-c-title { font-size: 24px; }
  .atcsr-c-sum { font-size: 14.5px; }
  .atcsr-c-h .atcsr-c-sum { font-size: 15.5px; }
  .atcsr-q-text { font-size: 15px; }
  .atcsr-av-lg { width: 64px; height: 64px; font-size: 23px; }
  .atcsr-choice-q { font-size: 15.5px; }
  .atcsr-split { grid-template-columns: 230px 1fr; gap: 30px; }
  .atcsr-row-title { font-size: 16.5px; }
  .atcsr-row-sub { font-size: 13.5px; }
  .atcsr-chip { font-size: 14.5px; }
}
```

## 썸네일 (thumbnail.html)
매거진과 함께 생성하는 게시글 썸네일. 376x460 직사각형. 카카오톡 공유 시 1:1 정사각형 크롭되므로 핵심 텍스트가 잘리지 않도록 주의. **v2 카카오풍**(나눔스퀘어라운드 + Pretendard + 라운드 칩)으로 본문과 톤 통일.

- 배경 이미지: 매거진 커버와 동일한 Unsplash 이미지 (해당 주차 주제)
- 상단: 라운드 브랜드 칩(반투명 흰 배경 + 노란 dot + "ALL THAT CSR 매거진")
- 헤드라인: 매거진 헤드라인을 후킹 카피로. 2줄, 둘째 줄 #ffd200 하이라이트. 나눔스퀘어라운드 800.
- 서브카피: 보조 설명 1-2줄, 라운드 반투명 박스 안에.
- 하단: 발행 칩 2개(Vol / 주차), 라운드 반투명.

아래 템플릿의 배경이미지·헤드라인·호수·주차만 교체해 생성한다.

```html
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
  @import url('https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.css');
  @font-face {
    font-family: 'NSquareRound';
    src: url('https://cdn.jsdelivr.net/gh/fonts-archive/NanumSquareRound/NanumSquareRoundEB.woff2') format('woff2');
    font-weight: 800; font-style: normal; font-display: swap;
  }
  @font-face {
    font-family: 'NSquareRound';
    src: url('https://cdn.jsdelivr.net/gh/fonts-archive/NanumSquareRound/NanumSquareRoundB.woff2') format('woff2');
    font-weight: 700; font-style: normal; font-display: swap;
  }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { width: 376px; height: 460px; overflow: hidden; }
  .cover {
    width: 376px; height: 460px; position: relative;
    font-family: 'Pretendard Variable', 'NSquareRound', sans-serif;
    background: url('https://images.unsplash.com/photo-1503945438517-f65904a52ce6?w=800&h=1000&fit=crop') center/cover no-repeat;
  }
  .overlay {
    position: absolute; inset: 0;
    background: linear-gradient(180deg, rgba(0,0,0,0.66) 0%, rgba(0,0,0,0.34) 30%, rgba(0,0,0,0.16) 52%, rgba(0,0,0,0.52) 80%, rgba(0,0,0,0.82) 100%);
  }
  /* 상단 브랜드 칩 */
  .brand {
    position: absolute; top: 26px; left: 24px; z-index: 2;
    display: inline-flex; align-items: center; gap: 7px;
    background: rgba(255,255,255,0.16); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px);
    border: 1px solid rgba(255,255,255,0.28); border-radius: 20px;
    padding: 7px 14px;
    font-family: 'NSquareRound', sans-serif; font-weight: 800; font-size: 12.5px;
    color: #fff; letter-spacing: 0.4px;
  }
  .brand .dot { width: 7px; height: 7px; border-radius: 50%; background: #ffd200; }
  /* 헤드라인 */
  .hl-block { position: absolute; top: 92px; left: 24px; right: 24px; z-index: 2; }
  .headline {
    font-family: 'NSquareRound', sans-serif; font-weight: 800;
    font-size: 35px; color: #fff; line-height: 1.36; letter-spacing: -1.3px;
    text-shadow: 0 2px 12px rgba(0,0,0,0.5); margin-bottom: 15px;
  }
  .headline .hl { color: #ffd200; }
  .sub {
    font-size: 13px; font-weight: 500; color: rgba(255,255,255,0.82);
    line-height: 1.7; text-shadow: 0 1px 5px rgba(0,0,0,0.45);
    background: rgba(255,255,255,0.12); backdrop-filter: blur(6px); -webkit-backdrop-filter: blur(6px);
    border-radius: 12px; padding: 11px 14px; display: inline-block;
  }
  /* 하단 발행정보 칩 */
  .foot {
    position: absolute; bottom: 28px; left: 24px; right: 24px; z-index: 2;
    display: flex; align-items: center; gap: 8px;
  }
  .pill {
    background: rgba(255,255,255,0.16); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px);
    border: 1px solid rgba(255,255,255,0.26); border-radius: 20px;
    padding: 6px 13px; font-size: 11.5px; font-weight: 700; color: #fff; letter-spacing: 0.3px;
  }
  .pill.vol { font-family: 'NSquareRound', sans-serif; font-weight: 800; }
</style>
</head>
<body>
<div class="cover">
  <div class="overlay"></div>
  <div class="brand"><span class="dot"></span>ALL THAT CSR 매거진</div>
  <div class="hl-block">
    <div class="headline">재구매 알림 대신<br><span class="hl">안부를 물었다</span></div>
    <div class="sub">1년째 주문 없던 고객에게 건 전화 한 통<br>청년 47.3%가 외로운 시대의 CSR</div>
  </div>
  <div class="foot">
    <span class="pill vol">Vol.17</span>
    <span class="pill">2026년 7월 4주차</span>
  </div>
</div>
</body>
</html>
```

## 출력 규칙
- `<style>` 블록을 먼저, 이어서 `<div class="atcsr-wrap">` 시작
- 마크다운 코드블록(```html) 없이 HTML만 출력
- JavaScript 사용 금지
- CSS에서 !important 사용 금지
- `<style>` 블록으로 시작해서 `</div>` (atcsr-wrap 닫기)로 끝나야 함

## 콘텐츠 작성 가이드
- 각 카드의 본문 요약은 단순 제목 반복이 아닌, 원문 내용을 분석한 2-3문장의 인사이트 중심 요약으로 작성
- PDF 파일이 있으면 반드시 읽어서 요약 품질에 반영 (수치, 기관명, 정책 내용 등)
- 핵심 수치, 기관명, 개념어는 `<strong>`으로 강조

## 헤드라인(콘텐츠 타이틀) 작성 가이드
헤더 배경 위에 표시되는 한줄 요약 헤드라인은 매거진의 첫인상을 결정하므로 품질이 중요함.

### 작성 규칙
- 해당 주차 콘텐츠 중 가장 임팩트 있는 소재를 **후킹 카피**로 만든다
- 대화에서 화제가 된 멘트, 인용문, 재치 있는 표현을 활용
- 호기심을 자극하는 톤: "이게 뭐지?" 하고 클릭하게 만드는 문장
- **2줄 구성**: 1줄(화이트) + 2줄(#ffd200 하이라이트)

### 작성 패턴
- "[화제 멘트] — [CSR 인사이트로 연결]"
- "[의외의 소재], [반전 메시지]"
- "[구체적 행동/발언] + [의미 확장]"

### 좋은 예시
- "명품은 구찌만 삽니다 — CSR도 진정성이 통화다"
- "못 써야 뽑힙니다 — 공모전의 반란"
- "90대 창업주의 악필이 CSR을 바꿨다"

### 나쁜 예시 (이렇게 쓰지 말 것)
- "이번 주 ESG 소식 모음" → 너무 포괄적, 임팩트 없음
- "ESG 공시, 법정공시로의 대전환이 시작되다" → 정보성은 있지만 후킹 아님
- "다양한 CSR 관련 뉴스" → 구체성 제로
- "중요한 변화가 일어나고 있습니다" → 모호함
