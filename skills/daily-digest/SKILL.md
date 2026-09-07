---
name: daily-digest
description: GitHub の Issue と PR を検索して今日の活動を要約する。ユーザーが「今日何やったっけ」「活動をまとめて」「daily-digest」「GitHub の活動を確認」のように今日の作業内容の振り返りや要約を求めたときに使う。
allowed-tools: Bash, Read
---

GitHub 上の今日の活動を `gh` コマンドで検索し、各 Issue/PR で何をしたかを要約してユーザーに表示する。ファイルへの書き込みは行わない。

## 手順

### 1. 今日の日付を取得する

CLAUDE.md の `currentDate` から今日の日付を取得する。以下 `$TODAY` と表記する。

### 2. GitHub の検索を実行する

以下の4つの検索を実行する。実行順序や実行方法は、検索結果の件数や実行環境に応じて適切に選択する:

```bash
gh search issues --author=@me --updated=$TODAY --limit 50 --json title,url,updatedAt,state,repository
gh search prs --author=@me --updated=$TODAY --limit 50 --json title,url,updatedAt,state,repository
gh search prs --reviewed-by=@me --updated=$TODAY --limit 50 --json title,url,updatedAt,state,repository
gh search issues --commenter=@me --updated=$TODAY --limit 50 --json title,url,updatedAt,state,repository
```

### 3. 重複を排除して各 Issue/PR の詳細を取得する

検索結果の URL で重複を排除し、ユニークな Issue/PR それぞれについて詳細を取得する。取得方法は、対象件数や実行環境に応じて適切に選択する:

- Issue の場合:
```bash
gh issue view <number> --repo <owner/repo> --json title,body,comments --jq '{title, body: .body[:500], comments: [.comments[] | select(.createdAt >= "$TODAY" or .updatedAt >= "$TODAY") | {author: .author.login, body: .body[:300], createdAt}]}'
```

- PR の場合:
```bash
gh pr view <number> --repo <owner/repo> --json title,body,comments,reviews,mergedAt --jq '{title, body: .body[:500], mergedAt, comments: [.comments[] | select(.createdAt >= "$TODAY") | {author: .author.login, body: .body[:300], createdAt}], reviews: [.reviews[] | select(.submittedAt >= "$TODAY") | {author: .author.login, body: .body[:300], state: .state}]}'
```

### 4. 要約を生成する

取得した情報をもとに、以下のフォーマットで要約を生成してユーザーに表示する:

- 1つの事柄を1つのリストアイテムとして記述する
- 各リストアイテムは、今日その Issue/PR で**自分が何をしたか**を後で見直して分かるように短い文章で記述する
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

- body や comments の内容から、今日の具体的な活動内容（コメントした、マージした、クローズした、レビューした等）を読み取って記述する
- 今日のコメントやレビューがない Issue/PR は、今日更新があっただけで自分が何かしたわけではない可能性がある。その場合は含めなくてよい
- `gh` の出力が空の場合は「今日の GitHub 上の活動は見つかりませんでした」と表示する
