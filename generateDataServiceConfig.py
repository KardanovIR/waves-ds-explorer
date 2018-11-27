import os
from yaml import load, dump

node_api_url = os.getenv('NODE_API_URI', 'http://localhost:6816')


with open("/var/src/blockchain-postgres-sync/config.example.yml", 'r') as stream:
    config = load(stream)

config['nodeAddress'] = node_api_url
config['postgresHost'] = 'localhost'
config['postgresDatabase'] = 'dataservices'
config['postgresUser'] = 'postgres'
config['postgresPassword'] = 'APASSWORD'


print(config)

with open('/var/src/blockchain-postgres-sync/config.yml', 'w') as outfile:
    dump(config, outfile, default_flow_style=False)
