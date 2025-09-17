# cyan
info () {
  echo -e "\e[36m\e[1mINFO: \e[36m${1}\e[0m"
}
# yellow
error () {
  echo -e "\e[33m\e[1mERROR: \e[33m${1}\e[0m"
}
# red
warn () {
  echo -e "\e[31m\e[1mWARN: \e[31m${1}\e[0m"
}