#!/bin/bash
ROOTDIR="$( cd "$(dirname "$0")" ; pwd -P )"
export build_threads=`nproc`
export build_threads=`expr $build_threads / 2`
rebuild=false
rm -fr release

if [[  $1 == "rebuild" || $1 == "--rebuild" || $1 == "-r" ]] || [[ ! -d "build-release" ]]; then
    rebuild=true
    echo "Remove build dir ..."
    rm -fr build-release
    mkdir -p "build-release"
    cd build-release
    ../configure --target-list=aarch64-softmmu,aarch64-linux-user --prefix=$ROOTDIR/release --disable-werror \
    --enable-plugins \
    --enable-capstone \
    --enable-system \
    --enable-fdt \
    --enable-slirp \
    --enable-virtfs \
    --disable-xen \
    --disable-kvm  
    # --enable-lto

    # 下面参数是给Qemu 快速运行用的，不支持Python的内存断点
    # --disable-phypin-memory-breakpoint 
    
    # 下面参数是关闭phypin对qemu的修改
    # --disable-phypin-monitor
else
    echo "Fast compile ..."
    echo "- if you want to rebuild, please compile with the -r parameter."
    cd build-release
fi

ninja -t compdb > compile_commands.json
if (( $? == 0 )); then
  ninja install
  if [ -d "../../release/bin" ];then ln -f qemu-system-aarch64 ../../release/bin/qemu-system-aarch64; fi
else
  if [[ $rebuild == false ]]; then
    echo "- please try to compile with the -r parameter."
  fi
  exit 1
fi;
