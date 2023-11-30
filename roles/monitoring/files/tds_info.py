from common import ValidatorConfig
import requests
from common import debug


def tds_rpc_call(config: ValidatorConfig, identity_account_pubkey: str):

    address = "https://kyc-api.vercel.app/api/validators/list?search_term=" + identity_account_pubkey

    try:
        debug(config, address)
        json_response = requests.get(address, timeout=5).json()
        if 'data' not in json_response:
            result = {}
        else:
            result = json_response['data']
    except:
        result = {}

    debug(config, result)

    return result


def load_tds_info(config: ValidatorConfig, identity_account_pubkey: str):
    tds_data = tds_rpc_call(config, identity_account_pubkey)
    result = {}
    if tds_data != [] and tds_data != {}:
        if 'tn_calculated_stats' in tds_data[0] and tds_data[0]['tn_calculated_stats'] is not None:
            result = {
                'tds': tds_data[0]['tn_calculated_stats'],
            }
            if 'onboarding_number' in tds_data[0]:
                result['tds']['onboarding_number'] = tds_data[0]['onboarding_number']
                result['tds']['onboarding_group'] = tds_data[0]['tds_onboarding_group']

    debug(config, result)

    return result
