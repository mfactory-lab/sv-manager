import json
import subprocess


def execute_cmd_str(cmd: str):
    """
    executes shell command and return string result
    :param cmd: shell command
    :return: returns string result or None
    """
    try:
        return json.loads(subprocess.check_output(cmd, shell=True).decode())
    except:
        return None


def load_stake_account_rewards(stake_account):
    cmd = f'solana stake-account ' + stake_account + ' --num-rewards-epochs=1 --with-rewards --output json-compact'
    return execute_cmd_str(cmd)


def calc_apy(rewards_data, epoch_count):
    if 'epochRewards' in rewards_data:
        epoch_rewards = rewards_data['epochRewards']
        if len(epoch_rewards) > 0:
            epoch_reward = rewards_data['epochRewards'][0]
            if 'percentChange' in epoch_reward:
                percent_change = epoch_reward['percentChange']
                apy = (1 + percent_change / 100) ** epoch_count - 1
                return apy

    return None


def process(stake_account):
    rewards_data = load_stake_account_rewards(stake_account)
    if stake_account is not None:
        apy = calc_apy(rewards_data, 130)

        if apy is not None:
            return apy

    return 0


apy = process('6P2SLykNoJH7G2TbL4MZNWEN9i4JgJXCLrUgK2V99bnT')
print(apy * 100)
