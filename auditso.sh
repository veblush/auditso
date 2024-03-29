#!/bin/bash

set +e 

usage() {
  echo "usage: $0 test.so"
}

make_conda_package() {
  # Create a conda package. The generated file is not fully legit
  # but enough for auditwheel to understand.
  # (https://docs.conda.io/projects/conda-build/en/latest/resources/package-spec.html)
  target=$1
  tmp_dir=$2
  pack_file=$3
  filename=$(basename $target)

  pack_dir=$tmp_dir/pack
  mkdir $pack_dir
  cp $target $pack_dir/$filename
  
  mkdir $pack_dir/info
  echo $filename > $pack_dir/info/files
  tar -cjSf $pack_file -C $pack_dir .
}

audit() {
  # Create a temporary conda package to test it compliant with manylinux1
  tmp_dir=$(mktemp -d -t auditso-XXXXXXXXXX)
  trap "{ rm -rf $tmp_dir; }" EXIT

  pack_file=$tmp_dir/pack.tar.bz2 
  make_conda_package $target $tmp_dir $pack_file

  # Run auditwheel against the generated package
  auditwheel show $pack_file > $tmp_dir/output

  # If output has "manylinux1, it is considered successful.
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
