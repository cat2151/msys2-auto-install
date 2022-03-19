@powershell -NoProfile -ExecutionPolicy Unrestricted "$s=[scriptblock]::create((gc \"%~f0\"|?{$_.readcount -gt 1})-join\"`n\");&$s" %*&goto:eof

# MSYS2����������_�E�����[�h���AMSYS2��gcc��clang���C���X�g�[������hello world���R���p�C�����A�����̃��O���o�͂��܂�

# �X�N���v�g�̓���f�B���N�g���𓾂�
function getScriptDir() {
  if ("$PSScriptRoot" -eq "") {
    $Pwd.Path # bat�������ꍇ�A$PSScriptRoot �� $MyInvocation.MyCommand.Path �� $PSCommandPath �͋�Ȃ̂ŁAbat�N�����̃J�����g�f�B���N�g���ő�p����
  } else {
    $PSScriptRoot
  }
}

# ���O���L�^�J�n����i�������Ԍv�����܂ށj
function startLog($filename) {
  $null = Start-Transcript $filename
  Get-Date # �Ăяo�����Ŏ��Ԍv���X�^�[�g�������L�^����p
}

# ���O���L�^�I������
function endLog() {
  "������������ : " + ((Get-Date) - $startTime).ToString("m'��'s'�b'")
  Stop-Transcript
}

# match����������𓾂�
function getMatchStr($str, [string]$regex) { # �����Ɍ����ẮA��1�����̌^�w������Ȃ��ق����A�~�X�Ŕz���n�����Ƃ���-match�� "match���܂���ł���" ���o�͂��邱�ƂŌ��m���ł���
  $null = "match���܂���ł���" -match ".*" # $Matches������������B�������Ȃ���match���Ȃ������ꍇ�ɈȑO��script���s��match�������̂�$Matches�ɏo�͂���č��[���o�O�̌����ɂȂ�
  $null = $str -match $regex
  $Matches.Values -join ""
}

# �q�v���Z�X�����s����
function execChild($commands) {
  $input | cmd.exe /c $commands
}

# rm -f ����
function rm_f($filename) {
  if (Test-Path $filename) {
    $null = Remove-Item $filename -Force # powershell��rm�� rm -f ���ł��Ȃ��ĕ���킵���̂Ŋ֐���wrap����
  }
}

# mv -f ����
function mv_f($src, $dest) {
  $null = Move-Item $src -Destination $dest -Force # powershell��mv�� mv -f ���ł��Ȃ��ĕ���킵���̂Ŋ֐���wrap����
}

# MSYS2��������exe��URL�𓾂�
function getMsys2ExeUrl() {
  $line = curl.exe "https://www.msys2.org/" | findstr "https.*exe.*button" # exe��URL�Ƃ݂Ȃ��s���i�荞��
  $url_q = getMatchStr $line 'https.*exe"' # exe����Ƀ_�u���N�H�[�g�����镶������Aexe��URL�Ƃ݂Ȃ�
  getMatchStr $url_q 'https.*exe' # �����_�u���N�H�[�g����菜��
}

# MSYS2��������exe���_�E�����[�h���Aexe���𓾂�
function downloadMsys2Exe() {
  $exeUrl = getMsys2ExeUrl
  $exeName = $exeUrl -replace 'https.*\/', ''
  $exeFullpath = "${msys64instDir}\install\${exeName}"
  rm_f $exeFullpath # �O��̎c�[�������ăo�O���m�ł��Ȃ��A��h�~����p
  $null = curl.exe -L $exeUrl --output $exeFullpath
  $exeFullpath
}

# MSYS2���C���X�g�[������
function installMsys2($exeFullpath) {
  $rootFullpath = "${msys64instDir}\msys64"
  "y" | execChild "${exeFullpath} install --root ${rootFullpath}"
}

# MSYS2��gcc��clang���C���X�g�[������hello world���R���p�C�����A���O�𓾂�
function installGccClang() {
  $Env:WD="${msys64instDir}\msys64\usr\bin\" # msys64\msys2_shell.cmd �ł̐ݒ�Ɋ񂹂�
  download_install_gcc_clang_sh $Env:WD

  pushd $Env:WD
    rm_f install_gcc_clang.log # install_gcc_clang.sh �̊O���Ń��O����������Binstall_gcc_clang.sh�̓����ł̃��O�������͂ł��Ȃ��Binstall_gcc_clang.sh�͓s���ɂ��2����s���邽�߁B
    .\bash --login -c "/usr/bin/install_gcc_clang.sh" # bash �� bash.exe �͔F�����ꂸ�A.\bash �͔F�����ꂽ
    # �Ď��s�i����͓r���ŏI�����邽�߁j
    .\bash --login -c "/usr/bin/install_gcc_clang.sh"
  popd
}

# "gcc&clang�C���X�g�[���psh" �̎��̂��_�E�����[�h���A/usr/bin�ɔz�u����
function download_install_gcc_clang_sh($Env:WD) {
  rm_f ${Env:WD}install_gcc_clang.sh
  curl.exe -L $url_install_gcc_clang_sh --output ${Env:WD}install_gcc_clang.sh
  #cp ${scriptDir}\install_gcc_clang.sh ${Env:WD}install_gcc_clang.sh # sh�J���p
}


function main() {
  $exeFullpath = downloadMsys2Exe
  #$exeFullpath = "${msys64instDir}\msys2-x86_64-20220128.exe" # �J���p�i�ȍ~���J������Ƃ��p�j
  installMsys2 $exeFullpath
  installGccClang
}


###
$url_install_gcc_clang_sh = "https://raw.githubusercontent.com/cat2151/msys2-auto-install/main/install_gcc_clang.sh"
$scriptDir = getScriptDir
$msys64instDir = "${scriptDir}\MSYS2_get_and_install" # bat�̂���f�B���N�g�����ł��邾�������Ȃ��p
$startTime = startLog "${msys64instDir}\install\MSYS2_get_and_install.log"
main
endLog
