# need array 'runCmd'
printf "%s\0" "${runCmd[@]}" | parallel -0 $1