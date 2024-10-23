#!/bin/bash
 
dbmap=("prod1" "prod2") 
 
for layer in ${dbmap[@]};do
    aws rds describe-db-instances --query "DBInstances[*].[DBInstanceIdentifier, DBInstanceStatus, DBInstanceClass, Engine]" --profile $layer --output text | while read line;do
    db_identifer=$(echo "$line" | awk '{print $1}')
    db_status=$(echo "$line" | awk '{print $2}')
    db_instance_class=$(echo "$line" | awk '{print $3}')
    db_engine=$(echo "$line" | awk '{print $4}')
    echo "db,busigroup=$layer,db_identifer=${db_identifer},db_status=${db_status},db_instance_class=${db_instance_class},db_engine=${db_engine} status=1"
        done
    aws elasticache describe-cache-clusters --query "CacheClusters[*].[CacheClusterId, CacheClusterStatus, CacheNodeType, Engine]" --profile $layer --output text | while read line;do
    db_identifer=$(echo "$line" | awk '{print $1}')
    db_status=$(echo "$line" | awk '{print $2}')
    db_instance_class=$(echo "$line" | awk '{print $3}')
    db_engine=$(echo "$line" | awk '{print $4}')
    echo "db,busigroup=$layer,db_identifer=${db_identifer},db_status=${db_status},db_instance_class=${db_instance_class},db_engine=${db_engine} status=1"
        done
done
