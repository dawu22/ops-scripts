#!/bin/bash
repo_lighthouse='sigp/lighthouse'
key_lighthouse='mandatory'
 
repo_geth='ethereum/go-ethereum'
key_geth='mainnet'
 
repo_tron='tronprotocol/java-tron'
key_tron='mandatory'
 
repo_btc='bitcoin/bitcoin'
key_btc='available'
 
repo_bsc='bnb-chain/bsc'
key_bsc='hard fork|required'
 
repo_solana='solana-labs/solana'
key_solana='recommended'
 
#github_api="https://api.github.com/repos/${repo_solana}/releases/latest"
 
for fullnode in 'geth' 'lighthouse' 'tron' 'btc' 'bsc' 'solana';do
    github_api="https://api.github.com/repos/$(eval echo '$'"repo_$fullnode")/releases/latest"
    json=$(curl -s ${github_api})
    echo $json | grep -iE "$(eval echo '$'"{key_$fullnode}")" | grep -iv 'Non-mandatory' | grep -v grep > /dev/null 2>&1
    if [[ $? -ne 0 ]];then continue;fi
    tag_name=$(echo $json | jq .tag_name)
    create_at=$(echo $json | jq .created_at | tr -d '"')
 
    now=$(date +%s)
    create=$(date -d ${create_at} +%s)
    diff_time=$(expr $now - $create)
    echo "version_fullnode_latest{job=\"$fullnode\",version=${tag_name},create_at=\"${create_at}\"} ${diff_time}"
done
