#!/usr/bin/env python3

import subprocess
import json
import time
import requests
#import sys

influx_data = []

try:

    #get key dynamically
    id_cmd = f'solana address -u localhost --keypair /home/solana/.secrets/validator-keypair.json'
    identity_key = subprocess.check_output(id_cmd, shell=True).decode().strip()

    id_vote_key_cmd = f'solana  vote-account -u localhost -keypair /home/solana/.secrets/vote-account-keypair.json --output json-compact'

    credits_data_string = subprocess.check_output(id_vote_key_cmd, shell=True).decode()
    credits_data_json = json.loads(credits_data_string)
    credits_data = credits_data_json["epochVotingHistory"][-1]

    leader_schedule = {"jsonrpc":"2.0","id":1, "method":"getLeaderSchedule"}
    leader_schedule_result = requests.post("http://localhost:8899", json = leader_schedule)

    if (eval("identity_key") in leader_schedule_result.json()['result']):
        my_leader_schedule = leader_schedule_result.json()['result'][eval("identity_key")]
        my_leader_slots_this_epoch = len(my_leader_schedule)
    else:
        my_leader_slots_this_epoch = 0

    cluster_info_cmd = f'solana epoch-info -u localhost --output json-compact'
    cluster_info_string = subprocess.check_output(cluster_info_cmd, shell=True).decode()
    cluster_info_data = json.loads(cluster_info_string)

    ## gather validator's solana info
    cmd = f'solana validators -u localhost --output json-compact'
    json_string = subprocess.check_output(cmd, shell=True).decode()
    solana_data = json.loads(json_string)

    for validator in solana_data["validators"]:
        if validator['identityPubkey'] == eval("identity_key"):
            output_data = validator


    #gather validator's public infos
    cmd2 = f'solana validator-info -u localhost get --output json-compact'
    json_string2 = subprocess.check_output(cmd2, shell=True).decode()
    solana_data2 = json.loads(json_string2)
    output_data2 = {"info": {"name": "not provided"}}
    for validator2 in solana_data2:
        if validator2['identityPubkey'] == eval("identity_key"):
            if ("keybaseUsername" not in validator2["info"]):
                validator2["info"]["keybaseUsername"] = "not provided"
            if ("name" not in validator2["info"]):
                validator2["info"]["name"] = "not provided"
            if ("name" not in validator2["details"]):
                validator2["info"]["details"] = "not provided"
            if ("name" not in validator2["website"]):
                validator2["info"]["website"] = "not provided"
            output_data2 = validator2

    output_data.update(output_data2['info'])

    #gather validator's leader slots info
    cmd3 = f'solana block-production -u localhost --output json-compact'
    json_string3 = subprocess.check_output(cmd3, shell=True).decode()
    solana_data3 = json.loads(json_string3[json_string3.find('{'):])
    for validator3 in solana_data3["leaders"]:
        if validator3['identityPubkey'] == eval("identity_key"):
            output_data3 = validator3
            break
        else:
            output_data3 = {
                "identityPubkey": identity_key,
                "leaderSlots": 0,
                "blocksProduced": 0,
                "skippedSlots": 0
            }

    last_epoch_slot = cluster_info_data['absoluteSlot']
    first_epoch_slot = cluster_info_data['absoluteSlot']-cluster_info_data['slotIndex']
    epoch_last_request = {"jsonrpc":"2.0","id":1, "method":"getBlockTime", "params":[last_epoch_slot]}
    epoch_first_request = {"jsonrpc":"2.0","id":1, "method":"getBlockTime", "params":[first_epoch_slot]}
    epoch_last_result = requests.post("http://testnet.solana.com:8899", json = epoch_last_request)
    epoch_first_result = requests.post("http://testnet.solana.com:8899", json = epoch_first_request)
    epoch_last_time = epoch_last_result.json()['result']
    epoch_first_time = epoch_first_result.json()['result']
    slots_done = cluster_info_data['slotIndex']
    mid_slot_time = (epoch_last_time-epoch_first_time)/slots_done
    remaining_time = (cluster_info_data["slotsInEpoch"]-slots_done)*mid_slot_time
    end_time = round(time.time())+remaining_time

    slots = leader_schedule_result.json()['result']

    if (identity_key in slots):
        for slot in slots[eval("identity_key")]:
            if (slots_done < slot):
                next_slot = slot
                break

        time_until_next_slot = (next_slot - solana_data3["total_slots"])*mid_slot_time
    else:
        time_until_next_slot = -1

    output_data.update(output_data3)
    output_data.update(credits_data)
    output_data.update(cluster_info_data)
    output_data.update({"vote_account_balance":credits_data_json["accountBalance"]})
    output_data.update({"my_leader_slots":my_leader_slots_this_epoch})
    output_data.update({"epoch_endtime":end_time})
    output_data.update({"epoch_remaining_sec":remaining_time})
    output_data.update({"time_until_next_slot":time_until_next_slot})
    output_data.update({"validator_status": 1})


    influx_item = {
        "measurement": "validators_info",
        "validator_name": output_data["name"],
        "time": round(time.time() * 1000),
        "cluster_total_slots": solana_data3["total_slots"],
        "cluster_total_slots_skipped": solana_data3["total_slots_skipped"],
        "cluster_total_blocks_produced": solana_data3["total_blocks_produced"],
        "fields": output_data
    }
except:
    print("Unexpected error:", sys.exc_info()[0])
    influx_item = {
        "measurement": "validators_info",
        "validator_name": "hezner-test-validator",
        "time": round(time.time() * 1000),
        "fields": {"validator_status": 0}
    }

influx_data.append(influx_item)


print(json.dumps(influx_data))
