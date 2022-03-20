#!/usr/bin/env bash
set -x    # 何が実行されているかログでわかりやすくする用
SECONDS=0 # 時間計測用

installGcc() {
  # 初期設定
  pacman -Syu --noconfirm
  pacman -Su --noconfirm
  # gccを含むtoolchainのインストール
  pacman -S --needed base-devel mingw-w64-x86_64-toolchain --noconfirm
  # 再実行（初回が頻繁にエラーになるのでその対策）
  pacman -S --needed base-devel mingw-w64-x86_64-toolchain --noconfirm
}

installClang() {
  pacman --noconfirm -S mingw-w64-x86_64-clang --noconfirm
  # 再実行（初回が頻繁にエラーになるのでその対策）
  pacman --noconfirm -S mingw-w64-x86_64-clang --noconfirm
}

printSeconds() { # 引数 SECONDS
  ((sec=${1}%60, min=${1}/60))
  echo $(printf "かかった時間 : %02d分%02d秒" ${min} ${sec})
}

createSourceFile() { # 引数 : $cName, $cppName
  cName=$1
  cppName=$2
  pushd /usr/bin
  cat <<EOS > $cName
#include <stdio.h>
int main() { printf("hello, world C\n"); }
EOS

  cat <<EOS > $cppName
#include <iostream>
int main() { std::cout << "hello, world C++\n"; }
EOS
  popd
}

build() { # 引数 : compiler, sourceName, option
  compiler=$1
  sourceName=$2
  option=$3
  exeName=${compiler}_${sourceName}.exe
  echo "---"
  echo "$compiler"
  rm -f $exeName # コンパイル失敗時に状況をわかりやすくする用（以前生成したものが残っているとわかりづらいので）
  ls -al --color $sourceName
  env MSYSTEM=MINGW64 /usr/bin/bash --login -c "cd /usr/bin; $compiler -o $exeName $sourceName -ggdb $option; ls -al --color $exeName; gdb $exeName --eval-command=list --batch; $exeName; echo $?"
  mv -f $exeName $WD../../../install # hello world exeを msys64/../install に移動する
}

buildHelloWorld() {
  set +x # hello worldの実行結果をわかりやすくする用
  cName=hello_c.c
  cppName=hello_c++.cpp

  pushd /usr/bin
    createSourceFile $cName $cppName
    build gcc     $cName   ""
    build g++     $cppName "-static -lstdc++ -lgcc -lwinpthread" # MSYS2のDLLに依存しないexeを作る用
    build clang   $cName   ""
    build clang++ $cppName "-static -lstdc++ -lgcc -lwinpthread"
    mv -f $cName $cppName $WD../../../install # hello worldソースを msys64/../install に移動する
  popd

  set -x
}

createMingw64Bat() {
  # msys64/../に、mingw64起動用bat を生成する
  cat <<EOS | iconv -f UTF-8 -t CP932 | perl -pe 's/\n/\r\n/' > ${WD}../../../msys64_mingw64.bat # 行末の \\ はbash仕様対応
@echo off
pushd msys64\usr\bin\\
set WD=%~dp0msys64\usr\bin\\
env MSYSTEM=MINGW64 /usr/bin/bash --login
popd
EOS
}

main() {
  # 開発時はそれぞれを適宜コメントアウトして効率化する
  installGcc
  installClang
  buildHelloWorld
  createMingw64Bat
  printSeconds ${SECONDS}
}


###
if [[ "$WD" == "" ]]; then exit; fi
main 2>&1 | tee -a $WD../../../install/install_gcc_clang.log # teeが追記モードなのは、このshを2連続で実行して両方のログを得るため
rm -f /usr/bin/install_gcc_clang.sh # 自分自身を掃除する。なおここに到達するのは、sh実行2回目である。1回目はpacman初期設定時にsh終了となる。
