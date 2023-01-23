import logging

# create logger
logger = logging.getLogger('PyIOTToolkit')
logger.setLevel(logging.ERROR)

# create console handler and set level to debug
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)

# create formatter
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# add formatter to ch
hc.setFormatter(formatter)

# add ch to logger
logger.addHandler(ch)
