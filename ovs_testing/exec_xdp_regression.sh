#!/bin/bash

# XDP regression test suite

driver=$1
if [[ -z $COMPOSE ]]; then COMPOSE=$2; fi

echo "Driver: $driver"
echo "Compose: $COMPOSE"

DBG_FLAG=${DBG_FLAG:-"set -x"}
$DBG_FLAG

NAY=${NAY:-"yes"}
NIC_NUM=${NIC_NUM:-"2"}
XDP_LOAD_MODE=${XDP_LOAD_MODE:-"native"}
XDP_TEST_FRAMEWORK=${XDP_TEST_FRAMEWORK:-"beakerlib"}
ARCH=${ARCH:-"x86_64"}
special_info=${special_info:-""}
brew_build=${brew_build:-""}
# example: export brew_build="repo:cki-artifacts,https://s3.upshift.redhat.com/DH-PROD-CKI/internal/1240303135/\$basearch/5.14.0-436.3968_1240302917.el9.\$basearch"
product="cpe:/o:redhat:enterprise_linux"
retention_tag="active+1"

sedeasy ()
{
sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

pushd /home/ralongi/github/tools/ovs_testing/xml_files

if [[ $driver == "ice" ]]; then
	server="netqe51.knqe.eng.rdu2.dc.redhat.com"
	client="netqe52.knqe.eng.rdu2.dc.redhat.com"
	server_driver="ice"
	client_driver="i40e"
	card_info="ICE"
elif [[ $driver == "i40e" ]]; then
	server="netqe52.knqe.eng.rdu2.dc.redhat.com"
	client="netqe51.knqe.eng.rdu2.dc.redhat.com"
	server_driver="i40e"
	client_driver="ice"
	card_info="I40E"
elif [[ $driver == "ixgbe" ]]; then
	server="netqe50.knqe.eng.rdu2.dc.redhat.com"
	client="netqe53.knqe.eng.rdu2.dc.redhat.com"
	server_driver="ixgbe"
	client_driver="sfc"
	card_info="IXGBE"
elif [[ $driver == "sfc" ]]; then
	server="netqe53.knqe.eng.rdu2.dc.redhat.com"
	client="netqe50.knqe.eng.rdu2.dc.redhat.com"
	server_driver="sfc"
	client_driver="ixgbe"
	card_info="SFC"
elif [[ $driver == "cx5" ]]; then
	server="netqe53.knqe.eng.rdu2.dc.redhat.com"
	client="netqe50.knqe.eng.rdu2.dc.redhat.com"
	server_driver="mlx5_core"
	client_driver="mlx5_core"
	server_pciid="15b3:1019"
	client_pciid="15b3:101d"
	card_info="CX5"
	#pciid_info="--param=mh-netqe-nic-pciid="${server_pciid}","${client_pciid}""
	#special_info="(CX5)"
elif [[ $driver == "cx6dx" ]]; then
	server="netqe50.knqe.eng.rdu2.dc.redhat.com"
	client="netqe53.knqe.eng.rdu2.dc.redhat.com"
	server_driver="mlx5_core"
	client_driver="mlx5_core"
	server_pciid="15b3:101d"
	client_pciid="15b3:1019"
	card_info="CX6-DX"
	#pciid_info='--param=mh-netqe-nic-pciid="${server_pciid}","${client_pciid}"'
	#special_info="(CX6 DX)"
elif [[ $driver == "cx3" ]]; then
	server="netqe53.knqe.eng.rdu2.dc.redhat.com"
	client="netqe50.knqe.eng.rdu2.dc.redhat.com"
	server_driver="mlx4_en"
	client_driver="mlx5_core"
	#special_info="(CX3)"
elif [[ $driver == "nfp" ]]; then
	server="netqe52.knqe.eng.rdu2.dc.redhat.com"
	client="netqe51.knqe.eng.rdu2.dc.redhat.com"
	server_driver="nfp"
	client_driver="i40e"
	card_info="NFP"
elif [[ $driver == "enic" ]]; then
	server="netqe26.knqe.eng.rdu2.dc.redhat.com"
	client="netqe22.knqe.eng.rdu2.dc.redhat.com"
	server_driver="enic"
	client_driver="bnxt_en"
	netscout_pair1="NETQE26_ENP9S0 NETQE22_P4P1"
	netscout_pair2="NETQE26_ENP10S0 NETQE22_P4P2"
	card_info="ENIC"	
elif [[ $driver == "qede" ]]; then
	server="netqe22.knqe.eng.rdu2.dc.redhat.com"
	client="netqe26.knqe.eng.rdu2.dc.redhat.com"
	server_driver="qede"
	client_driver="enic"
	netscout_pair1="NETQE26_ENP9S0 NETQE22_P7P1"
	netscout_pair2="NETQE26_ENP10S0 NETQE22_P7P2"
	card_info="QEDE"
elif [[ $driver == "bnxt_en" ]]; then
	server="netqe22.knqe.eng.rdu2.dc.redhat.com"
	client="netqe26.knqe.eng.rdu2.dc.redhat.com"
	server_driver="bnxt_en"
	client_driver="enic"
	netscout_pair1="NETQE26_ENP9S0 NETQE22_P4P1"
	netscout_pair2="NETQE26_ENP10S0 NETQE22_P4P2"
	card_info="BNXT_EN"
fi

if [[ $netscout_pair1 ]] || [[ $netscout_pair2 ]]; then 
    template=xdp_regression_netscout_template.xml
else
    template=xdp_regression_template.xml
fi

if [[ "$template" == xdp_regression_netscout_template.xml ]] && [[ $brew_build ]]; then
    template=xdp_regression_netscout_brew_template.xml
elif [[ "$template" == xdp_regression_template.xml ]] && [[ $brew_build ]]; then
    template=xdp_regression_brew_template.xml
fi

if [[ "$template" == xdp_regression_netscout_template.xml ]] && [[ $cmds_to_run ]]; then
    template=xdp_regression_netscout_cmds_template.xml
elif [[ "$template" == xdp_regression_template.xml ]] && [[ $cmds_to_run ]]; then
    template=xdp_regression_cmds_template.xml
fi

/bin/cp -f $template xdp_regression.xml
sedeasy "COMPOSE_VALUE" "$COMPOSE" "xdp_regression.xml"
sedeasy "ARCH_VALUE" "$ARCH" "xdp_regression.xml"
sedeasy "NAY_VALUE" "$NAY" "xdp_regression.xml"
sedeasy "DBG_FLAG_VALUE" "$DBG_FLAG" "xdp_regression.xml"
sedeasy "NIC_NUM_VALUE" "$NIC_NUM" "xdp_regression.xml"
sedeasy "SERVER_VALUE" "$server" "xdp_regression.xml"
sedeasy "CLIENT_VALUE" "$client" "xdp_regression.xml"
sedeasy "SERVER_DRIVER_VALUE" "$server_driver" "xdp_regression.xml"
sedeasy "CLIENT_DRIVER_VALUE" "$client_driver" "xdp_regression.xml"
sedeasy "CARD_INFO_VALUE" "$card_info" "xdp_regression.xml"
sedeasy "XDP_LOAD_MODE_VALUE" "$XDP_LOAD_MODE" "xdp_regression.xml"
sedeasy "XDP_TEST_FRAMEWORK_VALUE" "$XDP_TEST_FRAMEWORK" "xdp_regression.xml"
sedeasy "NETSCOUT_PAIR1_VALUE" "$netscout_pair1" "xdp_regression.xml"
sedeasy "NETSCOUT_PAIR2_VALUE" "$netscout_pair2" "xdp_regression.xml"
sedeasy "SPECIAL_INFO_VALUE" "$special_info" "xdp_regression.xml"
sedeasy "BREW_BUILD_VALUE" "$brew_build" "xdp_regression.xml"
sedeasy "CMDS_TO_RUN_VALUE" "$cmds_to_run" "xdp_regression.xml"

bkr job-submit xdp_regression.xml

popd
