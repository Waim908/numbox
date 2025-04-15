if [[ -n "$1" ]] &&
   [[ "$1" != "." && "$1" != ".." ]] &&
   [[ "$1" != */* ]] &&
   [[ "$1" != -* ]] &&
   [[ ! "$1" =~ [[:cntrl:]] ]] &&
   [[ "$1" =~ ^[^[:space:]].*[^[:space:]]$ ]]
then
    str_is=good
else
    str_is=bad
fi