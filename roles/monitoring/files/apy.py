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


def load_stake_account_rewards(stake_account, epochs):
    # solana stake-account 6P2SLykNoJH7G2TbL4MZNWEN9i4JgJXCLrUgK2V99bnT --num-rewards-epochs=1 --with-rewards --output json-compact
    cmd = f'solana stake-account ' + stake_account + ' --num-rewards-epochs=' + str(epochs) + ' --with-rewards --output json-compact'
    return execute_cmd_str(cmd)


def get_rewards(rewards_data):
    result = []

    if rewards_data is not None:
        if 'epochRewards' in rewards_data:
            epoch_rewards = rewards_data['epochRewards']
            for reward in epoch_rewards:
                result.append({
                    'percent_change': reward['percentChange'],
                    'apr': reward['apr']
                })

    return result


def calc_apy(apr, percent_change):
    epoch_count = apr / percent_change
    result = ((1 + percent_change / 100) ** epoch_count - 1) * 100
    return result


def process(stake_account):
    rewards_data = load_stake_account_rewards(stake_account, 10)
    rewards = get_rewards(rewards_data)

    l_apy = []

    for reward in rewards:
        apy = calc_apy(reward['apr'], reward['percent_change'])
        l_apy.append(apy)

    return l_apy


def avg(l_apy):
    s = 0

    for item in l_apy:
        s = s + item

    if len(l_apy) > 0:
        return s/len(l_apy)
    else:
        return 0


calc = process('6P2SLykNoJH7G2TbL4MZNWEN9i4JgJXCLrUgK2V99bnT')
print(calc)
print(avg(calc))
