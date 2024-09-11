#!/bin/bash

# Exit on error
set -e

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install necessary dependencies
echo "Installing dependencies..."
sudo apt-get install -y curl apt-transport-https software-properties-common

# Install Prometheus
echo "Installing Prometheus..."
PROMETHEUS_VERSION="2.37.1"  # Replace with the desired version
wget "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
tar xvf "prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
sudo mv "prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus" /usr/local/bin/
sudo mv "prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool" /usr/local/bin/
sudo mkdir -p /etc/prometheus
sudo mv "prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus.yml" /etc/prometheus/prometheus.yml

# Create Prometheus systemd service
echo "Creating Prometheus service..."
sudo bash -c 'cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=nobody
Group=nogroup
ExecStart=/usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml
Restart=on-failure

[Install]
WantedBy=default.target
EOF'

# Start Prometheus
echo "Starting Prometheus..."
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Install Grafana
echo "Installing Grafana..."
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
sudo apt-get update
sudo apt-get install -y grafana

# Start Grafana
echo "Starting Grafana..."
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Installation completed
echo "Prometheus and Grafana have been installed and started successfully."

# Print out the URLs to access Prometheus and Grafana
echo "You can access Prometheus at http://localhost:9090"
echo "You can access Grafana at http://localhost:3000"
