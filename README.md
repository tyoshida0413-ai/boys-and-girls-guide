# 児童の懸案事項ハブ

放課後等デイサービスの支援のなかで見えてきた「気になるつまずき・行動」を一つずつ取り上げ、
国内外の研究と実践を調べて、原因の切り分けと具体的な対応策を資料にまとめた資料集です。
各資料は公開情報の調査に基づく一般的な整理であり、診断や医学的助言ではありません。

公開ページ:

- トップ（ハブ）: https://tyoshida0413-ai.github.io/boys-and-girls-guide/
- 「10といくつ」の壁: https://tyoshida0413-ai.github.io/boys-and-girls-guide/number-sense.html
- かずのゲーム印刷キット: https://tyoshida0413-ai.github.io/boys-and-girls-guide/games.html

## 収録資料

### 「10といくつ」の壁（学習・認知 ／ 算数）

小学低学年で「10までは数えられるのに、11以上になると怪しい」という状態についての調査まとめ。

- 数の理解の5層モデル（数唱／計数／基数性／量感／十進位取り）
- 15分でできる切り分けチェック
- 想定される原因と対処 10パターン（原因・サイン・学術的裏づけ・具体策・判定の目印）
- 世界の指導法カタログ、6週間のプログラム案、記録テンプレート、出典
- 付属：かずのゲーム印刷キット（すごろく盤・比較カード）

## 更新の手順

原本（編集するのはこちら）— すべて同じフォルダ内:

```
second_brain/000.Inbox/Code-desktop/児童の懸案事項ハブ/
  ├ 懸案事項ハブ.html          → index.html      （トップ／ハブ）
  ├ 10といくつの壁.html        → number-sense.html
  └ かずのゲーム印刷キット.html → games.html
```

原本を編集したあと、このリポジトリで次を実行すると公開用HTMLが再生成され、
変更があれば自動で commit / push される。

```bash
./sync.sh "何を更新したか"
```

### 新しい懸案の資料を追加するとき

1. `児童の懸案事項ハブ/` に新しい断片HTML（例 `切り替えの困難.html`）を置く
2. `sync.sh` の `PAGES` 配列に1行足す（`原本名:::出力名:::description`）
3. `懸案事項ハブ.html` の一覧セクションにカードを追加する
4. `./sync.sh "◯◯の資料を追加"`

## メモ

- 原本は Artifact 用の断片HTML（`<!doctype>` や `<head>` を持たない）。`sync.sh` が外枠を付けて単体HTMLに変換している
- 最初のブロック要素（`<div>` / `<header>` など）の直前で head を閉じている。原本の冒頭構造を大きく変えた場合は `sync.sh` の awk 条件を確認する（body を開けなければエラーで止まる）
- `number-sense.html` は 2026-08-29 まで `index.html`（＝ルート）だった。同日ルートをハブに変更
- リポジトリ名は 2026-08-29 に `number-sense-guide` → `boys-and-girls-guide` に変更。旧URL（`tyoshida0413-ai.github.io/number-sense-guide/...`）は GitHub が新URLへリダイレクトする。原本内の絶対URL・sync.sh・READMEは新URLに更新済み
- Pages への反映は push から1〜2分
