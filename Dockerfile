# Python base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt ./

# Install dependencies
RUN pip install -r requirements.txt

# Copy application code
COPY . .

# Expose FastAPI appl
EXPOSE 8000

ENV UVICORN_PORT 8000

# Command to run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0"]