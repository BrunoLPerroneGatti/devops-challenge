The goal of this challenge was to automatically deploy changes to the cloud whenever they are pushed or merged into the `main` branch.

This removes the need to manually build the Docker image, push it to the registry, connect to the server, and deploy the updated application after every change.

---
# CI Workflow

The workflow created in challenge 3 was changed into a reusable GitHub actions workflow.

It is no longer triggered automatically when code is pushed to the main branch, just for pushes to other branches and on pull request into main, allowing changes to be tested during development.

The workflow continues to perform the same validation steps:
1. Checks out the repository.    
2. Sets up the Python environment.    
3. Install the project dependencies.    
4. Executes the automated test using Pytest.    

The new CD workflow calls this reusable CI workflow before proceeding with the deployment.

---
# CD workflow

A new workflow was created for automated deployment and it is triggered when:
- Code is pushed to the main branch.    
- Using the `workflow_dispatch` button.    

It consist of three stages that are connected using GitHub Actions job dependencies, so a deployment cannot start if the previous stage fails.

### 1. Run CI tests

The first job reuses the existing CI workflow:

```yaml
test:
  uses: ./.github/workflows/ci.yaml
```

This allows the same test process to be used by both the normal development workflow and the deployment pipeline without duplicating the CI configuration.

### 2. Build and push the Docker image

After the tests pass, GitHub actions builds the application's Docker image and pushes it to gitHub container registry.

The workflow authenticates to GHCR using the automatically provided `GITHUB_TOKEN`.
The image is then built and pushed into the container registry.

### 3. Deploy to EC2

Once the Docker image has been successfully published, the deployment job runs, doing the following tasks:
1. Checks out the repository.    
2. Configures the SSH private key, which itself is stored as a **GitHub actions secret** rather than being committed to the repository.   
3. Installs Ansible.    
4. Executes the existing Ansible deployment playbook.    

Ansible connects to the EC2 instance, where Docker compose pulls the newly published application image and updates the running application.

The existing deployment automation from Challenge 6 is therefore reused instead of creating a separate deployment mechanism specifically for GitHub actions.

---
# AWS security group change

Previously, the EC2 security group allowed SSH access only from my local IP address.

For GitHub actions to connect to the EC2 instance through Ansible, the SSH port had to be accessible from the GitHub actions.

For this challenge, the SSH security group rule was changed to allow connections from any IP address.

This is not considered a good production security practice because exposing SSH to the entire internet increases the attack surface.

The change was made for the purposes of this exercise so that GitHub could establish the SSH connection required by Ansible.


