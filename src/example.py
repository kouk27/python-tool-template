"""テンプレ動作確認用。
  docker compose run --rm tool src/example.py hello
で実行し、Python バージョンと渡した引数が表示されれば疎通OK。
"""
import sys
import platform


def main() -> None:
    print(f"Python {platform.python_version()} / argv={sys.argv[1:]}")


if __name__ == "__main__":
    main()
