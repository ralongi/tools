generate_zstream_repos_xml()
{
	display_usage()
	{
		echo ""
		echo "Please provide a RHEL compose to generate a list of Z stream repos in XML format for that compose."
		echo "Examples: generate_zstream_repos_xml RHEL-9.1.0, generate_zstream_repos_xml RHEL-8.6.0-updates-20230405.5"
		echo ""
	}
	
	$dbg_flag
	local COMPOSE=${COMPOSE:-"$1"}
	if [[ $COMPOSE ]] && [[ $# -lt 1 ]]; then
		echo ""
		echo "Compose $COMPOSE has already been specified in this terminal window so using that to generate Z stream repos..."
		echo ""
	elif [[ -z $COMPOSE ]] && [[ $# -lt 1 ]]; then
		display_usage; return 0
	fi
	arch=${arch:-"x86_64"}
	z_stream_base=$(echo $COMPOSE | awk -F '-' '{print $2}' | tr -d . | cut -c-2)
	z_stream_base=$(echo $z_stream_base)z
	pushd ~/temp
	alias rm='rm' 
	rm -f zstream_repos.txt
	wget -q -O ZConfig.yaml https://gitlab.cee.redhat.com/kernel-qe/core-kernel/kernel-general/-/raw/master/Sustaining/ZConfig.yaml
	if [[ $(grep -w "$z_stream_base" ZConfig.yaml) ]]; then
		 zstream_repos=$(grep -A35 -w "$z_stream_base" ZConfig.yaml | grep "$arch": | tr -d "'" | awk '{$1="";print $0}' | sed 's/^ //g')
	fi
	echo ""
	echo "Generating XML for Z stream repos (Compose: $COMPOSE)..."
	echo "      <repos>" >> zstream_repos.txt  
	total_repos=$(echo $zstream_repos | wc -w)
	count=1
	for i in $zstream_repos; do
		while [[ $count -le $total_repos ]]; do
			echo "        <repo name='"myrepo_$count"' url='"$i"'/>" >> zstream_repos.txt
            let count++
		done
    done	
	echo "      </repos>" >> zstream_repos.txt
	echo "" 
	cat zstream_repos.txt
	echo ""
	rm -f zstream_repos.txt
	alias rm='rm -i'
	popd
}
