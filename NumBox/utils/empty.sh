case $1 in
sd)
sdcard_dir=(  
    "/sdcard/NumBox"
    "/sdcard/NumBox/temp"
    "/sdcard/NumBox/ctr_package"
    "/sdcard/NumBox/winepack"
    "/sdcard/NumBox/plugins"
    "/sdcard/NumBox/logs"
    "/sdcard/NumBox/resources"
    "/sdcard/NumBox/resources/dxvk"
    "/sdcard/NumBox/resources/cncddraw"
    "/sdcard/NumBox/resources/wined3d"
    "/sdcard/NumBox/resources/vkd3d"
    "/sdcard/NumBox/resources/mono"
    "/sdcard/NumBox/resources/gecko"
)  
printf "%s\0" "${sdcard_dir[@]}" | parallel -0 mkdir -p ;;
data)
data_dir=(
    "$HOME/NumBox/data/container"
    "$HOME/NumBox/data/wine"
    "$HOME/NumBox/data/config"
    "$HOME/NumBox/data/resources/dxvk"
    "$HOME/NumBox/data/resources/cncddraw"
    "$HOME/NumBox/data/resources/wined3d"
    "$HOME/NumBox/data/resources/vkd3d"
    "$HOME/NumBox/data/resources/mono"
    "$HOME/NumBox/data/resources/gecko"
    "$HOME/NumBox/data/resources/drivers"
    "$HOME/NumBox/data/resources/wine"
    "$HOME/NumBox/data/patch"
)
printf "%s\0" "${data_dir[@]}" | parallel -0 mkdir -p ;;
esac