---
name: CSR 매거진 v3/v4 작업 현황
description: 올댓CSR 매거진 v3 피드백 반영 및 v4 그룹핑 예시 생성 (2026-04-03)
type: project
---

올댓CSR 매거진 v3 피드백 반영 완료, v4 그룹핑 예시 생성됨.
파일 위치: `/home/hyem095/all_that_csr/260402/`

**Why:** 클라이언트 피드백 반영 및 15개 초과 큐레이션 대비 채팅방별 그룹핑 데모 준비.

**How to apply:**
- `/csr-magazine [폴더경로]` 스킬로 매거진 HTML + thumbnail.html 자동 생성
- 현재 Vol.3까지 발행됨 (Vol.3: 2026-04-06~04-12)

**2026-04-03 변경사항:**
- 공유된 자료 모바일 반응형: `.atcsr-shared-file` + `.atcsr-shared-file-info` CSS 클래스, 480px 이하 세로 전환
- 큐레이션 그룹핑: 카테고리별 → **채팅방별**로 변경 (대화 파일 첫 줄에서 채팅방명 추출)
- 중복 링크 제거 규칙 추가: 여러 채팅방에서 같은 URL 공유 시 1번만 노출
- 함께 해주신 분들 리디자인: 원형 아바타 pill → 컬러 틴트 칩 (dot + rgba 배경/테두리)
  - 채팅방별 dot 색상: 1번 #0195df, 2번 #e6be00, 3번 #71c168, 4번 #FF5C35, 5번 #8B5CF6
  - 타이틀: "N명의 멤버가 이번 매거진을 함께 만들었어요" (17px, 700, N명은 #FF5C35 + 900)
- 푸터: "올댓CSR 단톡방 큐레이션" 문구 삭제
- v4 그룹핑 예시 파일: `매거진_v4_그룹핑예시.html` (18건, 3개 채팅방별 details/summary)

**2026-05-22 Figma 썸네일 레이아웃 변경:**
- Vol.7부터 적용: 마스트헤드(타이틀+Vol+날짜)가 **상단**(y:24~40), 헤드라인+서브카피가 **중하단**(y:255~401)
- 기존(Vol.8 초기): 헤드라인 상단, 마스트헤드 하단 → **폐기**
- Vol.7 정확한 좌표:
  - Masthead Title: x=23, y=26 (Black 13px)
  - Vol Number: x=우측정렬(376-23-width), y=24 (Bold 11px)
  - Date: x=우측정렬(376-23-width), y=40 (Medium 11px)
  - Headline Line 1: x=23, y=255, w=330 (Black 34px, lineHeight 45.9)
  - Headline Line 2: x=23, y=301, w=330 (Black 34px, #ffd200)
  - Sub Copy Bar: x=23, y=359, w=3, h=42 (#ffd200)
  - Sub Copy: x=36, y=359, w=310 (Medium 13px, lineHeight 20.8)

**링크 검증 필수:**
- 놓치지 마세요(액션 카드) 링크는 반드시 WebFetch로 사전 확인할 것
- 구글폼 마감/비공개 여부, 단축URL 리다이렉트 목적지 확인
- 접근 불가 링크는 대화 원문에서 대체 URL을 찾아 사용
