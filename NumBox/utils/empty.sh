case $1 in
sd)
nbdir=/sdcard/NumBox
resdir=$nbdir/resources
sdcard_dir=(
    "$nbdir"
    "$nbdir/temp"
    "$nbdir/ctr_package"
    "$nbdir/winepack"
    "$nbdir/plugins"
    "$nbdir/logs"
    "$resdir"
    "$resdir/dxvk"
    "$resdir/cncddraw"
    "$resdir/wined3d"
    "$resdir/vkd3d"
    "$resdir/mono"
    "$resdir/gecko"
)
printf "%s\0" "${sdcard_dir[@]}" | parallel -0 mkdir -p ;;
esac