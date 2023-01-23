from logger import logger
from tools.network import is_shelly_gen1


def main():
    result = is_shelly_gen1("192.168.68.123")

    logger.debug(result)


if __name__ == "__main__":
    main()
