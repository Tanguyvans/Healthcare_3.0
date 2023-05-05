. scripts/utils.sh

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}