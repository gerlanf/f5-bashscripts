#!/bin/bash
# Script name: ASM_create_hostnames_on_policy.sh
# Autor: Gerlan
# Description: change the state of all security policies to blocking|transparent
# Date: 31/12/2021
# Version: 1.0 - add a list of hostnames to a policy

# Static variables
bigip_mgmt_ip=10.1.1.245
user=admin
user_password=F5demo@123
version="version: 1.0"
MENSAGEM_USO="
uso: $0  hostnames.txt
    ASM_create_hostnames_on_policy.sh hostnames.txt
	
    E.g names inside hostnames.txt 
    host1.domain.com 

	"

case "$1" in
        -h)
		echo "$MENSAGEM_USO"
		exit 0
	;;
	hostnames.txt)
		for hostaname,subdomain in $(cat hostnames.txt | cut -d " " -f 1,2);
                do
	                #Change the state to transparent mode
	                echo "Add hostname $hostname to policy id $policy_id"
                        echo
	                curl -sku $user:$user_password -X POST https://$bigip_mgmt_ip/mgmt/tm/asm/policies/$policy_id/host-names -d '{ "name": "'$hostname'", "includeSubdomains": '$subdomain' }' >/dev/null 2>&1
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
