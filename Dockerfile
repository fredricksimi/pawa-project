# Using a lightweight python image from Dockerhub
FROM python:3.13-alpine

#Defining the working directory inside the container
WORKDIR /app

# Copying the requirements file that lists our dependencies for our project
COPY requirements.txt .
# Run the pip install command to install our dependencies
RUN pip install -r requirements.txt

# Copying the files of our project i.e 'app.py' into our working directory
COPY . .

# Setting the FLASK_APP environment variable
ENV FLASK_APP=app.py

# Here we expose port 500 for that we access our app outside the contianer enviroment
EXPOSE 5000

# We define the command to run our app and make it reachable
CMD ["flask", "run", "--host=0.0.0.0"]