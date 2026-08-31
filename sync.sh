#!/bin/bash
# Obsidian内の原本HTMLから公開用HTMLを再生成し、変更があれば GitHub へ push する。
#
#   使い方:  ./sync.sh  [コミットメッセージ]
#
# 原本は Artifact 用の断片HTML（<!doctype> や <head> を持たない）なので、
# ここで head/body の外枠を付けて GitHub Pages 用の単体HTMLに変換している。
#
#   原本「懸案事項ハブ.html」          → index.html      （トップ／ハブ）
#   原本「10といくつの壁.html」        → number-sense.html
#   原本「聞こえていないように見えるとき.html」 → not-listening.html
#   原本「切り替えられないとき.html」        → transitions.html
#   原本「字がマスにおさまらないとき.html」   → handwriting.html
#   原本「汚い言葉が出てしまうとき.html」    → swearing.html
#   原本「かずのゲーム印刷キット.html」 → games.html
#
# 新しい懸案の資料を追加するときは、下の PAGES 配列に1行足すだけ。

set -euo pipefail

SRCDIR="/Users/yoshidatomohiro/Library/Mobile Documents/iCloud~md~obsidian/Documents/second_brain/000.Inbox/Code-desktop/児童の懸案事項ハブ"
DIR="$(cd "$(dirname "$0")" && pwd)"
MSG="${1:-資料を更新}"

# 原本ファイル名 ::: 出力ファイル名 ::: meta description
PAGES=(
  "懸案事項ハブ.html:::index.html:::放課後等デイサービスの支援者向け。現場で気づいた児童のつまずき・気になる行動を、研究と実践を調べて原因の切り分けと対応策にまとめた資料集のトップ。"
  "10といくつの壁.html:::number-sense.html:::小学低学年で11以上の数がつかめないとき、原因を切り分け、10パターンの仮定ごとに具体的な対処を選ぶための支援者向け資料。"
  "聞こえていないように見えるとき.html:::not-listening.html:::注意しても聞こえていないように反応せず、人が多い場面でとくに目立つ子について、聞こえ・注意・処理・情動の経路を切り分け、10パターンの仮定ごとに環境調整と関わり方を選ぶための支援者向け資料。"
  "切り替えられないとき.html:::transitions.html:::自由遊びから次の活動へ移れず、大きな声や強い指示でないと動かない子について、切り替えが完了するまでの5層を切り分け、10パターンの仮定（没入・見通し・実行機能・不安・感覚過負荷・学習された大声・次の活動の回避・疲労・自閉的慣性・要求回避）ごとに、予告・合図・環境調整を選ぶための支援者向け資料。"
  "字がマスにおさまらないとき.html:::handwriting.html:::マス目があってもはみ出す、マスがないと字の大きさがそろわない子について、字が整うまでの6層（姿勢・見る力・手の運動・目と手の協応・字形の記憶・注意）を切り分け、9パターンの仮定ごとに姿勢・道具・書字練習の入れ方を選ぶための支援者向け資料。"
  "汚い言葉が出てしまうとき.html:::swearing.html:::発作的な大声とともに「死ね」「クソ」などの強い言葉が出る子について、言葉が出るまでを4層＋チック性の1経路に切り分け、8パターンの仮定（音声チック／情動の爆発／衝動抑制／感情語彙の不足／注目／要求・回避／発散／模倣）ごとに、叱責に頼らない対処を選ぶための支援者向け資料。"
  "かずのゲーム印刷キット.html:::games.html:::直線型のすごろくと「どっちが多い」カードを、A4に印刷してすぐ遊べる形にした教材。1〜20の数を扱います。"
)

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
    # 原本の <div class="wrap"> または最初のブロック要素の直前で head を閉じ、body を開く
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
OUTFILES=()
for row in "${PAGES[@]}"; do
  src="${row%%:::*}"; rest="${row#*:::}"
  out="${rest%%:::*}"; desc="${rest#*:::}"
  build "$src" "$out" "$desc"
  OUTFILES+=("$out")
done

# --- 変更があれば push -----------------------------------------------------
cd "$DIR"
if git diff --quiet -- "${OUTFILES[@]}" && git diff --cached --quiet -- "${OUTFILES[@]}"; then
  echo "変更なし。push はしていません。"
  echo "https://tyoshida0413-ai.github.io/boys-and-girls-guide/"
  exit 0
fi

git add "${OUTFILES[@]}"
git -c user.name="tyoshida0413-ai" -c user.email="t.yoshida.0413@gmail.com" \
    commit -q -m "$MSG"
git push -q origin main

echo "✓ push しました: $MSG"
echo "反映まで1〜2分 →"
echo "  トップ       https://tyoshida0413-ai.github.io/boys-and-girls-guide/"
echo "  10といくつ   https://tyoshida0413-ai.github.io/boys-and-girls-guide/number-sense.html"
echo "  聞こえ       https://tyoshida0413-ai.github.io/boys-and-girls-guide/not-listening.html"
echo "  切り替え     https://tyoshida0413-ai.github.io/boys-and-girls-guide/transitions.html"
echo "  書字         https://tyoshida0413-ai.github.io/boys-and-girls-guide/handwriting.html"
echo "  汚い言葉     https://tyoshida0413-ai.github.io/boys-and-girls-guide/swearing.html"
echo "  印刷キット   https://tyoshida0413-ai.github.io/boys-and-girls-guide/games.html"
