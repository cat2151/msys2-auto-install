@powershell -NoProfile -ExecutionPolicy Unrestricted "$s=[scriptblock]::create((gc \"%~f0\"|?{$_.readcount -gt 1})-join\"`n\");&$s" %*&goto:eof

# MSYS2を公式からダウンロードし、MSYS2にgccとclangをインストールしてhello worldをコンパイルし、それらのログを出力します

# スクリプトの動作ディレクトリを得る
function getScriptDir() {
  if ("$PSScriptRoot" -eq "") {
    $Pwd.Path # bat化した場合、$PSScriptRoot や $MyInvocation.MyCommand.Path や $PSCommandPath は空なので、bat起動時のカレントディレクトリで代用する
  } else {
    $PSScriptRoot
  }
}

# ログを記録開始する（処理時間計測を含む）
function startLog($filename) {
  $null = Start-Transcript $filename
  Get-Date # 呼び出し元で時間計測スタート時刻を記録する用
}

# ログを記録終了する
function endLog() {
  "かかった時間 : " + ((Get-Date) - $startTime).ToString("m'分's'秒'")
  Stop-Transcript
}

# matchした文字列を得る
function getMatchStr($str, [string]$regex) { # ここに限っては、第1引数の型指定をしないほうが、ミスで配列を渡したときに-matchが "matchしませんでした" を出力することで検知ができる
  $null = "matchしませんでした" -match ".*" # $Matchesを初期化する。こうしないとmatchしなかった場合に以前のscript実行でmatchしたものが$Matchesに出力されて根深いバグの原因になる
  $null = $str -match $regex
  $Matches.Values -join ""
}

# 子プロセスを実行する
function execChild($commands) {
  $input | cmd.exe /c $commands
}

# rm -f する
function rm_f($filename) {
  if (Test-Path $filename) {
    $null = Remove-Item $filename -Force # powershellのrmは rm -f ができなくて紛らわしいので関数でwrapする
  }
}

# mv -f する
function mv_f($src, $dest) {
  $null = Move-Item $src -Destination $dest -Force # powershellのmvは mv -f ができなくて紛らわしいので関数でwrapする
}

# MSYS2公式からexeのURLを得る
function getMsys2ExeUrl() {
  $line = curl.exe "https://www.msys2.org/" | findstr "https.*exe.*button" # exeのURLとみなす行を絞り込む
  $url_q = getMatchStr $line 'https.*exe"' # exe直後にダブルクォートがある文字列を、exeのURLとみなす
  getMatchStr $url_q 'https.*exe' # 末尾ダブルクォートを取り除く
}

# MSYS2公式からexeをダウンロードし、exe名を得る
function downloadMsys2Exe() {
  $exeUrl = getMsys2ExeUrl
  $exeName = $exeUrl -replace 'https.*\/', ''
  $exeFullpath = "${msys64instDir}\install\${exeName}"
  rm_f $exeFullpath # 前回の残骸があってバグ検知できない、を防止する用
  $null = curl.exe -L $exeUrl --output $exeFullpath
  $exeFullpath
}

# MSYS2をインストールする
function installMsys2($exeFullpath) {
  $rootFullpath = "${msys64instDir}\msys64"
  "y" | execChild "${exeFullpath} install --root ${rootFullpath}"
}

# MSYS2にgccとclangをインストールしてhello worldをコンパイルし、ログを得る
function installGccClang() {
  $Env:WD="${msys64instDir}\msys64\usr\bin\" # msys64\msys2_shell.cmd での設定に寄せた
  download_install_gcc_clang_sh $Env:WD

  pushd $Env:WD
    rm_f install_gcc_clang.log # install_gcc_clang.sh の外側でログ初期化する。install_gcc_clang.shの内部でのログ初期化はできない。install_gcc_clang.shは都合により2回実行するため。
    .\bash --login -c "/usr/bin/install_gcc_clang.sh" # bash や bash.exe は認識されず、.\bash は認識された
    # 再実行（初回は途中で終了するため）
    .\bash --login -c "/usr/bin/install_gcc_clang.sh"
  popd
}

# "gcc&clangインストール用sh" の実体をダウンロードし、/usr/binに配置する
function download_install_gcc_clang_sh($Env:WD) {
  rm_f ${Env:WD}install_gcc_clang.sh
  curl.exe -L $url_install_gcc_clang_sh --output ${Env:WD}install_gcc_clang.sh
  #cp ${scriptDir}\install_gcc_clang.sh ${Env:WD}install_gcc_clang.sh # sh開発用
}


function main() {
  $exeFullpath = downloadMsys2Exe
  #$exeFullpath = "${msys64instDir}\msys2-x86_64-20220128.exe" # 開発用（以降を開発するとき用）
  installMsys2 $exeFullpath
  installGccClang
}


###
$url_install_gcc_clang_sh = "https://raw.githubusercontent.com/cat2151/msys2-auto-install/main/install_gcc_clang.sh"
$scriptDir = getScriptDir
$msys64instDir = "${scriptDir}\MSYS2_get_and_install" # batのあるディレクトリをできるだけ汚さない用
$startTime = startLog "${msys64instDir}\install\MSYS2_get_and_install.log"
main
endLog
