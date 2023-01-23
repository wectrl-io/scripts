import requests
import socket

from logger import logger


def get_host_hostname():
    return socket.gethostname()


def get_host_ip() -> str:
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))

    return s.getsockname()[0]


def is_tasmota(ip_address) -> bool:
    pass


def is_shelly_gen1(ip_address) -> bool:
    logger.debug(f"Checking {ip_address} if Shelly gen 1")

    try:
        response = requests.get(f'http://{ip_address}/status/', timeout=(0.5, None))
    except requests.exceptions.ConnectTimeout:
        logger.debug("No device there.")
        return False
    
    try:
        response.json()
    except requests.exceptions.JSONDecodeError:
        return False

    return response.ok


def is_shelly_gen2(ip_address) -> bool:
    logger.debug(f"Checking {ip_address} if Shelly gen 2")

    try:
        response = requests.get(f'http://{ip_address}/rpc/Mqtt.GetConfig', timeout=(0.5, None))
    except requests.exceptions.ConnectTimeout:
        logger.debug("No device there.")
        return False
    
    try:
        response.json()
    except requests.exceptions.JSONDecodeError:
        return False

    return response.ok
