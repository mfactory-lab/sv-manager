import validator_monitoring_library as vm

config = vm.ValidatorConfig(
    validator_name="local_test",
    secrets_path=".",
    local_rpc_address="http://localhost:8899",
    remote_rpc_address="https://api.testnet.solana.com",
    debug_mode=True
)
