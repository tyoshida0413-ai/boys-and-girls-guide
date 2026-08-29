#!/bin/bash
# Obsidian内の原本HTMLから index.html を再生成し、変更があれば GitHub へ push する。
#
#   使い方:  ./sync.sh  [コミットメッセージ]
#
# 原本は Artifact 用の断片HTML（<!doctype> や <head> を持たない）なので、
# ここで head/body の外枠を付けて GitHub Pages 用の単体HTMLに変換している。

set -euo pipefail

SRC="/Users/yoshidatomohiro/Library/Mobile Documents/iCloud~md~obsidian/Documents/second_brain/000.Inbox/Code-desktop/数字の認識について（小学低学年）/10といくつの壁.html"
DIR="$(cd "$(dirname "$0")" && pwd)"
DST="$DIR/index.html"
DESC="小学低学年で11以上の数がつかめないとき、原因を切り分け、10パターンの仮定ごとに具体的な対処を選ぶための支援者向け資料。"
MSG="${1:-資料を更新}"

if [ ! -f "$SRC" ]; then
  echo "✗ 原本が見つかりません:" >&2
  echo "  $SRC" >&2
  exit 1
fi

# --- index.html を再生成 ---------------------------------------------------
{
  printf '<!doctype html>\n<html lang="ja">\n<head>\n'
  printf '<meta charset="utf-8">\n'
  printf '<meta name="viewport" content="width=device-width, initial-scale=1">\n'
  printf '<meta name="description" content="%s">\n' "$DESC"
  # 原本の <div class="wrap"> の直前で head を閉じ、body を開く
  awk 'BEGIN{d=0} /^<div class="wrap">/ && d==0 {print "</head>"; print "<body>"; d=1} {print}' "$SRC"
  printf '</body>\n</html>\n'
} > "$DST.tmp"

# body が開かれたか（原本の構造が変わっていないか）を検証してから差し替える
if ! grep -q '^<body>$' "$DST.tmp"; then
  rm -f "$DST.tmp"
  echo "✗ 原本に <div class=\"wrap\"> が見つからず、body を開けませんでした。" >&2
  echo "  原本の構造が変わっている可能性があります。sync.sh の awk 条件を確認してください。" >&2
  exit 1
fi
mv "$DST.tmp" "$DST"

# --- 変更があれば push -----------------------------------------------------
cd "$DIR"
if git diff --quiet -- index.html && git diff --cached --quiet -- index.html; then
  echo "変更なし。push はしていません。"
  echo "https://tyoshida0413-ai.github.io/number-sense-guide/"
  exit 0
fi

git add index.html
git -c user.name="tyoshida0413-ai" -c user.email="t.yoshida.0413@gmail.com" \
    commit -q -m "$MSG"
git push -q origin main

echo "✓ push しました: $MSG"
echo "反映まで1〜2分かかります → https://tyoshida0413-ai.github.io/number-sense-guide/"
