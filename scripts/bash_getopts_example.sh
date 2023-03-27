#!/bin/bash

usage() { echo "$0 usage:" && grep "[[:space:]].)\ #" $0 | sed 's/#//' | sed -r 's/([a-z])\)/-\1/'; exit 0; }

[ $# -eq 0 ] && usage
while getopts "he:f:a:" arg; do
  case $arg in
    e) # Specify an errata ID. Example: -e 111078
      errata=${OPTARG}
      ;;
    f) # Specify a file containing errata IDs. Example: -f errata_list.txt 
      errata_list_file=${OPTARG}
      ;;
    a) # Specify an arch (default is x86_64). Example: -a aarch64
      arch=${OPTARG}
      ;;
    h) # Display help.
      usage
      ;;
  esac
done

if [[ $errata ]] && [[ $errata_list_file ]]; then
	echo ""
	echo "  Please specify either -e <single errata ID> OR -f <errata list file>."
	echo "  The -e option is used for a single errata; the -f option is used for multiple erratas."
	echo "  The -e and -f options should NOT be used simultaneously."
	echo ""
	exit 1
fi

if [[ $errata_list_file ]]; then
	errata_list=$(cat $errata_list_file)
elif [[ $errata ]]; then
	errata_list=$errata
fi

if [[ -z $arch ]]; then arch="x86_64"; fi
