if [[ ! -f /data/data/com.termux/files/home/NumBox/data/container/"${CONTAINER_NAME}"/is_arm64ec ]]; then
  if ! box64 wine explorer /desktop=shell,
else
  echo "暂不支持"
fi