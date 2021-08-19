# Windows の設定

## AutoHotKey

AutoHotKey は強力なスクリプティング機能を備えたキーバインドを変えるためのソフトウェア。

- [AutoHotkey](https://www.autohotkey.com/)

AutoHotkey のインストール後、 `*.ahk` のコンテキストメニューから「Compile Script」を選ぶと `*.exe` ができあがる。その `*.exe` をスタートアップに登録することで自動的にキーバインドの設定が読み込まれる。

## Windows Terminal + PowerShell

### 導入済みパッケージ

- [Cascadia Code Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases): PowerLine やアイコンを表示できるようにした Cascadia Code
- [Scoop](https://scoop.sh/): Windows 向けの CLI でパッケージをインストール
- [FFmpeg](https://www.gyan.dev/ffmpeg/builds/)
- [GNUWin32](https://sourceforge.net/projects/getgnuwin32/)
	- GNU のコマンドを Windows で使えるようにしたもの
	- gzip, iconv, make, pcregrep, pcretest, stat, uname, which, xargs を使用
- [gawk](https://www.vector.co.jp/soft/win95/util/se376460.html)
- [htpasswd](https://httpd.apache.org/)
- [less](https://github.com/jftuga/less-Windows)
- [nkf](https://www.vector.co.jp/soft/win95/util/se295331.html)
- [whois](https://docs.microsoft.com/ja-jp/sysinternals/downloads/whois)

#### PowerShell からインストール

```shell-session
Install-Module oh-my-posh -Scope CurrentUser
Install-Module z -Scope CurrentUser
scoop install 7z
scoop install bat
scoop install fd
scoop install fzf
scoop install ghostscript
scoop install gibo
scoop install git-with-openssh
scoop install jq
scoop install lsd
scoop install ripgrep
scoop install sed
scoop install tokei
scoop install uutils-coreutils
scoop install yarn
```

#### WSL からインストール

WSL で Ubuntu 18.0 を入れてある

```shell-session
sudo apt install certbot
sudo apt install dos2unix
sudo apt install expect
sudo apt install hexyl
sudo apt install ripgrep
sudo apt install zsh
```

### 設定ファイルの場所

- PowerShell: %UserProfile%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
- Windows Terminal: [設定] → (左下の歯車)[settings.json を開きます]

### 参考

- [Windows TerminalとPowerShellでクールなターミナル環境をつくってみた (Tadashi Aikawa)](https://blog.mamansoft.net/2020/05/31/windows-terminal-and-power-shell-makes-beautiful/)
