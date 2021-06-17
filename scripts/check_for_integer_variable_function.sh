check_for_integer_variable()
{
	target_variable=$1
	
	if expr "$target_variable" : '-\?[0-9]\+$' >/dev/null; then
    	echo "$target_variable is considered an integer."	    
    else
        echo "$target_variable is NOT considered an integer."
    fi
}
