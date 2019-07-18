#!/bin/bash

if [ ! -d kos ]; then
  git clone --depth=1 https://github.com/KallistiOS/KallistiOS kos
fi

pushd kos || exit $?
  git pull || exit $?
popd

RUN=$(pwd)/bin/run

function run() {
  echo "$ $@"
  $RUN "$@" || exit $?
}

echo "== Setup"
run rm -rf png-example
run cp -r kos/examples/dreamcast/png ./png-example

echo "$ cd png-example"
cd png-example || exit 1

echo "== Build"
run make clean
run make all
run sh-elf-objcopy -R .stack -O binary example.elf output.bin

echo "== Generate CDIs"

echo "$ mkdir isofs"
mkdir isofs || exit 1

run bash -c 'cp *.elf ./isofs'
run bash -c 'cp /opt/toolchains/mksdiso/src/makeip/{ip.txt,IP.TMPL} .'
run makeip ip.txt IP.BIN
run /opt/toolchains/dc/kos/utils/scramble/scramble output.bin isofs/1ST_READ.BIN
run genisoimage -G IP.BIN -joliet -rock -l -o output.iso isofs/
run cdi4dc output.iso output.cdi

#dd if=session1.iso bs=1024 count=36 > session2.iso
#run cdrecord dev=1,0,0 speed=8 -multi -xa1 session1.iso
#run cdrecord dev=1,0,0 speed=8 -eject -xa1 session2.iso
