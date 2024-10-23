#!/bin/bash
 
profile="prod"
rdsins=$(aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DbiResourceId]' --output text --profile $profile)
 
IFS_old=$IFS
IFS=$'\n'
for r in $rdsins;do
    rds_id=$(echo $r | cut -f2)
    rds_name=$(echo $r | cut -f1)
    end_time=$(date +%s)
    start_time=$(expr ${end_time} - 300)
    resp=$(aws pi get-resource-metrics --service-type RDS --identifier ${rds_id} --start-time ${start_time} --end-time ${end_time} --period-in-seconds 300 --metric-queries file:///usr/local/categraf/scripts/metric-queries.json --profile $profile )
    value=$(echo $resp | jq '.MetricList[]| "\(.Key.Metric) \(.DataPoints[0].Value)"')
    rds_queries=$(echo $value | grep -Po "db.SQL.Queries.avg\ [\d+\.]+.*?" | awk '{printf $2}')
    rds_transaction_active=$(echo $value | grep -Po "db.Transactions.active_transactions.avg\ [\d+\.]+.*?" | awk '{printf $2}')
    rds_innodb_row_lock_waites=$(echo $value | grep -Po "db.Locks.innodb_row_lock_waits.avg\ [\d+\.]+.*?" | awk '{printf $2}')
 
    labels="{db_instance_identifier=\"${rds_name}\",busigroup=\"$profile\"}"
 
    echo "rds_queries$labels"  $rds_queries
    echo "rds_transaction_active$labels" ${rds_transaction_active}
    echo "rds_innodb_row_lock_waites$labels" ${rds_innodb_row_lock_waites}
done
 
IFS=${IFS_old}
