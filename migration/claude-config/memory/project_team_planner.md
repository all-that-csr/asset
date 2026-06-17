# 스콘팀 일정관리 웹 툴 구축

## 프로젝트 위치
- 앱: `~/planning/team-planner-app/`
- 원본 CSV: `~/planning/team_planner/스콘팀_일정관리 - 스콘팀_일정관리_2026.csv`

## 상태: Vercel 배포 완료, 이메일 자동화 추가
- `npx next build` 성공
- API 정상 동작 확인 (members, projects, events, workload)
- DB 시드 완료: 5명 멤버, 29개 프로젝트, 37개 마일스톤, 7개 이벤트, 1개 팀 이벤트
- 실행: `cd ~/planning/team-planner-app && npm run dev`
- Vercel 프로젝트: `team-planner-app` (project.json 있음)

## 구현된 기능
- `/` 메인 간트차트: 좌측 고정 패널 + 우측 스크롤 타임라인, 담당자별 그룹핑/접기, 주말 음영, 오늘 빨간선, 주간/월간/연간 뷰, 필터(담당자/상태/검색)
- `/workload` 업무량 뷰: 멤버별 활성 프로젝트 막대그래프 + 동시 3건 이상 충돌 감지
- 프로젝트 CRUD: 추가/수정/삭제 모달, 마일스톤 인라인 편집
- 마일스톤 마커 (호버 툴팁), 개인 이벤트, 팀 이벤트 배너

## 이메일 자동화 (2026-05 추가)
- **데일리 브리핑**: Vercel Cron `/api/cron/daily-digest`, 매일 UTC 00:00 (KST 09:00), 주말/공휴일 스킵
- SMTP: nodemailer + Outlook (smtp.office365.com:587), 환경변수 `OUTLOOK_EMAIL`, `OUTLOOK_PASSWORD`
- 수신자: members 테이블 email 컬럼에 등록된 팀원 (이보라 제외)
- 중복 발송 방지: `notification_log` 테이블로 하루 1회 체크
- DB 추가 테이블: `notification_log`, `holidays`
- `vercel.json`에 cron 설정, 미들웨어에서 `/api/cron/*`은 `CRON_SECRET` 헤더로 인증
- Vercel 환경변수: CRON_SECRET, OUTLOOK_EMAIL, OUTLOOK_PASSWORD, TURSO_*, SESSION_SECRET, TEAM_PASSWORD 모두 필요

## 기술 스택
- Next.js 14 (App Router), Turso (libsql), Drizzle ORM
- Tailwind CSS v3, 수동 shadcn 컴포넌트 (Radix UI), tailwindcss-animate
- date-fns (ko locale), papaparse (시드용), nodemailer (이메일), resend (미사용으로 전환)

## 팀원/색상
- 미정: #ED2428, 박채림: #cfe2f3, 장원창: #d9ead3, 도혜미: #D2EFEC, 이보라: #FFD4D5

## 주의사항
- shadcn v2(base-nova)는 Tailwind v4 전용 → 수동으로 Tailwind v3 호환 컴포넌트 작성함
- Drizzle schema에서 projects 테이블 self-reference는 타입 오류 유발 → parent_id를 plain integer로 처리
- Vercel 환경변수 변경 후 반드시 재배포 필요 (자동 반영 안 됨)
