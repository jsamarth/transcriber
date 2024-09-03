# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Set the working directory in the container
WORKDIR /app

# Install ffmpeg
RUN apt-get update && apt-get install -y ffmpeg && apt-get clean

# Copy the rest of the application code to the container
COPY . .

# Install packages
RUN pip install .

RUN pip list

# Expose the port that the app will run on
EXPOSE 80

# Run the Uvicorn server using the transcriber package
CMD ["uvicorn", "src.transcriber.main:app", "--host", "0.0.0.0", "--port", "80"]
