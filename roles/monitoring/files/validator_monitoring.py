import validator_monitoring_library as vm
import json
from validator_monitoring_config import config
import numpy
import sentry_sdk



class NumpyEncoder(json.JSONEncoder):
    """ Special json encoder for numpy types """
    def default(self, obj):
        if isinstance(obj, (numpy.int_, numpy.intc, numpy.intp, numpy.int8,
                            numpy.int16, numpy.int32, numpy.int64, numpy.uint8,
                            numpy.uint16, numpy.uint32, numpy.uint64)):
            return int(obj)
        elif isinstance(obj, (numpy.float_, numpy.float16, numpy.float32,
                              numpy.float64)):
            return float(obj)
        elif isinstance(obj, (numpy.ndarray,)):
            return obj.tolist()
        return json.JSONEncoder.default(self, obj)


def process():
    influx_measurement = vm.calculate_influx_data(config)
    print(json.dumps(influx_measurement, cls=NumpyEncoder))


if __name__ == '__main__':
    sentry_sdk.init(
        "https://796f81698cde4f67bd7975a2c7f12fa9@o913712.ingest.sentry.io/5851910",

        # Set traces_sample_rate to 1.0 to capture 100%
        # of transactions for performance monitoring.
        # We recommend adjusting this value in production.
        traces_sample_rate=1.0
    )

    process()
