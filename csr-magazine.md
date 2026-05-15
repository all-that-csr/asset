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

## HTML 구조 (반드시 이 순서대로 생성)

```
<style> ... </style>
<div class="atcsr-wrap">
<div class="atcsr-inner">
  1. HEADER (3색 바 + 배경이미지 히어로 + 로고 + 헤드라인 + 통계 + 발행정보)
  2. 액션 배너 (놓치지 마세요 콘텐츠 미리보기, 헤더 바로 아래)
  3. 이번 주 대화 요약 (채팅방별 버블 카드)
  4. 주간 하이라이트 섹션 라벨
  5. 히어로 카드 2개 (featured-grid)
  6. 커뮤니티 큐레이션 섹션 라벨
  7. 큐레이션 카드들 (curation-grid)
  8. 놓치지 마세요 섹션 라벨
  9. 액션 카드들
  10. 공유된 자료 섹션 (PDF 파일이 있을 경우만)
  11. 주간 정책 브리핑 섹션 (정부 브리핑 이미지 또는 PDF가 있을 경우)
  12. 구분선
  13. 함께 해주신 분들 섹션
  14. FOOTER
</div>
</div>
```

## CSS (style 블록에 정의)

```css
@font-face {
  font-family: 'Paperlogy';
  src: url('https://cdn.jsdelivr.net/gh/fonts-archive/Paperlogy/Paperlogy-8ExtraBold.woff2') format('woff2');
  font-weight: 800; font-style: normal;
}
@font-face {
  font-family: 'Paperlogy';
  src: url('https://cdn.jsdelivr.net/gh/fonts-archive/Paperlogy/Paperlogy-9Black.woff2') format('woff2');
  font-weight: 900; font-style: normal;
}
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700;900&display=swap');

.atcsr-wrap * { box-sizing: border-box; margin: 0; padding: 0; }
.atcsr-wrap { font-family: 'Noto Sans KR', sans-serif; overflow-wrap: break-word; word-break: keep-all; }
.atcsr-wrap a { text-decoration: none; color: inherit; }
.atcsr-wrap img { display: block; width: 100%; object-fit: cover; }
.atcsr-inner { max-width: 640px; margin: 0 auto; }

/* 히어로 카드 */
.atcsr-featured-grid { display: block; padding: 0; }
.atcsr-featured-card { margin-bottom: 16px; border-radius: 16px; overflow: hidden; box-shadow: 0 2px 12px rgba(0,0,0,0.08); background: #f5f9fd; border: 1px solid #d7e8f5; display: flex; flex-direction: column; }
.atcsr-featured-card > a { display: flex; flex-direction: column; flex: 1; }
.atcsr-featured-visual { position: relative; height: 220px; overflow: hidden; }
.atcsr-featured-visual img { height: 100%; width: 100%; object-fit: cover; }
.atcsr-featured-overlay {
  position: absolute; inset: 0;
  background: linear-gradient(0deg, rgba(0,0,0,0.7) 0%, rgba(0,0,0,0.15) 50%, rgba(0,0,0,0.05) 100%);
  display: flex; flex-direction: column; justify-content: flex-end;
  padding: 22px 24px;
}
.atcsr-featured-overlay .category {
  display: inline-block; font-size: 12px; font-weight: 700; letter-spacing: 0.5px;
  background: rgba(255,255,255,0.15); color: #fff; border-radius: 20px;
  padding: 5px 12px; margin-bottom: 8px; width: fit-content;
  backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255,255,255,0.25);
}
.atcsr-featured-overlay .title {
  font-size: 22px; font-weight: 800; color: #fff; line-height: 1.45; letter-spacing: -0.3px;
  text-shadow: 0 1px 4px rgba(0,0,0,0.3);
}
.atcsr-featured-body { padding: 20px 22px 22px; display: flex; flex-direction: column; flex: 1; }
.atcsr-featured-body .summary { font-size: 16px; color: #555; line-height: 1.9; margin-bottom: 14px; flex: 1; }
.atcsr-featured-body .meta {
  display: flex; align-items: center; justify-content: space-between;
  font-size: 13px; color: #333;
}
.atcsr-featured-body .meta .read-more { color: #0195df; font-weight: 600; font-size: 14px; }

/* 큐레이션 카드 */
.atcsr-curation-grid {
  display: flex; flex-direction: column; gap: 12px;
  padding: 0; margin-bottom: 4px;
}
.atcsr-curation-grid .atcsr-curation-thumb { width: 140px; min-width: 140px; object-fit: cover; flex-shrink: 0; display: block; }
.atcsr-card-category { display: inline-block; font-size: 12px; font-weight: 700; letter-spacing: 0.5px; color: #555; margin-bottom: 8px; background: rgba(0,0,0,0.05); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); border: 1px solid rgba(0,0,0,0.08); border-radius: 20px; padding: 5px 12px; }
.atcsr-card-title { font-size: 16px; font-weight: 700; color: #111; line-height: 1.5; margin-bottom: 8px; }
.atcsr-card-summary { font-size: 16px; color: #666; line-height: 1.8; margin-bottom: 12px; }
.atcsr-card-meta { display: flex; align-items: center; justify-content: space-between; font-size: 12px; color: #333; }

/* 큐레이션 카테고리 그룹핑 (15개 초과 시 사용) */
.atcsr-curation-group { margin-bottom: 8px; }
.atcsr-curation-group summary {
  display: flex; align-items: center; gap: 8px; cursor: pointer;
  font-size: 15px; font-weight: 700; color: #e6be00;
  padding: 10px 0; list-style: none;
}
.atcsr-curation-group summary::-webkit-details-marker { display: none; }
.atcsr-curation-group summary .count { font-size: 12px; font-weight: 500; color: #bbb; }
/* 펼쳐보기/접기 토글 버튼 */
.atcsr-curation-toggle {
  margin-left: auto; font-size: 13px; font-weight: 600; color: #fff;
  background: #e6be00; border-radius: 20px; padding: 4px 14px;
}
.atcsr-curation-toggle .atcsr-label-close { display: none; }
.atcsr-curation-group[open] .atcsr-curation-toggle { background: #c9a500; }
.atcsr-curation-group[open] .atcsr-curation-toggle .atcsr-label-open { display: none; }
.atcsr-curation-group[open] .atcsr-curation-toggle .atcsr-label-close { display: inline; }

/* 공유된 자료 */
.atcsr-shared-file {
  display: flex; align-items: center; gap: 12px;
  padding: 14px 16px; background: #fefcf3; border: 1px solid #f0e4b8;
  border-radius: 12px; text-decoration: none; color: inherit;
}
.atcsr-shared-file-info { text-align: right; flex-shrink: 0; }

/* 함께 해주신 분들 */
.atcsr-contrib-label { font-size: 17px; font-weight: 700; color: #333; margin-bottom: 16px; }
.atcsr-contrib-label strong { color: #FF5C35; font-weight: 900; }
.atcsr-contrib-chip {
  display: inline-flex; align-items: center; gap: 5px;
  border: 1px solid; border-radius: 6px;
  padding: 4px 10px; margin: 0 3px 5px 0;
  font-size: 13px; font-weight: 600; color: #222;
  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
}
.atcsr-contrib-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.atcsr-contrib-org { font-size: 12px; font-weight: 400; color: #888; margin-left: 2px; }

/* 헤더 반응형 */
.atcsr-header-vol { text-align: right; }
.atcsr-header-bottom { display: flex; align-items: center; justify-content: space-between; }
.atcsr-footer-text { text-align: right; }

@media (max-width: 480px) {
  .atcsr-curation-grid a,
  .atcsr-curation-grid > div > div { flex-direction: column; }
  .atcsr-curation-grid .atcsr-curation-thumb { width: 100%; min-width: 100%; height: 180px; }
  .atcsr-header-bottom { flex-direction: column; gap: 20px; align-items: center; text-align: center; }
  .atcsr-header-vol { text-align: center; }
  .atcsr-header-logo { flex-direction: column; align-items: center; text-align: center; margin-bottom: 8px; }
  .atcsr-header-content { align-items: center; text-align: center; padding: 24px 20px 28px; gap: 28px; }
  .atcsr-header-headline { text-align: center; font-size: 22px; margin-bottom: 24px; }
  .atcsr-footer-inner { flex-direction: column; align-items: flex-start; }
  .atcsr-footer-inner img { margin-bottom: 12px; }
  .atcsr-footer-text { text-align: center; }
  .atcsr-action-banner { flex-direction: column; }
  .atcsr-action-banner > a { min-width: 0; }
  .atcsr-footer { padding: 20px 16px 18px; }
  .atcsr-shared-file { flex-direction: column; align-items: flex-start; }
  .atcsr-shared-file-info { text-align: left; }
}
@media (min-width: 680px) {
  .atcsr-inner { border-radius: 12px; margin: 24px auto; }
  .atcsr-featured-grid { display: flex; gap: 14px; padding: 0; }
  .atcsr-featured-card { flex: 1; min-width: 0; margin-bottom: 0; }
}
```

## 각 섹션 HTML 패턴

### 1. HEADER (히어로 배너)
```html
<div style="position: relative; overflow: hidden;">
  <!-- 3색 바 -->
  <div style="display: flex; height: 6px; position: relative; z-index: 2;">
    <div style="flex: 1; background: #0195df;"></div>
    <div style="flex: 1; background: #ffd200;"></div>
    <div style="flex: 1; background: #71c168;"></div>
  </div>
  <!-- 배경 이미지: 해당 주차 주제에 맞는 Unsplash 이미지 -->
  <div style="position: relative; min-height: 320px; background: url('[Unsplash URL w=1280&h=600&fit=crop]') center/cover no-repeat;">
    <div style="position: absolute; inset: 0; background: linear-gradient(180deg, rgba(0,0,0,0.55) 0%, rgba(0,0,0,0.3) 50%, rgba(0,0,0,0.65) 100%);"></div>
    <div class="atcsr-header-content" style="position: relative; z-index: 1; padding: 28px 28px 24px; display: flex; flex-direction: column; justify-content: space-between; min-height: 320px;">
      <!-- 상단: 로고 + 타이틀 -->
      <div class="atcsr-header-logo" style="display: flex; align-items: center; gap: 12px;">
        <img src="[로고 Base64 data URI]" alt="All-That CSR" style="width: 120px; height: auto; border-radius: 8px; background: rgba(255,255,255,0.9); padding: 6px 8px;">
        <div>
          <div style="font-family: 'Paperlogy', 'Noto Sans KR', sans-serif; font-weight: 900; font-size: 20px; color: #fff; letter-spacing: 3px; text-shadow: 0 1px 4px rgba(0,0,0,0.3);">ALL THAT CSR 매거진</div>
          <div style="font-size: 12px; color: rgba(255,255,255,0.7); margin-top: 2px;">커뮤니티로 만드는 사회적 책임</div>
        </div>
      </div>
      <!-- 하단: 헤드라인 + 통계 + 발행정보 -->
      <div>
        <h1 class="atcsr-header-headline" style="font-size: 26px; font-weight: 900; color: #fff; line-height: 1.5; letter-spacing: -0.5px; margin: 0 0 16px; text-shadow: 0 2px 8px rgba(0,0,0,0.3);">[콘텐츠 한줄 요약 헤드라인]</h1>
        <div class="atcsr-header-bottom">
          <div style="display: flex; gap: 12px;">
            <div style="text-align: center;">
              <div style="font-size: 20px; font-weight: 900; color: #fff;">[메시지수]</div>
              <div style="font-size: 11px; color: rgba(255,255,255,0.6);">메시지</div>
            </div>
            <div style="width: 1px; background: rgba(255,255,255,0.2);"></div>
            <div style="text-align: center;">
              <div style="font-size: 20px; font-weight: 900; color: #fff;">[링크수]</div>
              <div style="font-size: 11px; color: rgba(255,255,255,0.6);">링크</div>
            </div>
            <div style="width: 1px; background: rgba(255,255,255,0.2);"></div>
            <div style="text-align: center;">
              <div style="font-size: 20px; font-weight: 900; color: #fff;">[큐레이션수]</div>
              <div style="font-size: 11px; color: rgba(255,255,255,0.6);">큐레이션</div>
            </div>
          </div>
          <div class="atcsr-header-vol">
            <div style="font-size: 13px; font-weight: 700; color: rgba(255,255,255,0.9); letter-spacing: 1px;">Vol.[호수]</div>
            <div style="font-size: 12px; color: rgba(255,255,255,0.6); margin-top: 2px;">[YYYY년 M월 N주차] · [M/DD~M/DD]</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
```

### 2. 액션 배너 (헤더 바로 아래)
놓치지 마세요 섹션의 콘텐츠를 헤더 직후에 컴팩트 배너로 미리 노출. 모바일에서는 세로 정렬.
```html
<div class="atcsr-action-banner" style="display: flex; gap: 10px; padding: 20px 0 0;">
  <a href="[URL]" target="_blank" rel="noopener" style="flex: 1; display: flex; align-items: center; gap: 10px; background: linear-gradient(135deg, #e8f5e3 0%, #f0faf0 100%); border: 1px solid #c8e6c0; border-radius: 12px; padding: 12px 14px; text-decoration: none; color: inherit;">
    <span style="font-size: 20px; flex-shrink: 0;">[이모지]</span>
    <div style="min-width: 0;">
      <div style="font-size: 11px; font-weight: 700; color: #71c168; margin-bottom: 2px;">[카테고리]</div>
      <div style="font-size: 13px; font-weight: 700; color: #222; line-height: 1.4;">[짧은 제목] →</div>
    </div>
  </a>
  <!-- 두 번째 배너도 동일 구조 -->
</div>
```

### 2-1. 이번 주 대화 요약 (액션 배너 바로 아래)
각 채팅방의 주요 대화 흐름을 요약하는 버블 카드 UI. 대표 인용문이 있는 채팅방은 아바타+인용문 버블을 포함하고, 인용문이 없거나 대화가 없었던 채팅방은 요약 텍스트만 표시.
**대화가 없었던 채팅방도 반드시 포함**하되, 이전 대화(필터링 전 원본 파일)를 참고하여 왜 대화가 없었는지 설명한다 (예: 독서모임 준비 중, 오프라인 모임 후 쉬는 기간 등).

채팅방별 배경색·라벨색:
| 채팅방 | 카드 배경 | 라벨 배경 | 라벨 텍스트 | 아바타/버블 색 |
|--------|-----------|-----------|-------------|---------------|
| 올댓CSR 전체 | #f3fbf2 | #edf7ec | #3d8c35 | #71c168 / #edf7ec |
| 사회공헌 | #f0f9ff | #e8f5fd | #0178b8 | #0195df / #e8f5fd |
| 지속가능경영 | #fefceb | #fdf6d8 | #b8960a | #e6be00 / #fdf6d8 |
| 임팩트투자 | #fff8f5 | #fff0eb | #d94f20 | #FF5C35 / #fff0eb |

```html
<!-- ============ 이번 주 대화 요약 ============ -->
<div style="padding: 32px 0 0;">
  <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 18px;">
    <div style="width: 5px; height: 28px; background: #333; border-radius: 2px;"></div>
    <div>
      <span style="font-size: 20px; font-weight: 900; color: #333;">이번 주 대화 요약</span>
      <div style="font-size: 13px; color: #aaa; margin-top: 4px;">링크 너머에서 나눈 이야기</div>
    </div>
  </div>
  <div style="display: flex; flex-direction: column; gap: 12px;">

    <!-- 인용문이 있는 채팅방 (올댓CSR 전체 예시) -->
    <div style="background: #f3fbf2; border-radius: 14px; padding: 14px 16px; box-shadow: 0 1px 6px rgba(0,0,0,0.05);">
      <div style="font-size: 11px; font-weight: 700; color: #3d8c35; background: #edf7ec; display: inline-block; padding: 2px 9px; border-radius: 20px; margin-bottom: 10px;">올댓CSR 전체</div>
      <div style="display: flex; gap: 8px; align-items: flex-start;">
        <div style="width: 32px; height: 32px; border-radius: 50%; background: #71c168; flex-shrink: 0; display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: 700; color: #fff;">[성]</div>
        <div style="flex: 1; min-width: 0;">
          <div style="font-size: 11px; color: #999; margin-bottom: 4px;">[이름]</div>
          <div style="background: #edf7ec; border-radius: 0 12px 12px 12px; padding: 10px 14px; font-size: 13px; color: #222; line-height: 1.6; word-break: keep-all;">"[대표 인용문]"</div>
        </div>
      </div>
      <p style="font-size: 12px; color: #888; line-height: 1.65; margin-top: 9px; word-break: keep-all;">[채팅방 전체 대화 흐름 요약 2-3문장]</p>
    </div>

    <!-- 인용문 없는 채팅방 (요약만) -->
    <div style="background: [카드 배경]; border-radius: 14px; padding: 14px 16px; box-shadow: 0 1px 6px rgba(0,0,0,0.05);">
      <div style="font-size: 11px; font-weight: 700; color: [라벨 텍스트]; background: [라벨 배경]; display: inline-block; padding: 2px 9px; border-radius: 20px; margin-bottom: 10px;">[채팅방명]</div>
      <p style="font-size: 12px; color: #888; line-height: 1.65; margin-top: 4px; word-break: keep-all;">[요약 텍스트]</p>
    </div>

  </div>
</div>
```

### 3. 섹션 라벨 (주간 하이라이트 — 파랑)
```html
<div style="padding: 32px 0 18px; display: flex; align-items: center; gap: 12px;">
  <div style="width: 5px; height: 28px; background: #0195df; border-radius: 2px;"></div>
  <div>
    <span style="font-size: 20px; font-weight: 900; color: #0195df; letter-spacing: 1px;">주간 하이라이트</span>
    <div style="font-size: 13px; color: #aaa; margin-top: 4px;">커뮤니티에서 가장 많은 대화를 이끌어낸 기사</div>
  </div>
</div>
```

### 4. 히어로 카드 (이미지 오버레이 + 하단 요약)
```html
<div class="atcsr-featured-grid">
  <div class="atcsr-featured-card">
    <a href="[URL]" target="_blank" rel="noopener">
      <div class="atcsr-featured-visual">
        <img src="[Unsplash URL w=640&h=400&fit=crop]" alt="">
        <div class="atcsr-featured-overlay">
          <div class="category">[이모지] [카테고리]</div>
          <div class="title">[제목]</div>
        </div>
      </div>
      <div class="atcsr-featured-body">
        <p class="summary">[요약 2-3문장. 핵심 키워드는 <strong>굵게</strong>]</p>
        <div class="meta">
          <span>💬 [공유자]</span>
          <span class="read-more">원문 읽기 →</span>
        </div>
      </div>
    </a>
  </div>
  <!-- 두 번째 히어로 카드도 동일 구조 -->
</div>
```

### 5. 섹션 라벨 (커뮤니티 큐레이션 — 노랑)
```html
<div style="padding: 36px 0 18px; display: flex; align-items: center; gap: 12px;">
  <div style="width: 5px; height: 28px; background: #e6be00; border-radius: 2px;"></div>
  <div>
    <span style="font-size: 20px; font-weight: 900; color: #e6be00; letter-spacing: 1px;">커뮤니티 큐레이션</span>
    <div style="font-size: 13px; color: #aaa; margin-top: 4px;">커뮤니티 멤버가 직접 공유한 기사</div>
  </div>
</div>
```

### 6. 큐레이션 카드 (좌측 썸네일 + 우측 텍스트, 모바일에서 세로 전환)
```html
<div class="atcsr-curation-grid">
  <div style="border-radius: 14px; overflow: hidden; box-shadow: 0 1px 6px rgba(0,0,0,0.05); background: #fefcf3; border: 1px solid #f0e4b8;">
    <a href="[URL]" target="_blank" rel="noopener" style="display: flex; text-decoration: none; color: inherit;">
      <img src="[Unsplash URL w=640&h=360&fit=crop]" alt="" class="atcsr-curation-thumb">
      <div style="padding: 16px 18px; flex: 1; min-width: 0;">
        <div class="atcsr-card-category">[이모지] [카테고리]</div>
        <div class="atcsr-card-title">[제목]</div>
        <p class="atcsr-card-summary">[요약 2-3문장. 핵심 키워드는 <strong>굵게</strong>]</p>
        <div class="atcsr-card-meta">
          <span>💬 [공유자]</span>
          <span style="color: #e6be00; font-weight: 600; font-size: 13px;">원문 읽기 →</span>
        </div>
      </div>
    </a>
  </div>
  <!-- URL 없는 콘텐츠는 <a> 대신 <div style="display: flex;">로 감싸고 "원문 읽기 →" 제거 -->
</div>
```

### 6-1. 큐레이션 채팅방별 그룹핑 (15개 초과 시에만 적용)
큐레이션 카드가 15개를 초과하면 채팅방별로 `<details>/<summary>`로 묶어서 접기/펼치기 적용.
채팅방 이름은 각 카카오톡 대화 파일의 첫 줄에서 추출 (예: "All that CSR_임팩트투자 님과 카카오톡 대화" → "임팩트투자").
전체방(메인 채팅방)은 **"올댓CSR 전체"**로 표기하고 반드시 첫 번째 그룹으로 배치 (`open` 속성).

**그룹 순서 (고정):**
1. 올댓CSR 전체 (기본 펼침)
2. 사회공헌
3. 지속가능경영
4. 임팩트투자

토글 버튼은 화살표가 아닌 "펼쳐보기"/"접기" 텍스트 버튼을 사용. CSS-only 듀얼 라벨 패턴으로 `<details>`의 `[open]` 상태에 따라 전환.
```html
<div class="atcsr-curation-grid">
  <!-- 그룹 1: 올댓CSR 전체 (기본 펼침) -->
  <details class="atcsr-curation-group" open>
    <summary>💬 올댓CSR 전체 <span class="count">([N]건)</span> <span class="atcsr-curation-toggle"><span class="atcsr-label-open">펼쳐보기</span><span class="atcsr-label-close">접기</span></span></summary>
    <!-- 해당 채팅방에서 공유된 큐레이션 카드들 나열 -->
  </details>

  <!-- 그룹 2: 사회공헌 (접힌 상태) -->
  <details class="atcsr-curation-group">
    <summary>💬 사회공헌 <span class="count">([N]건)</span> <span class="atcsr-curation-toggle"><span class="atcsr-label-open">펼쳐보기</span><span class="atcsr-label-close">접기</span></span></summary>
    <!-- 해당 채팅방에서 공유된 큐레이션 카드들 나열 -->
  </details>

  <!-- 그룹 3: 지속가능경영 -->
  <!-- 그룹 4: 임팩트투자 -->
</div>
```

### 7. 섹션 라벨 (놓치지 마세요 — 초록)
```html
<div style="padding: 36px 0 18px; display: flex; align-items: center; gap: 12px;">
  <div style="width: 5px; height: 28px; background: #71c168; border-radius: 2px;"></div>
  <div>
    <span style="font-size: 20px; font-weight: 900; color: #71c168; letter-spacing: 1px;">놓치지 마세요</span>
    <div style="font-size: 13px; color: #aaa; margin-top: 4px;">공모전 · 채용 · 행사 · 캠페인</div>
  </div>
</div>
```

### 8. 액션 카드
```html
<div style="padding: 0; display: flex; flex-direction: column; gap: 12px; margin-bottom: 16px;">
  <a href="[URL]" target="_blank" rel="noopener" style="display: flex; align-items: center; gap: 14px; background: #f7f9f7; border: 1px solid #e2ece2; border-radius: 14px; padding: 16px 18px; text-decoration: none; color: inherit;">
    <div style="width: 44px; height: 44px; border-radius: 12px; background: #71c168; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
      <span style="font-size: 22px;">[이모지]</span>
    </div>
    <div style="flex: 1; min-width: 0;">
      <div style="font-size: 12px; font-weight: 700; color: #71c168; margin-bottom: 4px;">[카테고리]</div>
      <div style="font-size: 15px; font-weight: 700; color: #111; line-height: 1.45;">[제목]</div>
      <div style="font-size: 13px; color: #333; margin-top: 4px;">[부가 정보]</div>
    </div>
    <div style="font-size: 13px; color: #71c168; font-weight: 700; flex-shrink: 0;">참여 →</div>
  </a>
</div>
```

### 9. 주간 정책 브리핑 (정부 브리핑 이미지가 있을 경우만 표시)
이미지(JPG/PNG)로 공유된 행정안전부 지방행정 여론·동향 등 정부 브리핑 자료를 텍스트로 요약하여 표시.
**반드시 단일 `<details>`로 전체 기간을 감싸고**, 내부에 날짜별 `<div>`로 구분한다. (날짜별 개별 `<details>` 금지)
기본 접힌 상태(`<details>` without `open`)로 표시하며, "펼쳐보기"/"접기" 토글 버튼 사용.
각 날짜별로 주요 이슈 제목과 핵심 수치/내용을 내려쓰기로 표시. 제목은 `<strong>`, 설명은 다음 줄에 들여쓰기.

CSS 추가:
```css
.atcsr-policy-briefing { margin-bottom: 8px; }
.atcsr-policy-briefing summary {
  display: flex; align-items: center; gap: 8px; cursor: pointer;
  font-size: 15px; font-weight: 700; color: #5a6a7a;
  padding: 14px 18px; list-style: none;
  background: #f4f6f8; border: 1px solid #dde2e8; border-radius: 14px;
}
.atcsr-policy-briefing summary::-webkit-details-marker { display: none; }
.atcsr-policy-toggle {
  margin-left: auto; font-size: 13px; font-weight: 600; color: #fff;
  background: #7a8a9a; border-radius: 20px; padding: 4px 14px;
}
.atcsr-policy-toggle .atcsr-label-close { display: none; }
.atcsr-policy-briefing[open] summary { border-radius: 14px 14px 0 0; border-bottom: none; }
.atcsr-policy-briefing[open] .atcsr-policy-toggle { background: #5a6a7a; }
.atcsr-policy-briefing[open] .atcsr-policy-toggle .atcsr-label-open { display: none; }
.atcsr-policy-briefing[open] .atcsr-policy-toggle .atcsr-label-close { display: inline; }
```

```html
<div style="padding: 24px 0 0;">
  <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 18px;">
    <div style="width: 5px; height: 28px; background: #5a6a7a; border-radius: 2px;"></div>
    <div>
      <span style="font-size: 20px; font-weight: 900; color: #5a6a7a; letter-spacing: 1px;">주간 정책 브리핑</span>
      <div style="font-size: 13px; color: #aaa; margin-top: 4px;">행정안전부 지방행정 여론·동향</div>
    </div>
  </div>
  <details class="atcsr-policy-briefing">
    <summary>📋 정책 브리핑 보기 <span class="atcsr-policy-toggle"><span class="atcsr-label-open">펼쳐보기</span><span class="atcsr-label-close">접기</span></span></summary>
    <div style="background: #f4f6f8; border: 1px solid #dde2e8; border-top: none; border-radius: 0 0 14px 14px; padding: 20px 22px;">
      <!-- 날짜별 반복 -->
      <div style="margin-bottom: 20px;">
        <div style="font-size: 13px; font-weight: 700; color: #5a6a7a; margin-bottom: 10px;">📅 [M/D] ([요일])</div>
        <div style="font-size: 14px; color: #444; line-height: 1.7; padding-left: 4px;">
          · <strong>[이슈 제목]</strong><br>
          <span style="padding-left: 12px; color: #666;">[핵심 수치/내용 요약]</span><br>
          · <strong>[이슈 제목]</strong><br>
          <span style="padding-left: 12px; color: #666;">[핵심 수치/내용 요약]</span>
        </div>
      </div>
      <!-- 마지막 날짜는 margin-bottom: 0 -->
    </div>
  </details>
</div>
```

### 10. 공유된 자료 (PDF 파일이 있을 경우만 표시)
대화에서 공유된 PDF 파일을 큐레이션과 분리하여 별도로 표시. 파일명은 10글자+ellipsis+확장자, 공유 날짜 표기.
```html
<div style="padding: 12px 0 0;">
  <div style="font-size: 14px; font-weight: 700; color: #888; margin-bottom: 12px;">📎 공유된 자료</div>
  <div style="display: flex; flex-direction: column; gap: 8px;">
    <a class="atcsr-shared-file" href="[GitHub raw PDF URL]" target="_blank" rel="noopener">
      <span style="font-size: 18px; flex-shrink: 0;">📄</span>
      <div style="flex: 1; min-width: 0;">
        <div style="font-size: 14px; font-weight: 700; color: #222; line-height: 1.4;">[자료 제목]</div>
        <div style="font-size: 12px; color: #999; margin-top: 3px;">[한줄 요약]</div>
      </div>
      <div class="atcsr-shared-file-info">
        <div style="font-size: 11px; color: #bbb;">[파일명10자 ….확장자]</div>
        <div style="font-size: 11px; color: #ccc; margin-top: 2px;">[M/D] 공유 · 다운로드 →</div>
      </div>
    </a>
  </div>
</div>
```

### 11. 구분선 + 함께 해주신 분들
칩의 배경색·테두리색은 채팅방별 dot 색상의 rgba 버전을 인라인으로 적용.
채팅방 색상 순서: 1번 #0195df, 2번 #e6be00, 3번 #71c168, 4번 #FF5C35, 5번 #8B5CF6
```html
<!-- 구분선 -->
<div style="width: 100%; height: 1px; background: #e0e0e0; margin-top: 28px;"></div>

<!-- 함께 해주신 분들 -->
<div style="margin: 28px 0 12px; padding: 24px 0 0;">
  <div class="atcsr-contrib-label"><strong>[N]명</strong>의 멤버가 이번 매거진을 함께 만들었어요</div>
  <div>
    <!-- 채팅방별 dot 색상 + 배경 rgba 8% + 테두리 rgba 25~30% -->
    <span class="atcsr-contrib-chip" style="background: rgba(1,149,223,0.08); border-color: rgba(1,149,223,0.25);"><span class="atcsr-contrib-dot" style="background: #0195df;"></span>[이름] <span class="atcsr-contrib-org">[소속]</span></span>
    <span class="atcsr-contrib-chip" style="background: rgba(230,190,0,0.08); border-color: rgba(230,190,0,0.3);"><span class="atcsr-contrib-dot" style="background: #e6be00;"></span>[이름]</span>
    <!-- 소속 없으면 atcsr-contrib-org 생략 -->
  </div>
</div>
```

### 12. FOOTER
좌측 로고 + 우측 발행정보·저작권 레이아웃. 모바일에서는 세로 정렬.
```html
<div class="atcsr-footer" style="margin: 16px 0 0; background: #f5f5f5; border-radius: 16px; padding: 28px 28px 24px;">
  <div class="atcsr-footer-inner" style="display: flex; align-items: center; justify-content: space-between; gap: 20px;">
    <!-- 좌측: 로고 -->
    <img src="[로고 Base64 data URI]" alt="All-That CSR" style="height: 70px; width: auto; flex-shrink: 0;">
    <!-- 우측: 발행정보 + 카피라이트 -->
    <div class="atcsr-footer-text">
      <div style="font-size: 13px; color: #999; margin-bottom: 4px;">커뮤니티로 만드는 사회적 책임</div>
      <div style="font-size: 12px; color: #bbb; margin-bottom: 8px;">[YYYY년 M월 N주차] ([M/DD~M/DD])</div>
      <div style="font-size: 11px; color: #ccc;">&copy; [YYYY] All That CSR. All rights reserved.</div>
    </div>
  </div>
  <div style="display: flex; justify-content: center; gap: 6px; margin-top: 20px;">
    <div style="width: 6px; height: 6px; border-radius: 50%; background: #0195df;"></div>
    <div style="width: 6px; height: 6px; border-radius: 50%; background: #ffd200;"></div>
    <div style="width: 6px; height: 6px; border-radius: 50%; background: #71c168;"></div>
  </div>
</div>
```

## 썸네일 (thumbnail.html)
매거진과 함께 생성되는 게시글 썸네일. 376x460 직사각형. 카카오톡 공유 시 1:1 정사각형 크롭되므로 핵심 텍스트가 잘리지 않도록 레이아웃에 주의.

- 배경 이미지: 매거진 헤더와 동일한 Unsplash 이미지 사용 (해당 주차 주제에 맞게)
- 헤드라인: 매거진 헤드라인을 후킹 카피로 변환. 2줄 구성, 두 번째 줄은 #ffd200 하이라이트
- 서브카피: 헤드라인 보조 설명 1-2줄, 왼쪽에 #ffd200 세로 바
- 마스트헤드: 하단에 좌측 "ALL THAT CSR 매거진" + 우측 Vol/주차

```html
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
  @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700;900&display=swap');
  @font-face {
    font-family: 'Paperlogy';
    src: url('https://cdn.jsdelivr.net/gh/fonts-archive/Paperlogy/Paperlogy-9Black.woff2') format('woff2');
    font-weight: 900; font-style: normal;
  }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { width: 376px; height: 460px; overflow: hidden; }
  .cover {
    width: 376px; height: 460px;
    position: relative;
    font-family: 'Noto Sans KR', sans-serif;
    background: url('[Unsplash URL w=800&h=1000&fit=crop]') center/cover no-repeat;
  }
  .cover-overlay {
    position: absolute; inset: 0;
    background: linear-gradient(180deg, rgba(0,0,0,0.7) 0%, rgba(0,0,0,0.4) 30%, rgba(0,0,0,0.15) 55%, rgba(0,0,0,0.5) 80%, rgba(0,0,0,0.8) 100%);
  }
  /* 상단 컬러바 */
  .color-bar { display: flex; height: 8px; position: absolute; top: 0; left: 0; right: 0; z-index: 3; }
  .color-bar div { flex: 1; }
  /* 마스트헤드 (하단) */
  .masthead {
    position: absolute; bottom: 30px; left: 0; right: 0; z-index: 2;
    padding: 0 23px;
    display: flex; align-items: flex-end; justify-content: space-between;
  }
  .masthead-title {
    font-family: 'Paperlogy', 'Noto Sans KR', sans-serif;
    font-weight: 900; font-size: 13px; color: #fff;
    letter-spacing: 1px;
    text-shadow: 0 1px 6px rgba(0,0,0,0.5);
  }
  .masthead-right {
    text-align: right;
  }
  .masthead-issue {
    font-size: 11px; font-weight: 700; color: rgba(255,255,255,0.7);
    letter-spacing: 0.5px;
  }
  .masthead-date {
    font-size: 11px; font-weight: 500; color: rgba(255,255,255,0.5);
    margin-top: 2px;
  }
  /* 상단 헤드라인 영역 */
  .bottom-block {
    position: absolute; top: 55px; left: 0; right: 0; z-index: 2;
    padding: 0 23px;
  }
  .headline {
    font-size: 34px; font-weight: 900; color: #fff;
    line-height: 1.35; letter-spacing: -1px;
    text-shadow: 0 2px 10px rgba(0,0,0,0.5);
    margin-bottom: 12px;
  }
  .headline .hl {
    color: #ffd200;
  }
  .sub-copy {
    font-size: 13px; font-weight: 500; color: rgba(255,255,255,0.7);
    line-height: 1.6;
    text-shadow: 0 1px 4px rgba(0,0,0,0.4);
    border-left: 3px solid #ffd200;
    padding-left: 10px;
  }
</style>
</head>
<body>
<div class="cover">
  <div class="cover-overlay"></div>
  <div class="color-bar">
    <div style="background: #0195df;"></div>
    <div style="background: #ffd200;"></div>
    <div style="background: #71c168;"></div>
  </div>
  <!-- 마스트헤드 -->
  <div class="masthead">
    <span class="masthead-title">ALL THAT CSR 매거진</span>
    <div class="masthead-right">
      <div class="masthead-issue">Vol.[호수]</div>
      <div class="masthead-date">[YYYY년 M월 N주차]</div>
    </div>
  </div>
  <!-- 상단 헤드라인 -->
  <div class="bottom-block">
    <div class="headline">[헤드라인 1줄]<br><span class="hl">[헤드라인 2줄 — 하이라이트]</span></div>
    <div class="sub-copy">[서브카피 1줄]<br>[서브카피 2줄]</div>
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
