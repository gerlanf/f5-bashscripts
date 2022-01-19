#!/bin/bash
# Script name: ASM_script_change_policy_built_to_manual.sh
# Autor: Gerlan
# Description: change the policy built to manual
# Date: 19/01/2022


# Static variables
bigip_mgmt_ip=10.1.1.245
user=admin
user_password=F5demo@123
version="version: 1.1"

#list all policies ids in ASM
curl -sku $user:$user_password https://$bigip_mgmt_ip/mgmt/tm/asm/policies?\$select=name,id | jq . | grep -i "\"id\"" > policy_IDs.txt
# read the file with all policies IDs and then change the enforcement to transparent
for policy_id in $(cat policy_IDs.txt | cut -d "\"" -f 4);
do
        #Change the state to transparent mode
        echo "Change policy id $policy_id to manual"
        echo
        curl -sku $user:$user_password -X PATCH https://$bigip_mgmt_ip/mgmt/tm/asm/policies/Xt7guzmdrKHuCXDjAa932Q/policy-builder -d '{ "learningMode": "manual"}' >/dev/null 2>&1
        #Apply the policy
        echo "applying the policy id: $policy_id"
        echo
        curl -sku $user:$user_password https://$bigip_mgmt_ip/mgmt/tm/asm/tasks/apply-policy -d '{"policyReference": {"link": "https://'$bigip_mgmt_ip'/mgmt/tm/asm/policies/'$policy_id'"}}' >/dev/null 2>&1
        echo "done"
done
