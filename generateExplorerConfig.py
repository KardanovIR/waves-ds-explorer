import os

data_services_port = os.getenv('DATA_SERVICES_PORT', '8080')
node_api_url = os.getenv('NODE_API_URI', 'http://localhost:6816')
data_service_url = os.getenv('DATA_SERVICES_URL', f"http://localhost:{data_services_port}")
network_byte = os.getenv('WAVES_NETWORK_BYTE', 'C')
blockchain_name = os.getenv('BLOCKCHAIN_NAME', 'Devnet')
nodes_by_comma = os.getenv('NODES_LIST', '')

nodes_list = nodes_by_comma.split(',')

nodes = []

for x in nodes_list:
    nodes.append(f"{{url: '{x}', maintainer: 'Local', showAsLink: true}},")

config = f"""
(function () {{
    'use strict';

    angular.module('web').constant('appConfig', {{
        apiDomain: '{node_api_url}',
        dataServiceBaseUrl: '{data_service_url}',
        title: '{blockchain_name} Explorer',
        blockchainName: '{blockchain_name}',
        nodes: [
            {''.join(nodes)}
        ],
        peerExplorer: {{
            url: '/',
            title: '{blockchain_name} Explorer'
        }},
        wallet: {{
            url: '/',
            title: 'Wallet'
        }}
    }});


    angular.module('web').constant('constants.network', {{
        NETWORK_NAME: 'devnet',
        ADDRESS_VERSION: 1,
        NETWORK_CODE: '{network_byte}',
        INITIAL_NONCE: 0
    }});
}})();

"""

with open('/var/src/WavesExplorerLite/src/js/config.devnet.js', 'w') as file:
    file.write(config)

