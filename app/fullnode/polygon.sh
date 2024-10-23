#Heimdall查询本地节点状态：catching_up不为true，表示heimdall没有同步完成
curl -s localhost:26657/status | jq  .result.sync_info.catching_up
#bor同步状态查询：
curl -s 'localhost:8545/' --header 'Content-Type: application/json' -d '{ "jsonrpc":"2.0", "method":"eth_syncing", "params":[], "id":1 }'
 
#全网最新高度查询：
curl -s 'https://api.polygonscan.com/api?module=proxy&action=eth_blockNumber' | jq .result | xargs printf '%d\n'
