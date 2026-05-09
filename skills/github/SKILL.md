---
name: github
description: GitHub には `gh` コマンドを使ってアクセスする。GitHub Issue, PR, Actions などの GitHub へのアクセスが必要なときに使用する。
---

# GitHub Skill
GitHub にアクセスするときには `gh` コマンドを使う。Git レポジトリにいない場合には `--repo {org}/{repo}` を明示的に指定するか、 URL を直接指定する。

## `gh api` の使用

`gh api` は他のサブコマンドでは取得できない情報を取得する場合に使用する。

## JSON 出力
機械可読なデータが必要な場合は、 `--json` オプションを使う。フィルタする場合には `--jq` オプションを使う。
