#!/bin/bash

SG_ID="sg-02e0791460060eb90"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z07001291I5OKT2L6X235"
DOMAIN_NAME="durgagopalakrishna.online"

for instance in $@
do
    echo "Creating EC2 instance for $instance"
    INSTANCE_ID=$( aws ec2 run-instances \
     --image-id $AMI_ID \
     --instance-type "t3.micro" \
     --security-group-ids $SG_ID \
     --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
     --query 'Instances[0].InstanceId' \
     --output text )
        echo "Instance ID of $instance is $INSTANCE_ID"

    if [ $instance == "frontend" ]; then
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text
            echo "IP address of $instance is $IP"
        )
        RECORD_NAME="$DOMAIN_NAME" # durgagopalakrishna.online
    else
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text
            echo "IP address of $instance is $IP"

        )
        RECORD_NAME="$instance.$DOMAIN_NAME" # mongodb.durgagopalakrishna.online
    fi

    echo "IP Address $IP"
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Updating record ",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
    }  
    '
    echo "Record created for $instance with IP $IP and record name $RECORD_NAME"
done