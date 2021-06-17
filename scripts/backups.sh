!/bin/bash

TODAY=$(date -I)

rm -Rf /run/media/ralongi/ee62da4e-3fcb-4109-a137-1c9f0fd84802/temp/*
rsync -avzC /home/ralongi --exclude-from=/home/ralongi/rsync-exclude.txt /run/media/ralongi/ee62da4e-3fcb-4109-a137-1c9f0fd84802/temp/
tar cjf /run/media/ralongi/ee62da4e-3fcb-4109-a137-1c9f0fd84802/ralongi_backups/work_homedir_backup_$TODAY.tar.bz2 /run/media/ralongi/ee62da4e-3fcb-4109-a137-1c9f0fd84802/temp/

rm -Rf /run/media/ralongi/ee62da4e-3fcb-4109-a137-1c9f0fd84802/temp/*
rsync -avzC --exclude-from=/home/ralongi/rsync-exclude.txt /VirtualMachines/backups /run/media/ralongi/ee62da4e-3fcb-4109-a137-1c9f0fd84802/temp/
tar cjf /run/media/ralongi/ee62da4e-3fcb-4109-a137-1c9f0fd84802/ralongi_backups/work_backupsdir_backup_$TODAY.tar.bz2 /run/media/ralongi/ee62da4e-3fcb-4109-a137-1c9f0fd84802/temp/

rm -Rf /run/media/ralongi/ee62da4e-3fcb-4109-a137-1c9f0fd84802/temp/*
rsync -avzC /etc --exclude-from=/home/ralongi/rsync-exclude.txt /run/media/ralongi/ee62da4e-3fcb-4109-a137-1c9f0fd84802/temp/
tar cjf /run/media/ralongi/ee62da4e-3fcb-4109-a137-1c9f0fd84802/ralongi_backups/work_etcdir_backup_$TODAY.tar.bz2 /run/media/ralongi/ee62da4e-3fcb-4109-a137-1c9f0fd84802/temp/

rm -Rf /run/media/ralongi/ee62da4e-3fcb-4109-a137-1c9f0fd84802/temp/*
