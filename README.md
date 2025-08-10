# Deployment of Cloud Run service using Cloud Build and Terraform

## Architecture Overview
This project uses a CI/CD pipeline to deploy a serverless Flask application to GCP using Cloud Build and Terraform. The system provisions all the necessary infrastructure, including a private Cloud Run service, an Artifact Registry repository, and a Serverless VPC Access network connector.

The entire process is automated: a simple code push to your GitHub repository triggers a build, test, and deployment of your application to GCP.

The following GCP Services have been used:
- VPC Networks
- Cloud Build
- Cloud Run
- Cloud IAM
- Serverless VPC Access
- Compute Engine
- Cloud Storage - For storing Cloud Build Logs written by Cloud Build process
- Artifact Registry
- Secret Manager - For storing our gcp service account info

## Deisgn Decisions
I decided to use Cloud Run for a number of reasons:
- It is serverless and cost effective. This means that it can scale down to zero when it is not in use. So you only get to pay for when the service gets executed
- It is a fully managed service in that you don't need to worry about the underlying infrastructure at all
-  It has security by default. Especially with the internal only traffic during its setup. This means the only way to access it through the VPC is by using Serverless VPC Access

In terms of security, I have used Serverless VPC Access connector, this makes the Cloud Run service only reachable via internal traffic. This makes our service secure
I have also not included any secrets in the `cloudbuild.yaml` file. I used **Secret Manager** for this. I provided the Cloud Build service account the necessary permissions to access the necessary credentials to perform its services

**How the CI/CD Pipeline works**
1. Testing: The dependencies needed are installed and unit tests are run. If the tests fail, the build process stops
2. Terraform IaC: I used Terraform to manage all the infrastructure. The pipeline uses a targeted `terraform apply` to first create the repositry where our docker image will be stored before proceeding with the pipeline
3. Docker build and push: With the repository in place, the pipeline builds and pushes the docker image to the Artifact Registry repo
4. Full deployment: This final step is the one that runs the complete `terraform apply`, deploying the rest of the infrastructure like Cloud Run service, VPC Access connector, enabling APIs etc. It also uses the docker image that was built in the previous steps, completing the deployment.

**Note** - The terraform state is stored and checked from a storage bucket that is used as a backend by terraform during the Cloud Build process

## System Architecture Diagram
![GCP Architecture Diagram](/Architecture_Diagram.png)


## Prerequisites and Setup
Before you begin, you need to set up the following:

1. GCP Resources:
    - Create a new Google Cloud Project.
    - Create a VPC Network.
    - **Note down the GCP Project ID, the subnet region, and zone you will deploy your resources to.**

2. Service Account:
    - Create a service account with the following permissions: 
        - `Artifact Registry Administrator`
        - `Artifact Registry Repository Administrator`
        - `Cloud Run Developer`
        - `Compute Network Admin`
        - `Logs Writer`
        - `Secret Manager Secret Accessor`
        - `Serverless VPC Access Admin`
        - `Service Account User`
        - `Service Usage Admin`
        - `Storage Admin`

    - **Download the service account key file in JSON format.**

3. Secret Manager:
    - Create a secret in Google Cloud Secret Manager and upload the content of the service account JSON file.
    - **Note down the Secret Name.**

4. GCS Bucket:
    - Create a Google Cloud Storage bucket that Terraform will use to store its state file.

    - **Note down the Storage Bucket Name.**

5. Artifact Registry:

    - Come up with a name for your Artifact Registry repository.

    - **Note down the Repository Name.**

6. GitHub & Cloud Build Trigger

    This section guides you through setting up the connection between your GitHub repository and Cloud Build.

    **Create a GitHub repository on GitHub.**

    - Create a Personal Access Token (classic) with appropriate scopes for Cloud Build to access your repository. You can follow the instructions [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic).

    - Install the Google Cloud Build GitHub app using this [link](https://github.com/apps/google-cloud-build).

    - In the Google Cloud Console, navigate to **Cloud Build** > **Triggers**

    - Select **Connect repository**.

    - Under **Region**, select the region you noted down.

    - After the **Authentication** section, select the repository you want to connect.

    - Create the trigger with the following settings:

        - Give it a unique Name.

        - Select the **Region** you noted.

        - Set the **Event** type to **Push to a branch**.

        - Confirm the correct repository has been selected and provide your branch of choice (e.g., main).

        - Under **Configuration**, select **Cloud Build configuration file (yaml or json)**.

        - Confirm the Cloud Build configuration file location is `/ cloudbuild.yaml`

        - Under **Service account**, select the service account you created.

        - Hit the **Create** button.

7. Local Repository Configuration
    - Clone this repository to your local machine.

    - In the repository, create a `variables.tf` file with the following content and replace the placeholder values with the information you have been noting down:

        - `variable "gcp_project_id" { type = string, default="YOUR-VALUE-HERE" }`
        - `variable "gcp_region" { type = string default="YOUR-VALUE-HERE" }`
        - `variable "gcp_zone" { type = string default="YOUR-VALUE-HERE" }`
        - `variable "terraform_state_bucket" { type = string default="YOUR-VALUE-HERE" }`
        - `variable "repo_name" { type = string default="YOUR-VALUE-HERE" }`
        - `variable "gcp_vpc_network" { type = string default="YOUR-VALUE-HERE" }`
        - `variable "gcp_serverless_vpc_subnet" { type = string default="YOUR-VALUE-HERE" }`
        - `variable "gcp_serverless_machine_type" { type = string default="YOUR-VALUE-HERE" }`
        - `variable "gcp_serverless_min_instances" { type = number default="YOUR-VALUE-HERE" }`
        - `variable "gcp_serverless_max_instances" { type = number default="YOUR-VALUE-HERE" }`

    - Open the cloudbuild.yaml file and update the substitutions section with your values:

    - `substitutions:`
        - `_GCP_REGION: "your-gcp-region"`
        - `_PROJECT_ID: "your-gcp-project-id"`
        - `_REPO_NAME: "your-artifact-registry-name"`
        - `_DOCKER_IMAGE_NAME: "my-app"` # This can stay as-is unless you want to change it
        - `_TERRAFORM_GCP_BACKEND: "your-terraform-state-bucket"`

    - Commit all your changes and push them to the branch you configured the trigger for (e.g., main).

8. Deployment
    - After pushing your changes, the Cloud Build trigger will automatically start the build process. You can monitor the progress in the **Cloud Build** History section of your GCP Console. 
    - The pipeline will:

        - Install dependencies and run unit tests.

        - Create the Artifact Registry repository using Terraform.

        - Build and push the Docker image to the new repository.

        - Deploy the Cloud Run service and the VPC Access Connector.

9. Validation
    - Once the build is successful, you can test your deployed Cloud Run service.

    - In the GCP Console, create a new Virtual Machine instance in the same VPC Network that you configured.

    - During the VM setup, ensure you enable the HTTP and HTTPS traffic in the Networking tab.

    - Once the VM is ready, connect to it via SSH.

    - Run the following commands in the SSH terminal:

        > TOKEN=$(gcloud auth print-identity-token)
        > 
        > curl -H "Authorization: Bearer $TOKEN" -H "Content-type: application/json" -d '{"text": "I love cloud engineering!"}' https://CLOUD-RUN-SERVICE-URL/analyze
        >
        >

10. You should receive a JSON response from your Cloud Run service, confirming that your deployment was successful. Note that you will need to replace the URL in the curl command with the actual URL of your deployed Cloud Run service.