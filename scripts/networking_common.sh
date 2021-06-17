#!/bin/bash

#####  Functions to be used with bash scripts  #####

#### Functions for configuration ####

# nmcli functions
nmcli_cfg_ip ()
{
    	CON=$1
    	IF=$2
    	IP4=$3
    	IP6=$4
    	nmcli con add con-name $CON ifname $IF autoconnect no type ethernet ip4 $IP4 ip6 $IP6
}

nmcli_con_up ()
{
    	CON=$1
    	nmcli con up $CON
}

nmcli_con_down ()
{
    	CON=$1
    	nmcli con down $CON
}

nmcli_con_del ()
{
    	CON=$1
    	nmcli con show $CON || :
        if [ $? -eq  0 ];
        then
            nmcli con del $CON || :
        fi
}

nmcli_cfg_mtu ()
{
    	MTU=$1
    	CON=$2
    	nmcli con mod $CON 802-3-ethernet.mtu $MTU
}

#Configure MTU setting for a link
cfg_mtu ()
{
    	MTU=$1
    	DEV=$2
    	ip link set mtu $MTU dev $DEV
}

#Clear ALL IP address from a target device
clr_ip_all_nic ()
{
    	DEV=$1
    	ip address flush dev $DEV
}

#Delete a specific IP address from a target device
clr_ip_nic ()
{
    	IP=$1
    	DEV=$2
    	ip address del $IP dev $DEV
}

#Configure an IPv4 or IPv6 address on a NIC
cfg_ip_nic ()
{
    	IP=$1
    	DEV=$2
    	ip address add $IP dev $DEV
}

#### Functions for tools and utilities ####

netperf4 ()
{
    	LOCAL=$1
    	REMOTE=$2
    	TEST_TYPE=$3
        PERFTIME=$4
    	PKT_SIZE=$5
        netperf -4 -H $REMOTE "-L" $LOCAL -t $TEST_TYPE -l $PERFTIME -- -m $PKT_SIZE
}

netperf6 ()
{
    	LOCAL=$1
    	REMOTE=$2
    	TEST_TYPE=$3
        PERFTIME=$4
    	PKT_SIZE=$5
    	netperf -6 -H $REMOTE -L $LOCAL -t $TEST_TYPE -l $PERFTIME -- -m $PKT_SIZE
}

netserver4 ()
{
    	LOCAL=$1
    	ps -elf | egrep -e "netserver|netserver -4" | grep inet
        if [ $? -ne 0 ];
        then
            netserver -4 -L "$LOCAL"
        fi 
}

netserver6 ()
{
    	LOCAL=$1
    	ps -elf | grep 'netserver -6' | grep inet
        if [ $? -ne 0 ];
        then
            netserver -6 -L "$LOCAL"
        fi 
}

do_ssh ()
{
	HOST=$1
	COMMAND=$2
    	ssh - XY root@qe-dell-$HOST.lab.eng.bos.redhat.com $COMMAND
}

#### Miscellaneous functions ####

#Check exit status code of previous operation
chk_result () 
{
	echo $?
}

#sed shortcuts

#easy sed function to allow you to put quoates around the search and replace strings and everything within is escaped
#Usage: sedeasy "search_string/can have slashes" "replace with this" *.sh
sedeasy ()
{
sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
} 

#To insert a line
insert ()
{
	FUNC_NAME=${FUNCNAME}
	ADD_THIS=$1
	LOCATION=$2
	PATTERN=$3
	TARGET=$4

	#create the display usage to be presented to the user
	display_usage(){
		echo -e "\nUsage: \n"$FUNC_NAME" [string to be inserted] [a | i] [string to locate] [target files - MUST BE ENCLOSED IN DOUBLE QUOTES (\"\")]"
		echo -e "Example: \n"$FUNC_NAME" foo a bar \"*.txt\" (to insert line \"foo\" AFTER line \"bar\") OR \n"$FUNC_NAME" foo i bar \"*.txt\" (to insert line \"foo\" BEFORE line \"bar\")"
	}

	#if less than 4 arguments are supplied by the user, display usage
	if [ $# -lt 4 ]
	then
	display_usage
	trap insert 0
	fi

	#check whether user has supplied -h or --help or help or -?.  if yes, display usage
	if [[ $# == "--help" || $# == "help" || $# == "-h" || $# == "-?" ]]
	then
        display_usage
        trap insert 0
	fi

	for i in $TARGET; do sed -i '/'$PATTERN'/'$LOCATION''$ADD_THIS'' $i; done
}

#To replace a string
replace ()
{
	FUNC_NAME=${FUNCNAME}
	FIND_THIS=$1
	REPLACE_WITH=$2
	TARGET=$3

	#create the display usage to be presented to the user
	display_usage(){
		echo -e "\n"$FUNC_NAME" [string to be replaced] [new string] [target files - MUST BE ENCLOSED IN DOUBLE QUOTES (\"\")]"
		echo -e "Example: \n"$FUNC_NAME" foo bar \"*.txt\" (to replace string \"foo\" with \"bar\" in all *.txt files in current directory)\n"
	}

	#if less than 3 arguments are supplied by the user, display usage
	if [ $# -lt 3 ]
	then
	display_usage
	trap insert 0
	fi

	#check whether user has supplied -h or --help or help or -?.  if yes, display usage
	if [[ $# == "--help" || $# == "help" || $# == "-h" || $# == "-?" ]]
	then
        display_usage
        trap insert 0
	fi

	for i in $TARGET; do sed -i s'/'$FIND_THIS'/'$REPLACE_WITH'/'g $i; done
}

#To display time in nice format rather than just in seconds

display_time ()
{
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  [[ $D > 0 ]] && printf '%d days ' $D
  [[ $H > 0 ]] && printf '%d hours ' $H
  [[ $M > 0 ]] && printf '%d minutes ' $M
  [[ $D > 0 || $H > 0 || $M > 0 ]] && printf 'and '
  printf '%d seconds\n' $S
}
