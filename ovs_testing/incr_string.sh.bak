chr() {
  [ "$1" -lt 256 ] || return 1
  printf "\\$(printf '%03o' "$1")"
}

ord() {
  LC_CTYPE=C printf '%d' "'$1"
}

incr_string () 
{
string="$1";
lcstring=$(echo $string | tr '[:lower:]' '[:upper:]');


for ((position=$((${#lcstring}-1));position>=0;position--));do  

  if [ "${lcstring:position:1}" = 'z' ]; then
    if [ "$position" -eq "$((${#lcstring}-1))" ]; then
       newstring="${lcstring:0:$(($position))}a";
       lcstring="$newstring";
    elif [ "$position" -eq "0" ]; then 
       newstring="a${lcstring:$((position+1))}";
    echo $newstring;
       break;
    else
       newstring="${lcstring:0:$(($position))}a${lcstring:$((position+1))}";
       lcstring="$newstring";
    fi
  elif [ "${lcstring:position:1}" = '9' ]; then
    if [ "$position" -eq "$((${#lcstring}-1))" ]; then
       newstring="${lcstring:0:$(($position))}0";
       lcstring="$newstring";
    elif [ "$position" -eq "0" ]; then  
       newstring="0${lcstring:$((position+1))}";
       echo $newstring;
       break;
    else
       newstring="${lcstring:0:$(($position))}0${lcstring:$((position+1))}";
       lcstring="$newstring";
    fi
  else
    if [ "$position" -eq "$((${#lcstring}-1))" ]; then
       newstring="${lcstring:0:$(($position))}$(chr $(($(ord ${lcstring:position})+1)))";
       echo $newstring;
       break;
    elif [ "$position" -eq "0" ]; then
       newstring="$(chr $(($(ord ${lcstring:position})+1)))${lcstring:$((position+1))}";
       echo $newstring;
       break;
    else
       newstring="${lcstring:0:$(($position))}$(chr $(($(ord ${lcstring:position})+1)))${lcstring:$(($position+1))}";
       echo $newstring;
       break;               
    fi
  fi
done

}



