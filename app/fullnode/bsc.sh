curl -s -H "Content-Type:application/json"  -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":56}'  https://bsc-dataseed.binance.org | jq .result |  tr -d '"' | xargs printf "%d\n"

