#!/bin/bash
set -eo pipefail

case $ARCH in
  x86-64)
    MAKE_OPTS="MY_ASM=uasm -f ../../cmpl_gcc_x64.mak";;
  x86|arm64)
    MAKE_OPTS="MY_ASM=uasm -f ../../cmpl_gcc_$ARCH.mak";;
  arm|armhf)
    MAKE_OPTS="-f ../../cmpl_gcc_arm.mak";;
  *)
    MAKE_OPTS="-f ../../cmpl_gcc.mak";;
esac

git ls-files -z | xargs -0 unix2dos -q --allow-chown && ( QUILT_PATCHES=../patches quilt push -a || exit 1 )

( cd CPP/7zip/Bundles/Alone2 && mkdir -p b/g && \
  make -j$(nproc) \
    CROSS_COMPILE="${TOOL}-" \
    CFLAGS_BASE_LIST="-c -D_7ZIP_AFFINITY_DISABLE=1 -DZ7_AFFINITY_DISABLE=1 -D_GNU_SOURCE=1" \
    CFLAGS_WARN_WALL="-Wall -Wextra" COMPL_STATIC=1 $MAKE_OPTS || exit 1 )

find . -type f -name '7zzs' -exec cp -va {} 7zz \;
[ -f 7zz ] || { echo "Error: 7zzs binary not found after build" >&2; exit 1; }
tar -cJvf "$GITHUB_WORKSPACE/7zz-linux-$ARCH.tar.xz" 7zz
