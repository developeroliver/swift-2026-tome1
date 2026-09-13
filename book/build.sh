#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

OUT="${1:-Swift-2026-Tome1.pdf}"

pandoc parts/*.md \
  -o "$OUT" \
  --pdf-engine=weasyprint \
  --css=style.css \
  --metadata lang=fr \
  --syntax-highlighting=breezedark \
  -f markdown+raw_html

python3 - "$OUT" << 'PYEOF'
import sys
from pypdf import PdfReader, PdfWriter

path = sys.argv[1]
reader = PdfReader(path)
writer = PdfWriter()
writer.append(reader)
writer.add_metadata({
    "/Title": "Swift 2026 — Tome 1 : Maîtriser le langage",
    "/Author": "Olivier Geiger",
    "/Subject": "Apprendre Swift de zéro à un niveau avancé/expert",
    "/Language": "fr",
})
with open(path, "wb") as f:
    writer.write(f)
PYEOF

echo "PDF généré : $OUT"
