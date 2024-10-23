#!/bin/bash

##/usr/local/bin/aws logs get-log-events --log-group-name /aws/rds/instance/rds-prod1/slowquery --log-stream-name rds-prod1 --profile prod1 --start-time 1712016000000 --end-time 1712102399000 --out json 


function get_sql()
{
        content=$1
        sql=$(echo "$content" | jq .events[].message | sed 's/"//g')
        echo "$sql"
}
function get_back_token()
{
        content=$1
        back_token=$(echo "$content" | jq .nextBackwardToken)
        echo "${back_token}"
}
function get_forward_token()
{
        content=$1
        forward_token=$(echo "$content" | jq .nextForwardToken)
        echo "${forward_token}"
}

function main()
{
        slow_log_path="/tmp"
        #rm -f ${slow_log_path}/*slowtop*

        day=$(date -d "-1 day" +%Y-%m-%d)
        start_time=$(date -d "${day}T00:00:00Z" +%s%3N)
        end_time=$(date -d "${day}T23:59:59Z" +%s%3N)

        chat_id="xxxx"
        token="xxxx"
	   
        profile=$1
        rdsins=$(/usr/local/bin/aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier]' --output text --profile $profile)

        for rds in $rdsins;do
                tmp_log="${slow_log_path}/.${rds}.tmp"
                echo > ${tmp_log}
		        rds_log_group=$rds
		        rds_type="instance"
		        if [ "$profile" == "kyc" ];then
			            rds_type="cluster"
		                rds_log_group="kyc-database-prod-1"
		        fi
                awscommand="/usr/local/bin/aws logs get-log-events --log-group-name /aws/rds/${rds_type}/${rds_log_group}/slowquery --log-stream-name $rds --profile $profile --start-time ${start_time} --end-time ${end_time} --out json"
                content=$(eval "$awscommand")
                fsql=$(get_sql "$content")
                bsql=$(get_sql "$content")
                ftoken=$(get_forward_token "$content")
                btoken=$(get_back_token "$content")
		        ftoken_num=$(echo $ftoken | awk -F/ '{print $2}')
		        btoken_num=$(echo $btoken | awk -F/ '{print $2}')

                _ftoken=$ftoken
                #while [ -n "$fsql" ] ;do
                while [ "${ftoken_num}" != "${btoken_num}" ] ;do
			            if [ -n "$fsql" ];then
                                 echo "$fsql" >> ${tmp_log}
			            fi
                        content=$(eval "$awscommand --next-token $_ftoken")
                        _ftoken=$(get_forward_token "$content")
                	    _btoken=$(get_back_token "$content")
                        fsql=$(get_sql "$content")
			            _ftoken_num=$(echo $_ftoken | awk -F/ '{print $2}')
			            _btoken_num=$(echo $_btoken | awk -F/ '{print $2}')
			            if [ ${_ftoken_num} == ${_btoken_num} ];then
				                break
			            fi
                done

                _btoken=$btoken
                #while [ -n "$bsql" ] ;do
                while [ "${ftoken_num}" != "${btoken_num}" ] ;do
                        content=$(eval "$awscommand --next-token $_btoken")
                        bsql=$(get_sql "$content")
                        echo "$bsql" >> ${tmp_log}
                        _ftoken=$(get_forward_token "$content")
                	    _btoken=$(get_back_token "$content")
			            _ftoken_num=$(echo $_ftoken | awk -F/ '{print $2}')
			            _btoken_num=$(echo $_btoken | awk -F/ '{print $2}')
			            if [ ${_ftoken_num} == ${_btoken_num} ];then
				               break
			            fi
                done

                log=${slow_log_path}/${rds}.slowtop-${day}
                ready_log=${log}.log
                if [[ -n "$(cat "${tmp_log}")" ]];then
                        #cat ${tmp_log} | sort -k11nr | sed '/^$/d' > ${log}
                        cat ${tmp_log} | sort -k11nr | sed '/^$/d' | sed 's/\\n/\n/g' > ${log}
                        /usr/bin/mysqldumpslow   -s t -t 20 ${log} >  ${ready_log}
                        curl -s -F chat_id="${chat_id}" -F document=@"${ready_log}" https://api.telegram.org/bot$token/sendDocument > /dev/null
                fi
        done
}

main $1
