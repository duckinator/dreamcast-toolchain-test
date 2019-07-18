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
  $RUN "$@"
}

cd kos/examples/dreamcast/png
run make clean
run make all
run sh-elf-objcopy -R .stack -O binary example.elf output.bin
run /opt/toolchains/dc/kos/utils/scramble/scramble output.bin 1st_read.bin
