# Python base image
FROM python:3.12-alpine

# Setting the working dir
WORKDIR /app

# Exposing the port on which the application will run
EXPOSE 5000

# Copy the requirements file to the working directory
COPY requirements.txt .

# Install the Python dependencies
RUN pip install -r requirements.txt

# Copy the application code to the working directory
COPY . .

ENV PORT 5000

# Run the application
CMD ["python", "app.py"]