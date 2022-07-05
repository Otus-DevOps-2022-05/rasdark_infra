#!/bin/bash
yc compute instances list | tail -n +4 | head -n -2 | awk -F '|' '{print "["$3"]\n" $3 "-server" "%ansible_host="$6}' | tr -d '[:blank:]' | sed 's/%/ /g'  | sed 's/reddit-//g' > inventory
ansible-inventory -i inventory --list > inventory.json
