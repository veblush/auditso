tmp_dir=$(mktemp -d -t auditso-XXXXXXXXXX)
trap "{ rm -rf $tmp_dir; }" EXIT

g++ hello.cc -o $tmp_dir/hello4.so -D_GLIBCXX_USE_CXX11_ABI=0
g++ hello.cc -o $tmp_dir/hello5.so -D_GLIBCXX_USE_CXX11_ABI=1

../auditso.sh $tmp_dir/hello4.so
result=$?
if [ $result -eq 0 ]; then
  echo "-> PASS"
else
  echo "-> FAILED"
fi

../auditso.sh $tmp_dir/hello5.so
result=$?
if [ $result -eq 1 ]; then
  echo "-> PASS"
else
  echo "-> FAILED"
fi
