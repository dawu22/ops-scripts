##查询全网最新高度：
curl https://apilist.tronscanapi.com/api/system/status
##查询本节点高度：
curl http://localhost:8090/wallet/getblock
##查看metrics
curl http://localhost:9527/metrics
##查询最新版本
curl -s https://api.github.com/repos/tronprotocol/java-tron/releases/latest | jq .tag_name
