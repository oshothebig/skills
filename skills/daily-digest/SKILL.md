---
name: daily-digest
description: GitHub の Issue と PR を検索して、指定日の活動を要約する。ユーザーが「今日何やったっけ」「昨日の活動をまとめて」「2026-09-01 の活動をまとめて」「daily-digest」「GitHub の活動を確認」のように作業内容の振り返りや要約を求めたときに使う。
allowed-tools: Bash, Read
---

GitHub 上の指定日の活動を `gh` コマンドで検索し、各 Issue/PR で何をしたかを要約してユーザーに表示する。ファイルへの書き込みは行わない。

## 手順

### 1. 対象日を決定する

- 日付が指定されていない場合には今日の日付を対象日とする。
- 日付が指定されている場合にはその日を対象日とする。
- 指定された日付が不明な場合にはユーザに対象日を確認する。

以下、対象日を `{TARGET_DATE}` と表記する。

### 2. GitHub の検索を実行する

`gh` コマンドを使い、対象日に自分が活動した可能性のある Issue/PR を検索する。

- 自分が作成した Issue/PR、自分がレビューした PR、自分がコメントした Issue/PR を検索対象とする。
- 自分を表す検索条件には、利用可能な場合は `@me` を優先して使う。具体的なユーザー名が必要な場合にのみ取得する。
- 対象日の活動を拾えるように検索条件を選択する。検索結果だけでは対象日に自分が活動したと判断せず、次の手順で詳細を確認する。
- サブコマンド、検索条件の組み合わせ、取得項目、実行順序は、検索結果や実行環境に応じて選択する。
- 取得件数の上限により結果が欠落する場合は、追加取得や検索条件の分割を行う。
- 後続の詳細取得と重複排除に必要な、Issue/PR の URL などの識別情報を取得する。

### 3. 重複を排除して各 Issue/PR の詳細を取得する

検索結果の URL で重複を排除し、ユニークな Issue/PR それぞれについて詳細を取得する。取得方法は、対象件数や実行環境に応じて適切に選択する:

- Issue の場合:
```bash
gh issue view <number> --repo <owner/repo> --json title,body,comments --jq '{title, body: .body[:500], comments: [.comments[] | select(.createdAt >= "{TARGET_DATE}" or .updatedAt >= "{TARGET_DATE}") | {author: .author.login, body: .body[:300], createdAt}]}'
```

- PR の場合:
```bash
gh pr view <number> --repo <owner/repo> --json title,body,comments,reviews,mergedAt --jq '{title, body: .body[:500], mergedAt, comments: [.comments[] | select(.createdAt >= "{TARGET_DATE}") | {author: .author.login, body: .body[:300], createdAt}], reviews: [.reviews[] | select(.submittedAt >= "{TARGET_DATE}") | {author: .author.login, body: .body[:300], state: .state}]}'
```

### 4. 要約を生成する

取得した情報をもとに、以下のフォーマットで要約を生成してユーザーに表示する:

- 1つの事柄を1つのリストアイテムとして記述する
- 各リストアイテムは、対象日その Issue/PR で**自分が何をしたか**を後で見直して分かるように短い文章で記述する
- サブリストに関連する Issue/PR の URL を記載する
- 関連する Issue と PR は1つのリストアイテムにまとめてよい（例: Issue とその対応 PR）

### 出力フォーマット例

```
- Claude Enterprise 利用方針を決定し、Slack でアナウンスした。Issue をクローズ。
    - https://github.com/org/repo/issues/123
- ノードの IP アドレスを IPAM として扱うためのデータの定義を行う PR を作成した。
    - https://github.com/org/repo/issues/456
    - https://github.com/org/repo/pull/789
- ストレージノードをの移行を行うための計画を立てた。
    - https://github.com/org/repo/pull/101
```

### 注意点

- body や comments の内容から、対象日の具体的な活動内容（コメントした、マージした、クローズした、レビューした等）を読み取って記述する
- コメントやレビューがない Issue/PR は、更新があっただけで自分が何かしたわけではない可能性がある。その場合は含めなくてよい
- `gh` の出力が空の場合は「{TARGET_DATE}の GitHub 上の活動は見つかりませんでした」と表示する
