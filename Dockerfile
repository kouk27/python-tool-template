FROM python:3.12-slim

ENV HOME=/tmp \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /work

# 依存を先に入れてレイヤキャッシュを効かせる（requirements.txt は空でも可）
COPY requirements.txt /work/requirements.txt
RUN pip install --no-cache-dir -r /work/requirements.txt

# 非 root ユーザ（compose の user: でホストの UID/GID に上書きされる想定）
RUN useradd -m -u 1000 app
USER app

# 実行スクリプトは実行時に引数で渡す:
#   docker compose run --rm tool src/your_script.py --foo bar
ENTRYPOINT ["python"]
