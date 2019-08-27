#!/bin/bash

set +e 

usage() {
  echo "usage: $0 test.so"
}

audit() {
  tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
  trap "{ rm -rf $tmp_dir; }" EXIT

  target=$1
  filename=$(basename $target)

  pack_dir=$tmp_dir/pack
  pack_file=$tmp_dir/pack.tar.bz2 
  mkdir $pack_dir
  cp $target $pack_dir/$filename
  
  mkdir $pack_dir/info
  echo $filename > $pack_dir/info/files
  tar -cjSf $pack_file -C $pack_dir .

  auditwheel show $pack_file > $tmp_dir/output
  if grep -q "\"manylinux1" $tmp_dir/output
  then
      echo "* Pass: Compliant with manylinux1."
      exit 0
  else
      echo "* Fail: NOT compliant with manylinux1."
      echo "* Output from auditwheel:"
      cat $tmp_dir/output
      exit 1
  fi
}

target=$1
if [[ -n "$target" ]]; then
  if [ ! -f "$target" ]; then
    echo "$target not found."
    exit 1
  fi
  audit $target
else
  usage
  exit 1
fi
