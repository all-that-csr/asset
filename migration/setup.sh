#!/bin/bash
# =============================================
# 올댓CSR 매거진 - 새 PC 세팅 스크립트
# =============================================
# 사용법: bash setup.sh
#
# 이 스크립트가 하는 일:
# 1. Claude Code 설치 확인
# 2. /csr-magazine 스킬 파일 설치
# 3. 메모리 파일 설치 (축적된 피드백/컨벤션)
# 4. chat_filter.py 설치
# 5. 작업 폴더 구조 생성
# =============================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo "=========================================="
echo "  올댓CSR 매거진 - 새 PC 세팅"
echo "=========================================="
echo ""

# --- 0. OS 확인 ---
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo -e "${YELLOW}[!] Windows에서 직접 실행하셨네요.${NC}"
    echo "    WSL(Ubuntu)에서 실행해주세요: wsl bash setup.sh"
    exit 1
fi

# --- 1. Node.js 확인 ---
echo "[1/6] Node.js 확인..."
if command -v node &> /dev/null; then
    echo -e "  ${GREEN}OK${NC} node $(node --version)"
else
    echo -e "  ${RED}Node.js가 설치되어 있지 않습니다.${NC}"
    echo "  설치: curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt-get install -y nodejs"
    exit 1
fi

# --- 2. Claude Code 확인/설치 ---
echo "[2/6] Claude Code 확인..."
if command -v claude &> /dev/null; then
    echo -e "  ${GREEN}OK${NC} claude $(claude --version 2>/dev/null || echo 'installed')"
else
    echo -e "  ${YELLOW}Claude Code가 없습니다. 설치합니다...${NC}"
    npm install -g @anthropic-ai/claude-code
    if command -v claude &> /dev/null; then
        echo -e "  ${GREEN}OK${NC} Claude Code 설치 완료"
    else
        echo -e "  ${RED}설치 실패. 수동 설치 필요: npm install -g @anthropic-ai/claude-code${NC}"
        exit 1
    fi
fi

# --- 3. 홈 디렉토리 감지 ---
HOME_DIR="$HOME"
echo ""
echo "[3/6] 스킬 파일 설치..."

# /csr-magazine 커맨드 설치
COMMANDS_DIR="$HOME_DIR/.claude/commands"
mkdir -p "$COMMANDS_DIR"
cp "$(dirname "$0")/claude-config/commands/csr-magazine.md" "$COMMANDS_DIR/"
echo -e "  ${GREEN}OK${NC} $COMMANDS_DIR/csr-magazine.md"

# --- 4. 메모리 파일 설치 ---
echo "[4/6] 메모리 파일 설치..."

# 새 PC의 홈 경로에 맞는 메모리 디렉토리 생성
# Claude Code는 프로젝트 경로 기반으로 메모리를 관리함
# 홈 디렉토리에서 실행하므로 경로는 -home-[username]
USERNAME=$(whoami)
MEMORY_DIR="$HOME_DIR/.claude/projects/-home-$USERNAME/memory"
mkdir -p "$MEMORY_DIR"

# 메모리 파일 복사
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
for f in "$SCRIPT_DIR/claude-config/memory/"*.md; do
    filename=$(basename "$f")
    # MEMORY.md 내용에서 이전 경로를 새 경로로 치환
    sed "s|/home/hyem095|$HOME_DIR|g" "$f" > "$MEMORY_DIR/$filename"
done
echo -e "  ${GREEN}OK${NC} $(ls "$SCRIPT_DIR/claude-config/memory/"*.md | wc -l)개 메모리 파일 → $MEMORY_DIR/"

# --- 5. chat_filter.py 설치 ---
echo "[5/6] chat_filter.py 설치..."
WORK_DIR="$HOME_DIR/all_that_csr"
mkdir -p "$WORK_DIR"
cp "$SCRIPT_DIR/chat_filter.py" "$WORK_DIR/"
echo -e "  ${GREEN}OK${NC} $WORK_DIR/chat_filter.py"

# Python3 확인
if command -v python3 &> /dev/null; then
    echo -e "  ${GREEN}OK${NC} python3 $(python3 --version 2>&1)"
else
    echo -e "  ${YELLOW}[!] python3이 없습니다. chat_filter.py 사용을 위해 설치 필요${NC}"
    echo "  설치: sudo apt install python3"
fi

# --- 6. 작업 폴더 구조 안내 ---
echo "[6/6] 작업 폴더 구조 생성..."
mkdir -p "$WORK_DIR/asset/logo"
if [ -f "$SCRIPT_DIR/../asset/logo/logo-typeB.png" ]; then
    cp "$SCRIPT_DIR/../asset/logo/logo-typeB.png" "$WORK_DIR/asset/logo/"
    echo -e "  ${GREEN}OK${NC} 로고 파일 복사 완료"
fi
echo -e "  ${GREEN}OK${NC} $WORK_DIR/ 폴더 준비 완료"

# --- 완료 ---
echo ""
echo "=========================================="
echo -e "  ${GREEN}세팅 완료!${NC}"
echo "=========================================="
echo ""
echo "  다음 단계:"
echo ""
echo "  1. Claude Code 로그인 (최초 1회)"
echo "     $ claude"
echo "     (브라우저에서 Anthropic 계정 로그인)"
echo ""
echo "  2. GitHub 연결 (PDF 업로드 기능용)"
echo "     $ gh auth login"
echo "     $ gh auth switch --user all-that-csr"
echo ""
echo "  3. Figma MCP 연결 (썸네일 자동생성용)"
echo "     $ claude mcp add figma -- npx -y figma-developer-mcp --figma-api-key=YOUR_KEY"
echo "     (Figma API 키는 figma.com > Settings > Personal access tokens)"
echo ""
echo "  4. 매거진 만들기"
echo "     $ cd ~"
echo "     $ claude"
echo "     > /csr-magazine ~/all_that_csr/YYMMDD"
echo ""
echo "  사용법 상세: ~/all_that_csr/migration/NEW_PC_GUIDE.md"
echo ""
