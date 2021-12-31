#!/bin/bash
# Script name: ASM_script_change_enforcement_state.sh
# Autor: Gerlan
# Description: change the state of all security policies to blocking|transparent
# Date: 11/03/2021
# Version: 1.1 - Added the description of the command and how to set to blocking or transparenti
# Version: 1.0 - Change the state of AdvWAF policies to transparent mode

# Static variables
bigip_mgmt_ip=10.1.1.245
user=admin
user_password=F5demo@123
version="version: 1.1"
MENSAGEM_USO="
uso: $0 [-h|-V|-blocking|transparent]

	-h 		- Show this screen 
	-V 		- Show the version
        -list           - List the policies and their IDs
	-blocking 	- change the state of all policies to blocking
	-transparent 	- change the state of all policies to transparent
	"

case "$1" in
        -h)
		echo "$MENSAGEM_USO"
		exit 0
	;;
	-V)
		echo "$0 $version"
	;;
        -list)
                echo
        ;;
        -transparent)
                #list all policies ids in ASM
                curl -sku $user:$user_password https://$bigip_mgmt_ip/mgmt/tm/asm/policies?\$select=name,id | jq . | grep -i "\"id\"" > policy_IDs.txt
                # read the file with all policies IDs and then change the enforcement to transparent
                for policy_id in $(cat policy_IDs.txt | cut -d "\"" -f 4);
                do
	                #Change the state to transparent mode
	                echo "Change policy id $policy_id to transparent"
                        echo
	                curl -sku $user:$user_password -X PATCH https://$bigip_mgmt_ip/mgmt/tm/asm/policies/$policy_id -d '{"enforcementMode": "transparent"}' >/dev/null 2>&1
                        #Apply the policy
                        echo "applying the policy id: $policy_id"
                        echo
                        curl -sku $user:$user_password https://$bigip_mgmt_ip/mgmt/tm/asm/tasks/apply-policy -d '{"policyReference": {"link": "https://'$bigip_mgmt_ip'/mgmt/tm/asm/policies/'$policy_id'"}}' >/dev/null 2>&1
                        echo "done"
                done
        ;;
	-blocking)
                for policy_id in $(cat policy_IDs.txt | cut -d "\"" -f 4);
                do
	                #Change the state to transparent mode
	                echo "Change policy id $policy_id to blocking"
                        echo
	                curl -sku $user:$user_password -X PATCH https://$bigip_mgmt_ip/mgmt/tm/asm/policies/$policy_id -d '{"enforcementMode": "blocking"}' >/dev/null 2>&1
                        #Apply the policy
                        echo "applying the policy id: $policy_id"
                        echo
                        curl -sku $user:$user_password https://$bigip_mgmt_ip/mgmt/tm/asm/tasks/apply-policy -d '{"policyReference": {"link": "https://'$bigip_mgmt_ip'/mgmt/tm/asm/policies/'$policy_id'"}}' >/dev/null 2>&1
                        echo "done"
                done
        ;;
        *)
		echo "$MENSAGEM_USO"
		exit 1
	;;
esac   
