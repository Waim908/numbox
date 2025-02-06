read -p "pkg name: " pkg_name
apt-get download $pkg_name 
# && for i in $(apt-cache depends $pkg_name | grep -E 'Depends|Recommends|Suggests' | cut -d ':' -f 2,3 | sed -e s/'<'/''/ -e s/'>'/''/); do apt-get download $i 2>>errors.txt; done
