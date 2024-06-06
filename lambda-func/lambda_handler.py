import json
import requests

def lambda_handler(event, context):
    service_type = event["service_type"]

    # Diagrid API endpoint and headers
    url = "https://catalyst.region.diagrid.io/apps/your-app-id/workflows/start"
    headers = {"Authorization": f"diagrid-catalyst-token"}

    # Data for Diagrid workflow
    workflow_data = {"service_type": service_type}

    try:
        # Diagrid workflow trigger based on service_type
        if service_type in ("eks", "rds", "elasticache"):
            response = requests.post(url, headers=headers, json=workflow_data)
            response.raise_for_status()  # Exception for non-2xx status codes
            logging.info(f"Triggered Diagrid workflow for {service_type} provisioning.")
            return {"message": f"Provisioning request for {service_type} initiated!"}

        else:
            return {"message": f"Unsupported service type: {service_type}"}

    except requests.exceptions.RequestException as e:
        logging.error(f"Error triggering Diagrid workflow: {e}")
        return {"error": "Failed to initiate provisioning request. Please try again later."}