# MSYS2 auto install

MSYS2のインストールを自動化します。

# Features
- 以下を自動化します :
  - MSYS2を公式サイトからダウンロードする
  - MSYS2をカレントディレクトリ配下にインストールする
    - レジストリやシステム環境変数に影響を与えません
    - 任意のディレクトリに移動しても動作します
  - MSYS2にgccとclangをインストールする
  - hello worldをコンパイルして実行する
    - MSYS2がない環境でも動作します（DLLに依存しません）
  - mingw64起動batを生成する
    - このbatを実行するとMSYS2にmingw64モードでbashログインしてgccとclangが使えます
  - 上記すべてのログを出力する

- 環境を汚さないため、手軽に扱えます。
- コマンドプロンプトからこのコマンドを実行するだけで自動ですべてが完了します。面倒な操作は不要です。
```
curl.exe -L https://raw.githubusercontent.com/cat2151/msys2-auto-install/main/MSYS2_get_and_install.bat --output MSYS2_get_and_install.bat && MSYS2_get_and_install.bat
```

# Requirement
- Windows
- 3GB程度の空き容量
- 7分～30分程度の時間（ネットワーク速度により変わります）
- batを実行する場所のフルパス名に半角スペースや日本語を含まないこと
