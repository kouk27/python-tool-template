FROM python:3.12-slim

ENV HOME=/tmp \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /work

# 依存を先に入れてレイヤキャッシュを効かせる（requirements.txt は空でも可）
COPY requirements.txt /work/requirements.txt
RUN pip install --no-cache-dir -r /work/requirements.txt

# 既定 UID=1000 の app ユーザ。compose の user: が UID/GID を上書きするが、
# Mac/Win や UID=1000 の Linux では本ユーザに一致して HOME 等が活きる。
# UID≠1000 の Linux では無名 UID で動くため、ENV HOME=/tmp が HOME を確保する。
RUN useradd -m -u 1000 app
USER app

# 実行スクリプトは実行時に引数で渡す:
#   docker compose run --rm tool src/your_script.py --foo bar
ENTRYPOINT ["python"]
