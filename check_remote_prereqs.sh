#!/bin/bash

# Check if Kubernetes is enabled and running in Docker Desktop
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed (Kubernetes might not be enabled in Docker Desktop)"
    exit 1
fi

if ! kubectl cluster-info &> /dev/null; then
    echo "Kubernetes is not running (or kubectl is not configured)"
    exit 1
fi

echo "Checking if keytool is installed"
if ! command -v keytool &> /dev/null; then
    echo "keytool is not installed; try installing a Java runtime (JRE or JDK)"
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
echo "✅ Kubernetes is enabled and accessible"
echo "✅ helm is installed"
echo "✅ openssl is installed"
echo "✅ cfssl is installed"

# Print versions for reference
echo -e "\nKubernetes Versions:"
kubectl version 
echo -e "\nHelm Version:"
helm version