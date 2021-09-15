from pprint import pprint


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
