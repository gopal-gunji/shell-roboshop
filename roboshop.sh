#!/bin/bash

SG_ID="sg-02e0791460060eb90"
AMI_ID="ami-0220d79f3f480ecf5"

for instance in $@
do

    echo "creating instance for $instance"

    instance_id=$( aws ec2 run-instances \
     --image-id $AMI_ID \
     --instance-type t3.micro \
     --security-group-ids $SG_ID \
     --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
     --query 'Reservations[0].Instances[0].PrivateIpAddress' \
     --output text )


    if [ $instance == "frontend" ]; then
        IP=$(
            aws ec2 describe-instsnces \
            --instance-ids $instance_id \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text
        )
    else
        IP=$(
            aws ec2 describe-instsnces \
            --instance-ids $instance_id \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text
        )
    fi


done