#!/bin/bash

fdp_release="FDP 20.B"

# script to resubmit user's aborted jobs
rm -f ~/temp/jobs.txt
rm -f ~/temp/aborted_jobs.txt
rm -f ~/temp/new_jobs.txt
jobs=$(bkr job-list --mine --whiteboard="$fdp_release" --finished)
for i in $(echo $jobs | grep J | tr -d [\"\,]); do echo $i >> ~/temp/jobs.txt; done

echo "Gathering list of your aborted jobs for $fdp_release.  This may take several minutes..."
for i in $(cat ~/temp/jobs.txt); do
	if [[ $(bkr job-results $i | grep 'status="Aborted"') ]]; then
		echo $i >> ~/temp/aborted_jobs.txt
	fi
done

if [[ -s ~/temp/aborted_jobs.txt ]]; then
	num_aborted_jobs=$(cat ~/temp/aborted_jobs.txt | wc -l) > /dev/null
	echo "You currently have $num_aborted_jobs aborted jobs from $fdp_release:"
	echo "$(cat ~/temp/aborted_jobs.txt)"
	while true; do
    read -p "Do you want to resubmit the aborted jobs and then delete the orignal? (y/n)" yn
    case $yn in
        [Yy]* ) 
        		echo "OK.  Time to clone the aborted jobs and then delete them."

				for i in $(cat ~/temp/aborted_jobs.txt); do
					echo "Cloning and resubmitting job $i"
					bkr job-clone $i | tee -a ~/temp/new_jobs.txt
					new_job=$(tail -n1 ~/temp/new_jobs.txt | awk '{print $NF}' | tr -d [\[\]\'])
					echo "New job submitted: $new_job"
					echo "Deleting original aborted job $i..."
					bkr job-delete $i
				done
        		exit;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
	done
	exit
else
	echo "You currently have no aborted jobs for $fdp_release."
	exit
fi

