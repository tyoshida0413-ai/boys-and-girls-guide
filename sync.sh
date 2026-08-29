#!/bin/bash
# Obsidian内の原本HTMLから公開用HTMLを再生成し、変更があれば GitHub へ push する。
#
#   使い方:  ./sync.sh  [コミットメッセージ]
#
# 原本は Artifact 用の断片HTML（<!doctype> や <head> を持たない）なので、
# ここで head/body の外枠を付けて GitHub Pages 用の単体HTMLに変換している。
#
#   原本「10といくつの壁.html」        → index.html
#   原本「かずのゲーム印刷キット.html」 → games.html

set -euo pipefail

SRCDIR="/Users/yoshidatomohiro/Library/Mobile Documents/iCloud~md~obsidian/Documents/second_brain/000.Inbox/Code-desktop/数字の認識について（小学低学年）"
DIR="$(cd "$(dirname "$0")" && pwd)"
MSG="${1:-資料を更新}"

# build <原本ファイル名> <出力ファイル名> <meta description>
build() {
  local src="$SRCDIR/$1" dst="$DIR/$2" desc="$3"

  if [ ! -f "$src" ]; then
    echo "✗ 原本が見つかりません: $src" >&2
    exit 1
  fi

  {
    printf '<!doctype html>\n<html lang="ja">\n<head>\n'
    printf '<meta charset="utf-8">\n'
    printf '<meta name="viewport" content="width=device-width, initial-scale=1">\n'
    printf '<meta name="description" content="%s">\n' "$desc"
    # 原本の <div class="wrap"> または最初の <div ...> の直前で head を閉じ、body を開く
    awk 'BEGIN{d=0}
         d==0 && /^<(div|header|main|section|nav|script)[ >]/ {print "</head>"; print "<body>"; d=1}
         {print}
         END{if(d==0){print "BODY_NOT_OPENED" > "/dev/stderr"; exit 1}}' "$src"
    printf '</body>\n</html>\n'
  } > "$dst.tmp"

  if ! grep -q '^<body>$' "$dst.tmp"; then
    rm -f "$dst.tmp"
    echo "✗ $1 で body を開けませんでした。原本の構造が変わっている可能性があります。" >&2
    exit 1
  fi
  mv "$dst.tmp" "$dst"
  echo "  ✓ $2 を生成"
}

echo "生成中..."
build "10といくつの壁.html" "index.html" \
      "小学低学年で11以上の数がつかめないとき、原因を切り分け、10パターンの仮定ごとに具体的な対処を選ぶための支援者向け資料。"
build "かずのゲーム印刷キット.html" "games.html" \
      "直線型のすごろくと「どっちが多い」カードを、A4に印刷してすぐ遊べる形にした教材。1〜20の数を扱います。"

# --- 変更があれば push -----------------------------------------------------
cd "$DIR"
if git diff --quiet -- index.html games.html && git diff --cached --quiet -- index.html games.html; then
  echo "変更なし。push はしていません。"
  echo "https://tyoshida0413-ai.github.io/number-sense-guide/"
  exit 0
fi

git add index.html games.html
git -c user.name="tyoshida0413-ai" -c user.email="t.yoshida.0413@gmail.com" \
    commit -q -m "$MSG"
git push -q origin main

echo "✓ push しました: $MSG"
echo "反映まで1〜2分 →"
echo "  本文     https://tyoshida0413-ai.github.io/number-sense-guide/"
echo "  印刷キット https://tyoshida0413-ai.github.io/number-sense-guide/games.html"
