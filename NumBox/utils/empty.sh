case $1 in
sd)
  sdcard_dir=(  
      "/sdcard/NumBox"
      "/sdcard/NumBox/temp"
      "/sdcard/NumBox/ctr_package"
      "/sdcard/NumBox/plugins"
      "/sdcard/NumBox/logs"
      "/sdcard/NumBox/patch"
      "/sdcard/NumBox/resources"
      "/sdcard/NumBox/resources/dxvk"
      "/sdcard/NumBox/resources/cncddraw"
      "/sdcard/NumBox/resources/wined3d"
      "/sdcard/NumBox/resources/vkd3d"
      "/sdcard/NumBox/resources/mono"
      "/sdcard/NumBox/resources/gecko"
      "/sdcard/NumBox/resources/wine"
      "/sdcard/NumBox/resources/drivers"
  )  
  printf "%s\0" "${sdcard_dir[@]}" | parallel -0 mkdir -p ;;
data)
  data_dir=(
      "$HOME/NumBox/data/container"
      "$HOME/NumBox/data/config"
      "$HOME/NumBox/data/patch"
      "$HOME/NumBox/data/pulgin"
  )
  printf "%s\0" "${data_dir[@]}" | parallel -0 mkdir -p ;;
esac