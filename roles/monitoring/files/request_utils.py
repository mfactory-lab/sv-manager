from common import ValidatorConfig
import subprocess
import requests
import json


def execute_cmd_str(cmd: str, convert_to_json: bool):
    """
    executes shell command and return string result
    :param convert_to_json:
    :param cmd: shell command
    :return: returns string result or None
    """
    try:
        result: str = subprocess.check_output(cmd, shell=True, stderr=subprocess.DEVNULL).decode().strip()

        if convert_to_json:
            result = json.loads(result)

        return result
    except:
        return None


def rpc_call(address: str, method: str, params, error_result, except_result):
    """
    calls solana rpc (https://docs.solana.com/developing/clients/jsonrpc-api)
    and returns result or default
    :param except_result:
    :param error_result:
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
