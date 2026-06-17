# GA4 대시보드: 테스트 데이터 덮어쓰기 금지

- `python3 main.py --dry-run` 은 샘플 데이터로 preview를 생성하므로, 실제 데이터가 덮어씌워질 위험이 있다.
- 코드 변경 후 확인할 때는 **절대 `--dry-run` 사용 금지**.
- 대신 `master_data.json`에서 직접 HTML을 재빌드하는 방식으로 확인:
  ```python
  python3 -c "
  from report_html import _load_master_data, _build_master_html, MASTER_PATH
  master = _load_master_data()
  html = _build_master_html(master)
  with open(MASTER_PATH, 'w', encoding='utf-8') as f:
      f.write(html)
  "
  ```
- 데스크톱에 복사할 때도 반드시 실제 마스터 대시보드 파일을 복사할 것.
