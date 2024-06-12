import boto3
import logging
import json


def lambda_handler(event, context):
    # Extract message based on trigger type
    message_body = None

    # Handle message from SNS event
    if "Records" in event:
        message_record = event['Records'][0]
        message_body = message_record['body']

    # Handle message from SQS event
    elif "Message" in event:
        message_body = event['Message']

    # Handle potential errors
    if not message_body:
        logging.error("Empty message received!")
        return {
            'statusCode': 400,
            'body': json.dumps("Error: Empty message received!")
        }

    # Extract message data
    message = json.loads(message_body)

    # Extract service type and order ID
    service_type = message.get("serviceType")
    order_id = message.get("orderId")

    logging.info(f"Received message for service type: {service_type}")
    logging.info(f"Received message for order ID: {order_id}")

    try:
        eks = boto3.client('eks')

        # logic - service type
        if service_type == "batch_processing":
            response = eks.create_cluster(
            name=f"eks-cluster-{order_id}",
            resourcesVpcConfig={
                "securityGroupIds": [],
            },
            nodegroupName="default",
            scalingConfig={
                "desiredCapacity": 3,
                "instanceType": "t3.medium",
            },
        )
        # Extracting cluster ARN from response
        cluster_arn = response['cluster']['arn']

        logging.info(f"EKS cluster created: (ARN: {cluster_arn})")
        message = f"EKS cluster creation initiated for order ID: {order_id} (ARN: {cluster_arn})"

    except Exception as e:
        logging.error(f"EKS cluster provisioning failed: {e}")

    return {
        'statusCode': 200,
        'body': json.dumps(message)
    }