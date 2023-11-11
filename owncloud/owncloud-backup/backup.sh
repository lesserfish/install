#! /bin/bash
docker start owncloud_backup && docker exec owncloud_backup "/tmp/backup.sh"
