test_func()
{
if [ $1 > 0 ]; then
        local var1=$1
        echo "$var1"
else
        echo "No \$1 argument was passed, but that is OK"
        return 0
fi

if [ $2 > 0 ]; then
	local tcp_msg_size=$(echo $2 | awk -F ',' '{ if ($1 > 1) { print $1 } else { print 16384 } }')
	local udp_msg_size=$(echo $2 | awk -F ',' '{ if ($2 > 1) { print $2 } else { print 65507 } }')
	echo " -- -m $udp_msg_size"
else
        echo "No \$2 argument was passed, but that is OK"
        return 0
fi

echo $var1 " " $tcp_msg_size " " $udp_msg_size
}

