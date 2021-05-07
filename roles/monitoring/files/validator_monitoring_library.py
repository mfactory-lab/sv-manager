import subprocess
import time
from pprint import pprint
import requests
from typing import Optional


class ValidatorConfig:
    def __init__(self,
                 validator_name: str,
                 secrets_path: str,
                 local_rpc_address: str,
                 remote_rpc_address: str,
                 debug_mode: bool):
        self.validator_name = validator_name
        self.secrets_path = secrets_path
        self.local_rpc_address = local_rpc_address
        self.remote_rpc_address = remote_rpc_address
        self.debug_mode = debug_mode


def debug(config: ValidatorConfig, data):
    if config.debug_mode:
        pprint(data)


def execute_cmd_str(cmd: str) -> Optional[str]:
    """
    executes shell command and return string result
    :param cmd: shell command
    :return: returns string result or None
    """
    try:
        result: str = subprocess.check_output(cmd, shell=True).decode().strip()
        return result
    except:
        return None


def rpc_call(address: str, method: str, params, error_result, except_result):
    """
    calls solana rpc (https://docs.solana.com/developing/clients/jsonrpc-api)
    and returns result or default
    :param address: local or remote rpc server address
    :param method: rpc method
    :param params: rpc call parameters
    :return: result or default
    """
    try:
        json_request = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": method,
            "params": params
        }
        json_response = requests.post(address, json=json_request).json()
        if 'result' not in json_response:
            return error_result
        else:
            return json_response['result']
    except:
        return except_result


def smart_rpc_call(config: ValidatorConfig, method: str, params, default_result):
    """
    tries to call local rpc, if it fails tries to call remote rpc
    """
    result = rpc_call(config.local_rpc_address, method, params, None, None)

    if result is None:
        result = rpc_call(config.remote_rpc_address, method, params, default_result, default_result)

    return result


def load_identity_account_pubkey(config: ValidatorConfig) -> Optional[str]:
    """
    loads validator identity account pubkey
    :param config: Validator Configuration
    :return: returns validator identity pubkey or None
    """
    identity_cmd = f'solana address -u localhost --keypair ' + config.secrets_path + '/validator-keypair.json'
    debug(config, identity_cmd)
    return execute_cmd_str(identity_cmd)


def load_vote_account_pubkey(config: ValidatorConfig) -> Optional[str]:
    """
    loads vote account pubkey
    :param config: Validator Configuration
    :return: returns vote account pubkey  or None
    """
    vote_pubkey_cmd = f'solana address -u localhost --keypair ' + config.secrets_path + '/vote-account-keypair.json'
    debug(config, vote_pubkey_cmd)
    return execute_cmd_str(vote_pubkey_cmd)


def load_vote_account_balance(config: ValidatorConfig, vote_account_pubkey: str):
    """
    loads vote account balance
    https://docs.solana.com/developing/clients/jsonrpc-api#getbalance
    """
    return smart_rpc_call(config, "getBalance", [vote_account_pubkey], {})


def load_identity_account_balance(config: ValidatorConfig, identity_account_pubkey: str):
    """
    loads identity account balance
    https://docs.solana.com/developing/clients/jsonrpc-api#getbalance
    """
    return smart_rpc_call(config, "getBalance", [identity_account_pubkey], {})


def load_epoch_info(config: ValidatorConfig):
    """
    loads epoch info
    https://docs.solana.com/developing/clients/jsonrpc-api#getbalance
    """
    return smart_rpc_call(config, "getEpochInfo", [], {})


def load_leader_schedule(config: ValidatorConfig, identity_account_pubkey: str):
    """
    loads leader schedule
    https://docs.solana.com/developing/clients/jsonrpc-api#getleaderschedule
    """
    params = [
        None,
        {
            'identity': identity_account_pubkey
        }
    ]
    return smart_rpc_call(config, "getLeaderSchedule", params, {})


def load_block_production(config: ValidatorConfig, identity_account_pubkey: str):
    """
    loads block production
    https://docs.solana.com/developing/clients/jsonrpc-api#getblockproduction
    """
    params = [
        {
            'identity': identity_account_pubkey
        }
    ]
    return smart_rpc_call(config, "getBlockProduction", params, {})


def load_vote_accounts(config: ValidatorConfig, vote_account_pubkey: str):
    """
    loads block production
    https://docs.solana.com/developing/clients/jsonrpc-api#getvoteaccounts
    """
    params = [
        {
            'votePubkey': vote_account_pubkey
        }
    ]
    return rpc_call(config.remote_rpc_address, "getVoteAccounts", params, {}, {})


def load_recent_performance_sample(config: ValidatorConfig):
    """
    loads recent performance sample
    https://docs.solana.com/developing/clients/jsonrpc-api#getrecentperformancesamples
    """
    params = [1]
    return rpc_call(config.remote_rpc_address, "getRecentPerformanceSamples", params, [], [])


def load_solana_version(config: ValidatorConfig):
    """
    loads solana version
    https://docs.solana.com/developing/clients/jsonrpc-api#getversion
    """
    return rpc_call(config.remote_rpc_address, "getVersion", [], [], [])


def get_metrics_from_vote_account_item(item):
    return {
            'epoch_number': item['epochCredits'][-1][0],
            'credits_epoch': item['epochCredits'][-1][1],
            'credits_previous_epoch': item['epochCredits'][-1][2],
            'activated_stake': item['activatedStake'],
            'credits_epoch_delta': item['epochCredits'][-1][1] - item['epochCredits'][-1][2],
            'commission': item['commission']
        }
    

def find_item_in_vote_accounts_section(identity_account_pubkey, section_parent, section_name):
    if section_name in section_parent:
        section = section_parent[section_name]
        for item in section:
            if item['nodePubkey'] == identity_account_pubkey:
                return get_metrics_from_vote_account_item(item)

    return None


def get_vote_account_metrics(vote_accounts_data, identity_account_pubkey):
    """
    get vote metrics from vote account
    :return: 
    voting_status: 0 if validator not found in voting accounts
    voting_status: 1 if validator is current
    voting_status: 2 if validator is delinquent

    """
    result = find_item_in_vote_accounts_section(identity_account_pubkey, vote_accounts_data, 'current')
    if result is not None:
        result.update({'voting_status': 1})
    else:
        result = find_item_in_vote_accounts_section(identity_account_pubkey, vote_accounts_data, 'delinquent')
        if result is not None:
            result.update({'voting_status': 2})
        else:
            result = {'voting_status': 0}
    return result


def get_leader_schedule_metrics(leader_schedule_data, identity_account_pubkey):
    """
    get metrics about leader slots
    """
    if identity_account_pubkey in leader_schedule_data:
        return {"leader_slots_this_epoch": len(leader_schedule_data[identity_account_pubkey])}
    else:
        return {"leader_slots_this_epoch": 0}


def get_block_production_metrics(block_production_data, identity_account_pubkey):
    try:
        item = block_production_data['value']['byIdentity'][identity_account_pubkey]
        return {
            "slots_done": item[0],
            "slots_skipped": item[0] - item[1],
            "blocks_produced": item[1]

        }
    except:
        return {"slots_done": 0, "slots_skipped": 0, "blocks_produced": 0}
       

def get_performance_metrics(performance_sample_data, epoch_info_data, leader_schedule_by_identity):

    if len(performance_sample_data) > 0:
        sample = performance_sample_data[0]
        mid_slot_time = sample['samplePeriodSecs'] / sample['numSlots']
        current_slot_index = epoch_info_data['slotIndex']
        remaining_time = (epoch_info_data["slotsInEpoch"] - current_slot_index)*mid_slot_time
        epoch_end_time = round(time.time()) + remaining_time
        time_until_next_slot = -1
        if leader_schedule_by_identity is not None:
            for slot in leader_schedule_by_identity:
                if current_slot_index < slot:
                    next_slot = slot
                    time_until_next_slot = (next_slot - current_slot_index)*mid_slot_time
                    break
        else:
            time_until_next_slot = None

        result = {
            "epoch_endtime": epoch_end_time,
            "epoch_remaining_sec": remaining_time
        }

        if time_until_next_slot is not None:
            result.update({"time_until_next_slot": time_until_next_slot})
    else:
        result = {}

    return result


def get_balance_metric(balance_data, key: str):
    if 'value' in balance_data:
        result = {key: balance_data['value']}
    else:
        result = {}

    return result


def get_solana_version_metric(solana_version_data):
    if 'solana-core' in solana_version_data:
        return {'solana_version': solana_version_data['solana-core']}
    else:
        return {}


def load_data(config: ValidatorConfig):
    identity_account_pubkey = load_identity_account_pubkey(config)
    vote_account_pubkey = load_vote_account_pubkey(config)

    if (identity_account_pubkey is not None) and (vote_account_pubkey is not None):
        identity_account_balance_data = load_identity_account_balance(config, identity_account_pubkey)
        vote_account_balance_data = load_vote_account_balance(config, vote_account_pubkey)
        epoch_info_data = load_epoch_info(config)
        leader_schedule_data = load_leader_schedule(config, identity_account_pubkey)
        block_production_data = load_block_production(config, identity_account_pubkey)
        vote_accounts_data = load_vote_accounts(config, vote_account_pubkey)
        performance_sample_data = load_recent_performance_sample(config)
        solana_version_data = load_solana_version(config)

        result = {
            'identity_account_pubkey': identity_account_pubkey,
            'vote_account_pubkey': vote_account_pubkey,
            'identity_account_balance':  identity_account_balance_data,
            'vote_account_balance': vote_account_balance_data,
            'epoch_info': epoch_info_data,
            'leader_schedule': leader_schedule_data,
            'block_production': block_production_data,
            'vote_accounts': vote_accounts_data,
            'performance_sample': performance_sample_data,
            'solana_version_data': solana_version_data
        }

        debug(config, str(result))

        return result
    else:
        return None


def calculate_influx_fields(config: ValidatorConfig):
    data = load_data(config)

    if data is None:
        result = {"validator_status": 0}
    else:
        identity_account_pubkey = data['identity_account_pubkey']

        vote_account_metrics = get_vote_account_metrics(data['vote_accounts'], identity_account_pubkey)
        leader_schedule_metrics = get_leader_schedule_metrics(data['leader_schedule'], identity_account_pubkey)
        epoch_metrics = data['epoch_info']
        block_production_metrics = get_block_production_metrics(data['block_production'], identity_account_pubkey)
        if identity_account_pubkey in data['leader_schedule']:
            leader_schedule_by_identity = data['leader_schedule'][identity_account_pubkey]
        else:
            leader_schedule_by_identity = None

        performance_metrics = get_performance_metrics(
            data['performance_sample'], epoch_metrics, leader_schedule_by_identity)

        result = {"validator_status": 1}
        result.update(vote_account_metrics)
        result.update(leader_schedule_metrics)
        result.update(epoch_metrics)
        result.update(block_production_metrics)
        result.update(performance_metrics)
        result.update(get_balance_metric(data['identity_account_balance'], 'identity_account_balance'))
        result.update(get_balance_metric(data['vote_account_balance'], 'vote_account_balance'))
        result.update(get_solana_version_metric(data['solana_version_data']))

    result.update({"monitoring_version": 1})

    return result


def calculate_influx_data(config: ValidatorConfig):
    influx_measurement = {
        "measurement": "validators_info",
        "time": round(time.time() * 1000),
        "validator_name": config.validator_name,
        "fields": calculate_influx_fields(config)
    }

    return influx_measurement
