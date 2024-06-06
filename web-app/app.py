from flask import Flask, render_template, request, flash, redirect
import requests
import logging
from config import DIAGRID_APP_ID, DIAGRID_TOKEN, DIAGRID_API_URL

app = Flask(__name__)


@app.route("/")
def home():
    return render_template("index.html")


@app.route("/provision", methods=["POST"])
def provision_service():
    service_type = request.form.get("service_type")
    if not service_type:
        return "Please select a service type to provision.", 400

    try:
        # service data
        service_data = {"service_type": service_type}

        # API endpoint URL
        url = DIAGRID_API_URL.format(DIAGRID_APP_ID, "state/services")

        # Headers for Diagrid API authentication
        headers = {"Authorization": f"Bearer {DIAGRID_TOKEN}"}

        # POST request to Diagrid Catalyst API
        response = requests.post(url, headers=headers, json=service_data)
        response.raise_for_status()

        logging.info(f"Provisioning request submitted: {response.json()}")

        # Generic notification flash message
        flash("Your resource provisioning request has been submitted. You will receive output (endpoints, IP addresses, config files information, etc) with further instructions shortly.")

        # Redirect to the home page
        return redirect("/")

    except requests.exceptions.RequestException as e:
        logging.error(f"Error submitting provisioning request: {e}")
        return "Failed to submit provisioning request. Please try again later.", 500

if __name__ == "__main__":
    app.run(debug=True)