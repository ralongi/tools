get_starting_packages()
{
    starting_stream=$(grep OVS$FDP_STREAM2 package_list.sh | grep RHEL$RHEL_VER_MAJOR | egrep -vi 'python|tcpdump' | tail -n2 | head -n1 | awk -F "_" '{print $2}')
    
    export STARTING_RPM_OVS=$(grep "$starting_stream" package_list.sh | grep OVS$FDP_STREAM2 | grep RHEL$RHEL_VER_MAJOR | egrep -vi 'python|tcpdump' | awk -F "=" '{print $2}')
    export STARTING_RPM_OVS_SELINUX_EXTRA_POLICY=$(grep "$starting_stream" package_list.sh | grep -i selinux | grep RHEL$RHEL_VER_MAJOR)

    echo "STARTING_RPM_OVS: $STARTING_RPM_OVS"
    echo "STARTING_RPM_OVS_SELINUX_EXTRA_POLICY: $STARTING_RPM_OVS_SELINUX_EXTRA_POLICY"
}
    
