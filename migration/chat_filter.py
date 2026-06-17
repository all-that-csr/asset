"""
카카오톡 대화 내보내기 파일에서 특정 날짜 범위만 추출하는 스크립트

사용법:
    python3 chat_filter.py [폴더경로] [시작일] [종료일]

예시:
    python3 chat_filter.py ~/all_that_csr/260409 2026-04-07 2026-04-09
"""

import sys
import os
import re
import glob
from datetime import datetime

def parse_date_header(line):
    """카카오톡 날짜 구분선에서 날짜 추출"""
    match = re.search(r'(\d{4})년 (\d{1,2})월 (\d{1,2})일', line)
    if match:
        return datetime(int(match.group(1)), int(match.group(2)), int(match.group(3)))
    return None

def filter_chat(filepath, start_date, end_date):
    """채팅 파일에서 날짜 범위에 해당하는 내용만 추출"""
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # 첫 줄(채팅방 이름) + 둘째 줄(저장 날짜)은 항상 유지
    header = []
    if len(lines) >= 1:
        header.append(lines[0])
    if len(lines) >= 2:
        header.append(lines[1])

    filtered = []
    in_range = False

    for line in lines[2:]:
        date = parse_date_header(line)
        if date:
            in_range = start_date <= date <= end_date

        if in_range:
            filtered.append(line)

    if not filtered:
        return None

    return ''.join(header) + '\n' + ''.join(filtered)

def main():
    if len(sys.argv) != 4:
        print("사용법: python3 chat_filter.py [폴더경로] [시작일] [종료일]")
        print("예시:   python3 chat_filter.py ~/all_that_csr/260409 2026-04-07 2026-04-09")
        sys.exit(1)

    folder = os.path.expanduser(sys.argv[1])
    start_date = datetime.strptime(sys.argv[2], '%Y-%m-%d')
    end_date = datetime.strptime(sys.argv[3], '%Y-%m-%d')

    # 폴더 내 모든 txt 파일 찾기
    txt_files = glob.glob(os.path.join(folder, '*.txt'))

    if not txt_files:
        print(f"❌ {folder}에 txt 파일이 없습니다")
        sys.exit(1)

    # 출력 폴더 생성
    output_dir = os.path.join(folder, 'filtered')
    os.makedirs(output_dir, exist_ok=True)

    count = 0
    for filepath in txt_files:
        filename = os.path.basename(filepath)
        result = filter_chat(filepath, start_date, end_date)

        if result:
            output_path = os.path.join(output_dir, filename)
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(result)
            count += 1
            print(f"✅ {filename} → filtered/{filename}")
        else:
            print(f"⏭️ {filename} — 해당 기간 대화 없음, 건너뜀")

    print(f"\n📁 {count}개 파일 필터링 완료 → {output_dir}")
    print(f"📌 이제 이렇게 실행하세요: /csr-magazine {output_dir}")

if __name__ == '__main__':
    main()
