# Python ツール用 汎用テンプレ

Python のバッチ／CLI ツールを **Docker で隔離して開発・実行** するためのテンプレートです。
開発環境は **VSCode の devcontainer でも、素の CLI（`docker compose`）でも** 同じものを使えます。

---

## ディレクトリ構成

```
.
├── dev/
│   └── Dockerfile                # 開発用イメージ（Python + Claude Code + pytest）
├── .devcontainer.json            # VSCode 用。compose の dev サービスを参照（※先頭ドット必須）
├── Dockerfile                    # 実行用イメージ（非root・任意UID・スクリプトは引数）
├── compose.yaml                  # dev / tool の2サービス
├── compose.override.yml.example  # compose.override.ymlの設定例
├── requirements.txt              # ← プロジェクトの依存を書く（プレースホルダ）
├── .env.example                  # Linux 用の UID/GID 設定例
├── .gitignore
└── src/                          # ソース（example.py が動作確認用）
```

---

## 初回セットアップ（CLI / devcontainer 共通・必須）

```bash
cp compose.override.yml.example compose.override.yml
# 必要に応じて ~/.claude のパス等を自分の環境に合わせて編集
```

## 使用方法（開発）

### A. CLI

```bash
# 開発イメージをビルド
docker compose build dev

# 対話シェルに入る（この中で Claude Code を動かす）
docker compose run --rm dev bash
  # ↓ コンテナ内で
  claude                                    # 初回サインイン / コード生成
  pip install --user -r requirements.txt    # 依存を入れる（更新したとき）
  pytest -q                                 # テスト

# 常駐させて使う場合
docker compose up -d dev
docker compose exec dev bash
```

### B. VSCode devcontainer

1. このフォルダを VSCode で開く → コマンドパレット → **Dev Containers: Reopen in Container**
   （`.devcontainer.json` 経由で compose の `dev` サービスが起動する）
2. ターミナルで `claude` でサインイン → 開発。`requirements.txt` は `postCreateCommand` で自動導入。

---

## 使用方法（開発済みツールの実行）

```bash
# 疎通確認
docker compose run --rm tool src/example.py hello

# 実際のツール
docker compose run --rm tool src/your_script.py --input input/x.json --output output/y.json
```
- `requirements.txt` を変更したらイメージを作り直す：`docker compose build tool`
- Linux で出力をホスト所有に合わせるなら初回に：
  ```bash
  printf "UID=%s\nGID=%s\n" "$(id -u)" "$(id -g)" > .env
  ```
  （macOS / Windows は自動マッピングのため不要）

---

## 新しいツールに合わせて直す3か所

| 箇所 | 既定 | 変更指針 |
| --- | --- | --- |
| **依存** `requirements.txt` | 空（プレースホルダ） | 使うパッケージを記載（例 `python-dateutil`, `pandas`） |
| **実行スクリプト** | `tool` は `ENTRYPOINT ["python"]`、スクリプトは実行時引数 | 固定したいなら `Dockerfile` を `ENTRYPOINT ["python","src/main.py"]` に |
| **ネットワーク** | `tool` の `network_mode: none` はコメントアウト（通信可） | 外部通信しないツールは有効化して隔離。API/DB を使うなら無効のまま |

その他：重い OS 依存ライブラリのビルドが要る場合は実行用 `Dockerfile` に
`apt-get install build-essential` を追加、または `python:3.12`（非 slim）へ。
