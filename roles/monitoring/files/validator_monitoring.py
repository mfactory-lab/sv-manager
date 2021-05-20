import validator_monitoring_library as vm
import json
from validator_monitoring_config import config


def process():
    influx_measurement = vm.calculate_influx_data(config)
    print(json.dumps(influx_measurement))


if __name__ == '__main__':
    process()
