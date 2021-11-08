""" Script to overwrite values in set config
    python3 overwrite_config.py \
    -u https://gist.githubusercontent.com/Rub21/1a82fb3e4c0efd15524709a5e2d8ab89/raw/23c399802ba2a01cc30379875ac02a7b1b5ac8e1/taginfo.json\
    -f taginfo-config.json
"""

import argparse
import urllib.request
import json

def main(config_file, overwrite_config_url):
    with urllib.request.urlopen(overwrite_config_url) as url:
        overwrite_values = json.loads(url.read())
    with open(config_file) as f:
        current_values = json.loads(f.read())
    # Hardcode for certain values
    if 'instance' in overwrite_values.keys():
        current_values['instance'] = overwrite_values['instance']
    if 'turbo' in overwrite_values.keys():
        current_values['turbo'] = overwrite_values['turbo']
    if 'sources' in overwrite_values.keys() and 'master' in overwrite_values['sources'].keys():
        current_values['sources']['master'] = overwrite_values['sources']['master']
    # Overwrite file
    with open(config_file + '.json', 'w') as f:
        f.write(json.dumps(current_values))


parser = argparse.ArgumentParser(description='Set config values')
parser.add_argument(
    '-u',
    type=str,
    help='URL of the config to overwrite',
    dest='overwrite_config_url')

parser.add_argument(
    '-f'
    '--config_file',
    type=str,
    help='Path of the config file',
    dest='config_file')

args = parser.parse_args()

if args.config_file and args.overwrite_config_url:
    main(args.config_file, args.overwrite_config_url)
