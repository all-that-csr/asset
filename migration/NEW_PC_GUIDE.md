# 올댓CSR 매거진 - 새 PC 세팅 가이드

## 한눈에 보기

```
[이전 PC]                          [새 PC]
~/.claude/commands/csr-magazine.md  →  자동 설치 (setup.sh)
~/.claude/.../memory/*.md           →  자동 설치 (setup.sh)
~/all_that_csr/chat_filter.py       →  자동 설치 (setup.sh)
~/all_that_csr/asset/               →  GitHub에서 clone
Anthropic 계정                      →  claude 실행 시 로그인
GitHub all-that-csr 계정            →  gh auth login
Figma MCP                          →  claude mcp add (선택)
```

---

## Step 1. 사전 준비 (새 PC에서)

### WSL + Ubuntu 설치 (Windows인 경우)
```powershell
# PowerShell (관리자)에서:
wsl --install
# 재부팅 후 Ubuntu 터미널 열기
```

### Node.js 설치
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Python3 설치 (보통 이미 있음)
```bash
sudo apt install python3
```

### GitHub CLI 설치
```bash
sudo apt install gh
```

---

## Step 2. migration 폴더 옮기기

이 `migration` 폴더 전체를 새 PC로 옮기세요.

**방법 1: USB / 클라우드**
- 이 `migration` 폴더를 USB나 구글 드라이브로 옮기기

**방법 2: GitHub에서 받기**
- `all-that-csr/asset` 레포에 migration 폴더를 push 해두면 새 PC에서 clone

---

## Step 3. 자동 설치

```bash
# migration 폴더로 이동
cd ~/all_that_csr/migration   # (또는 옮긴 경로)

# 설치 스크립트 실행
bash setup.sh
```

이 스크립트가 자동으로:
- Claude Code 설치 (없으면)
- `/csr-magazine` 스킬 파일 설치
- 메모리 파일 설치 (축적된 피드백/규칙)
- `chat_filter.py` 설치
- 작업 폴더 구조 생성

---

## Step 4. 계정 연결

### Claude Code 로그인
```bash
claude
# 처음 실행하면 브라우저가 열립니다
# Anthropic 계정으로 로그인
```

### GitHub 연결 (PDF 다운로드 링크 생성용)
```bash
gh auth login
# → GitHub.com > HTTPS > Login with a web browser
# 로그인 후:
gh auth switch --user all-that-csr
```

### Figma MCP 연결 (썸네일 자동 생성용, 선택사항)
```bash
# Figma Personal Access Token 필요
# figma.com > Settings > Personal access tokens > Generate new token
claude mcp add figma -- npx -y figma-developer-mcp --figma-api-key=YOUR_FIGMA_TOKEN
```

---

## Step 5. asset 레포 clone

```bash
cd ~/all_that_csr
git clone https://github.com/all-that-csr/asset.git
```

---

## Step 6. 사용하기

### 매거진 생성
```bash
cd ~
claude

# Claude Code 안에서:
/csr-magazine ~/all_that_csr/YYMMDD
```

### 작업 흐름
1. 카카오톡에서 대화 내보내기 (.txt)
2. `~/all_that_csr/YYMMDD/` 폴더에 넣기 (PDF, 이미지도 함께)
3. `/csr-magazine ~/all_that_csr/YYMMDD` 실행
4. 날짜 범위 답변
5. 생성 완료 → `매거진_YYYY-MM-DD_YYYY-MM-DD.html` + `thumbnail.html` + Figma 썸네일

---

## 폴더 구조

```
~/
├── .claude/
│   ├── commands/
│   │   └── csr-magazine.md          ← 스킬 정의 (800줄)
│   └── projects/-home-USERNAME/
│       └── memory/
│           ├── MEMORY.md            ← 메모리 인덱스
│           ├── project_csr_magazine_v3.md
│           ├── feedback_*.md        ← 축적된 피드백
│           └── ...
│
└── all_that_csr/
    ├── chat_filter.py               ← 날짜 필터 스크립트
    ├── asset/                       ← GitHub 레포 (clone)
    │   └── logo/logo-typeB.png
    ├── 260402/                      ← 주차별 대화 폴더
    ├── 260407/
    └── ...
```

---

## 문제 해결

| 문제 | 해결 |
|------|------|
| `claude` 명령어 안 됨 | `npm install -g @anthropic-ai/claude-code` |
| `/csr-magazine` 안 됨 | `~/.claude/commands/csr-magazine.md` 파일 확인 |
| `chat_filter.py` 오류 | `python3 --version` 확인, 없으면 `sudo apt install python3` |
| PDF 링크 안 됨 | `gh auth status`로 all-that-csr 계정 확인 |
| Figma 연결 안 됨 | `claude mcp list`로 figma 서버 확인 |
| 이전 매거진 Vol 번호 모름 | Claude에게 "현재 Vol 몇 호야?" 물어보면 메모리에서 확인 |

---

## 이 폴더에 포함된 파일

```
migration/
├── setup.sh                         ← 자동 설치 스크립트
├── NEW_PC_GUIDE.md                  ← 이 가이드
├── chat_filter.py                   ← 날짜 필터링 스크립트
└── claude-config/
    ├── commands/
    │   └── csr-magazine.md          ← 매거진 생성 스킬 (800줄)
    └── memory/
        ├── MEMORY.md
        ├── project_csr_magazine_v3.md
        ├── feedback_article_title.md
        ├── feedback_auto_vol_number.md
        ├── feedback_check_images.md
        ├── feedback_no_arbitrary_copy.md
        ├── feedback_no_dryrun_overwrite.md
        ├── feedback_pdf_read.md
        ├── project_v5_layout_sample.md
        ├── reference_clab_platform.md
        ├── reference_estimation_structure.md
        └── user_causeworks.md
```
