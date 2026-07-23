The goal of this challenge was to deploy the application on a real cloud server, accessible via a public hostname that persists across reboots.

---

# Infrastructure

The application runs on a AWS EC2 instance managed with **systemd**, so it starts automatically on boot and restarts on failure.
Security groups where configured to allow SSH access on port 22 with my source IP, and connections with port 8080 from any IP to access the application.

---

# Application
A new endpoint was added in this challenge:

| Method | Endpoint | Description                                                   |
| ------ | -------- | ------------------------------------------------------------- |
| GET    | `/info`  | Returns the hostname, useful to identify the running instance |

This endpoint becomes useful in Challenge 7, where the app runs on multiple instances behind a load balancer and the response identifies which instance handled each request.

The greeting message is configured through the `APP_MESSAGE` environment variable, set in the systemd unit file.

---

# Systemd service

The application is managed by a systemd unit file at `/etc/systemd/system/devops-challenge.service`.

Key settings:
- Starts after the network is available
- Restarts automatically on failure
- Enabled to start on every boot

```ini
[Unit]
Description=DevOps challenge application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/devops-challenge
Environment="PATH=/home/ubuntu/devops-challenge/.venv/bin"
Environment="APP_MESSAGE=hello world from EC2"
ExecStart=/home/ubuntu/devops-challenge/.venv/bin/uvicorn main:app --host 0.0.0.0 --port 8080
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```


---

## Commands executed

```bash
# connect with SSH
ssh -i ~/.ssh/devops-challenge-key.pem ubuntu@INSTANCE-PUBLIC-IP

# install dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-venv git

# clone the github repository
git clone https://github.com/BrunoLPerroneGatti/devops-challenge.git
cd devops-challenge

# set up Python environment
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# after configuring systemd service
sudo systemctl daemon-reload 
sudo systemctl enable devops-challenge 
sudo systemctl start devops-challenge 

# test endpoints
curl http://INSTANCE-PUBLIC-IP:8080/
curl http://INSTANCE-PUBLIC-IP:8080/health
curl http://INSTANCE-PUBLIC-IP:8080/info
```
