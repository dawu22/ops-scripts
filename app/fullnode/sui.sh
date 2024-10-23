#fullnode
curl -s --data-binary '{"jsonrpc":"2.0","id":1,"method":"sui_getLatestCheckpointSequenceNumber","params":[]}' --header 'content-type: application/json' http://127.0.0.1:9000/ | jq
curl -s --data-binary '{"jsonrpc":"2.0","id":1,"method":"sui_getTotalTransactionBlocks","params":[]}' --header 'content-type: application/json' http://127.0.0.1:19000/ | jq
curl -s --data-binary '{"jsonrpc":"2.0","id":0,"method":"suix_getLatestSuiSystemState","params":[]}' --header 'content-type: application/json' http://127.0.0.1:19000/ | jq


#validator
#highest_known_checkpoint
#highest_synced_checkpoint
#highest_verified_checkpoint
curl -s 127.1:37212/metrics | grep highest_synced_checkpoint

