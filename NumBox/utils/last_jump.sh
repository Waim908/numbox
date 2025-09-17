last_jump () {
  if [[ $lastJump == 1 ]] && [[ ! -z $lastScript ]]; then
    unset lastJump
    unset lastScript
    . $lastScript
  else
    echo "退出"
  fi
}