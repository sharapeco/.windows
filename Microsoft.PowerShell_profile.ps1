# ----------------------------------------------------------------
# General
# ----------------------------------------------------------------

# CP932 をやめて UTF-8 を使用する
[System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
[System.Console]::InputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

# git log などで使用
$env:LESSCHARSET = "utf-8"
$env:GIT_SSH = "C:\Windows\System32\OpenSSH\ssh.exe"

# Keybinding
Set-PSReadLineOption -EditMode Emacs

# ----------------------------------------------------------------
# Powerline
# ----------------------------------------------------------------

# Windows Terminal のみで有効にする
if ($env:WT_PROFILE_ID) {
	Import-Module oh-my-posh
	Set-PoshPrompt -Theme pure
}

# ----------------------------------------------------------------
# fzf
# ----------------------------------------------------------------

$env:FZF_DEFAULT_OPTS="--reverse --border --height 50%"
$env:FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git --exclude node_modules --exclude backup .'

# 内部で使うための fd のデフォルトオプション
function MyFind {
	fd --hidden --follow --exclude .git --exclude node_modules --exclude backup $args
}

# 履歴検索
function FuzzyHistory {
    if (Get-Command Get-PSReadLineOption -ErrorAction SilentlyContinue) {
        $result = Get-Content (Get-PSReadLineOption).HistorySavePath | fzf --no-sort --tac
    } else {
        $result = Get-History | ForEach-Object { $_.CommandLine } | fzf --no-sort --tac
    }
    if ($null -ne $result) {
        Write-Output "Invoking '$result'`n"
        Invoke-Expression "$result" -Verbose
    }
}
New-Alias -Name fh -Scope Global -Value FuzzyHistory -ErrorAction Ignore

# カレントディレクトリ配下のディレクトリに cd
function FuzzyMoveDownDirectory {
	MyFind --type d | fzf | cd
}
New-Alias -Name jd -Scope Global -Value FuzzyMoveDownDirectory -ErrorAction Ignore

# 指定したパスの中からファイルを選択する
function FuzzySelectFile {
	param ([string]$path = '.')

	if ((Get-Item $path).PSIsContainer) {
		# フォルダの場合は fzf でファイルを選ぶ
		$selected = MyFind --search-path $path |
		  fzf --preview "bat --color=always --style=plain --line-range :100 {}"
		if ($selected) {
			return "$selected"
		}
	} else {
		return "$path"
	}
}

function FuzzyOpenWithXyzzy {
	[CmdletBinding()]
	param ([string]$path = '.')
	FuzzySelectFile $path | % { C:\Apps\xyzzy\xyzzycli $_ }
}
New-Alias -Name vi -Scope Global -Value FuzzyOpenWithXyzzy -ErrorAction Ignore

# ----------------------------------------------------------------
# z - jump around
# ----------------------------------------------------------------

Import-Module z
function FuzzyJumpAround {
	z -l | oss | select -skip 3 | % { $_ -split " +" } | sls -raw '^[a-zA-Z].+' | fzf | cd
}
New-Alias -Name jp -Scope Global -Value FuzzyJumpAround -ErrorAction Ignore

# ----------------------------------------------------------------
# Linux like commands
# ----------------------------------------------------------------

# パイプラインを受けつけないLinux標準コマンド
Remove-Item alias:cp
Remove-Item alias:ls
Remove-Item alias:mv
Remove-Item alias:rm
function cksum { uutils cksum $args }
function cp { uutils cp $args }
function df { uutils df $args }
function du { uutils du $args }
function factor { uutils factor $args }
function gdate { uutils date $args }
function gecho { uutils echo $args }
function hashsum { uutils hashsum $args }
function ln { uutils ln $args }
function ls { uutils ls $args }
function mkdir { uutils mkdir $args }
function mv { uutils mv $args }
function printenv { uutils printenv $args }
function rm { uutils rm $args }
function seq { uutils seq $args }
function sha1sum { uutils sha1sum $args }
function shred { uutils shred $args }
function sleep { uutils sleep $args }
function tee { uutils tee $args }
function touch { uutils touch $args }
function yes { uutils yes $args }

# パイプラインを受けつけるLinux標準コマンド
Remove-Item alias:cat
Remove-Item alias:pwd
function cat { $input | uutils cat $args }
function cut { $input | uutils cut $args }
function head { $input | uutils head $args }
function pwd { $input | uutils pwd $args }
function tail { $input | uutils tail $args }
function tr { $input | uutils tr $args }
function uniq { $input | uutils uniq $args }
function wc { $input | uutils wc $args }

# ⚠ readonlyのaliasなので問題が発生するかも..
Remove-Item alias:sort -Force
function sort { $input | uutils sort $args }

# ll
function ll { lsd -l --blocks permission --blocks size --blocks date --blocks name --blocks inode $args }

# tree
function tree { lsd --tree $args }

# ----------------------------------------------------------------
# Utility for WSL
# ----------------------------------------------------------------

function Convert-Windows-Path-To-WSL {
	$args | % {
		if ($_ -is [string]) {
			return $_.Replace('\', '/').Replace('C:/', '/mnt/c/')
		} else {
			return $_
		}
	}
}

function hexyl {
	$largs = Convert-Windows-Path-To-WSL @args
	$input | wsl hexyl $largs
}

function certbot {
	wsl certbot $(Convert-Windows-Path-To-WSL @args)
}

function certbot-create {
	[CmdletBinding()]
	param (
		[string]$domain
	)
	if ([string]::IsNullorEmpty($domain)) {
		Write-Host "Certbot で証明書を発行する"
		Write-Host ""
		Write-Host "USAGE:"
		Write-Host "    certbot-create <domain>"
		Write-Host ""
		Write-Host "証明書ファイルは C:/Server/certs/<domain>/ にできるよ"
		return
	}
	wsl certbot certonly `
	  --manual `
	  --domain $domain `
	  --preferred-challenges dns `
	  --work-dir ~/var/lib/letsencrypt `
	  --logs-dir ~/var/log/letsencrypt `
	  --config-dir ~/etc/letsencrypt
	wsl fd $domain ~/etc/letsencrypt/live `
	  --type d `
	  --exec cp -RL '{}' /mnt/c/Server/certs/
}

# ----------------------------------------------------------------
# Windows Services
# ----------------------------------------------------------------

function nginx-restart {
	# sudo sc stop nginx
	sudo taskkill /f /IM nginx.exe
	sudo sc start nginx
}

function unbound-restart {
	sudo sc stop unbound
	sudo sc start unbound
}

# ----------------------------------------------------------------
# Misc
# ----------------------------------------------------------------

function convert-ppk-to-pem {
	[CmdletBinding()]
	param (
		[string]$ppk
	)
	if ([string]::IsNullorEmpty($ppk)) {
		Write-Host "PuTTY 形式の秘密鍵を OpenSSH 形式に変換する"
		Write-Host ""
		Write-Host "USAGE:"
		Write-Host "    convert-ppk-to-pem <ppk-file>"
		return
	}
	$file = Get-Item $ppk
	$base = Join-Path $file.DirectoryName $file.BaseName
	$uppk = $ppk.Replace('\', '/')
	$upem = "$base.pem".Replace('\', '/').Replace('C:/', '/mnt/c/')
	echo "$uppk -> $upem"
	wsl puttygen -O private-openssh "$uppk" -o "$upem"
}

function passwd-pem {
	[CmdletBinding()]
	param (
		[string]$pem
	)
	if ([string]::IsNullorEmpty($pem)) {
		Write-Host "OpenSSH 形式の秘密鍵のパスフレーズを変更する"
		Write-Host ""
		Write-Host "USAGE:"
		Write-Host "    passwd-pem <pem-file>"
		return
	}
	ssh-keygen -f "$pem" -p
}

function crop-images {
	[CmdletBinding()]
	param (
		[string]$glob,
		[string]$cropParam
	)
	if ([string]::IsNullorEmpty($cropParam)) {
		Write-Host "指定した画像を一括で切り抜きする"
		Write-Host "出力ファイル名は crop-<元のファイル名> となる"
		Write-Host ""
		Write-Host "USAGE:"
		Write-Host "    crop-images <glob> <crop-param>"
		Write-Host ""
		Write-Host "<crop-param>: <width>x<height>+<x>+<y>"
		return
	}
	foreach ($f in Get-Item $glob) {
		$o = $f.Directory.ToString() + "\crop-" + $f.BaseName.ToString() + $f.Extension.ToString()
		magick $f -crop $cropParam $o
	}
}
