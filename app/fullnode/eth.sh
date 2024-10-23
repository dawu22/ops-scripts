curl 'https://api.etherscan.io/api?module=proxy&action=eth_blockNumber'

curl -XPOST -H 'Content-Type: application/json' --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'  http://localhost:8545

curl 127.1:6060/debug/metrics/prometheus

curl -s https://api.github.com/repos/sigp/lighthouse/releases/latest | jq .tag_name
curl -s https://api.github.com/repos/ethereum/go-ethereum/releases/latest | jq .tag_name
