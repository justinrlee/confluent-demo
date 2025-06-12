#!/bin/bash

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "This script is intended to run on macOS only"
    exit 1
fi

# Check if Docker Desktop is installed
if ! command -v docker &> /dev/null; then
    echo "Docker Desktop is not installed"
    exit 1
fi

# Check if Docker Desktop is running
if ! docker info &> /dev/null; then
    echo "Docker Desktop is not running"
    exit 1
fi

# Check if Kubernetes is enabled and running in Docker Desktop
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed (Kubernetes might not be enabled in Docker Desktop)"
    exit 1
fi

echo "Switching to docker-desktop context"
kubectl config use-context docker-desktop

if ! kubectl cluster-info &> /dev/null; then
    echo "Kubernetes is not running"
    exit 1
fi

echo "Checking if helm is installed"
if ! command -v helm &> /dev/null; then
    echo "helm is not installed"
    exit 1
fi

echo "Check if openssl is installed"
if ! command -v openssl &> /dev/null; then
    echo "openssl is not installed"
    exit 1
fi

echo "Check if cfssl is installed"
if ! command -v cfssl &> /dev/null; then
    echo "cfssl is not installed"
    exit 1
fi


# If we get here, everything is working
echo "✅ Docker Desktop is installed and running"
echo "✅ Kubernetes is enabled and running"
echo "✅ helm is installed"
echo "✅ openssl is installed"
echo "✅ cfssl is installed"

# Print versions for reference
echo -e "\nDocker Version:"
docker version --format 'Docker Version: {{.Server.Version}}'
echo -e "\nKubernetes Versions:"
kubectl version 
echo -e "\nHelm Version:"
helm version