from common import ValidatorConfig
from typing import Optional
from common import debug
from request_utils import execute_cmd_str, smart_rpc_call, rpc_call


def load_identity_account_pubkey(config: ValidatorConfig) -> Optional[str]:
    """
    loads validator identity account pubkey
    :param config: Validator Configuration
    :return: returns validator identity pubkey or None
    """
    identity_cmd = f'solana address -u localhost --keypair ' + config.secrets_path + '/validator-keypair.json'
    debug(config, identity_cmd)
    return execute_cmd_str(identity_cmd, convert_to_json=False)


def load_vote_account_pubkey(config: ValidatorConfig) -> Optional[str]:
    """
    loads vote account pubkey
    :param config: Validator Configuration
    :return: returns vote account pubkey  or None
    """
    vote_pubkey_cmd = f'solana address -u localhost --keypair ' + config.secrets_path + '/vote-account-keypair.json'
    debug(config, vote_pubkey_cmd)
    return execute_cmd_str(vote_pubkey_cmd, convert_to_json=False)


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


def load_stake_account_rewards(stake_account):
    cmd = f'solana stake-account ' + stake_account + ' --num-rewards-epochs=1 --with-rewards --output json-compact'
    return execute_cmd_str(cmd, convert_to_json=True)


def load_solana_validators():
    cmd = f'solana validators --output json-compact'
    data = execute_cmd_str(cmd, convert_to_json=True)

    if 'validators' in data:
        return data['validators']
    else:
        return None


def load_stakes(vote_account):
    cmd = f'solana stakes ' + vote_account + ' --output json-compact'
    return execute_cmd_str(cmd, convert_to_json=True)


