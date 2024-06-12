from fastapi import FastAPI, BackgroundTasks
import boto3
import json
from pydantic import BaseModel
import logging

app = FastAPI()

class OrderRequest(BaseModel):
    orderId: int

@app.post("/provision-eks")
async def provision_eks(background_tasks: BackgroundTasks, order_request: OrderRequest):
    try:
        # Extract orderId from request body
        order_id_str = str(order_request.orderId)

        # sns trigger (did not work out with App Runner, should be tested on EKS)
        sns_client = boto3.client("sns")

        message = {
            "serviceType": "batch_processing",
            "orderId": order_id_str
        }

        logging.info(f"Publishing message to SNS: {message}")
        sns_client.publish(
            TopicArn="arn:aws:sns:us-east-1:<topic>:orders",
            Message=json.dumps(message),
        )

        return {"message": "EKS cluster provisioning initiated!"}

    except Exception as e:
        logging.error(f"Error sending message to SNS: {e}")
        return {"error": "Failed to initiate EKS provisioning"}

# RDS and Elastic Cache endpoints should be added        