#!/bin/bash

RESOURCE_GROUP="aminesRG"
LOCATION="eastus2"
VNET_NAME="aminesVnet"
CONTAINER_APP_ENV_NAME="aminesContainerAppEnv"
LOGS_WORKSPACE_NAME="aminesLogsWorkspace"

echo "Creating RESOURCE GROUP..."
az group create --name $RESOURCE_GROUP --location $LOCATION
echo "RESOURCE GROUP created successfully"

echo "Creating VNET..."
az network vnet create --resource-group $RESOURCE_GROUP -n $VNET_NAME --address-prefix 10.110.0.0/16
echo "VNET created successfully"

echo "Creating SUBNET..."
az network vnet subnet create -g $RESOURCE_GROUP --vnet-name $VNET_NAME -n controlPlane --address-prefixes "10.110.0.0/21" --delegations Microsoft.App/environments
echo "SUBNET created successfully"

echo "Creating APPS SUBNET..."
az network vnet subnet create -g $RESOURCE_GROUP --vnet-name $VNET_NAME -n Apps --address-prefixes "10.110.8.0/21"
echo "APPS SUBNET created successfully"

echo "Creating VMs SUBNET..."
az network vnet subnet create -g $RESOURCE_GROUP --vnet-name $VNET_NAME -n VMs --address-prefixes "10.110.16.0/22"
echo "VMs SUBNET created successfully"

echo "Creating LOGS WORKSPACE..."
az monitor log-analytics workspace create --resource-group $RESOURCE_GROUP --workspace-name $LOGS_WORKSPACE_NAME --location $LOCATION

export VNET_ID=$(az network vnet show -g $RESOURCE_GROUP -n $VNET_NAME --query id -o tsv)
echo "VNET ID: $VNET_ID"

export CONTROL_PLANE_SUBNET_ID=$(az network vnet subnet show -g $RESOURCE_GROUP --vnet-name $VNET_NAME -n controlPlane --query id -o tsv)
echo "CONTROL PLANE SUBNET ID: $CONTROL_PLANE_SUBNET_ID"

export APPS_SUBNET_ID=$(az network vnet subnet show -g $RESOURCE_GROUP --vnet-name $VNET_NAME -n Apps --query id -o tsv)
echo "APPS SUBNET ID: $APPS_SUBNET_ID"

export VMS_SUBNET_ID=$(az network vnet subnet show -g $RESOURCE_GROUP --vnet-name $VNET_NAME -n VMs --query id -o tsv)
echo "VMS SUBNET ID: $VMS_SUBNET_ID"

export LOGS_WORKSPACE_ID=$(az monitor log-analytics workspace show --resource-group $RESOURCE_GROUP --workspace-name $LOGS_WORKSPACE_NAME --query customerId -o tsv)
echo "LOGS WORKSPACE ID: $LOGS_WORKSPACE_ID"
export LOGS_WORKSPACE_KEY=$(az monitor log-analytics workspace get-shared-keys --resource-group $RESOURCE_GROUP --workspace-name $LOGS_WORKSPACE_NAME --query primarySharedKey -o tsv)
echo "LOGS WORKSPACE KEY: $LOGS_WORKSPACE_KEY"

az containerapp env create -n $CONTAINER_APP_ENV_NAME -g $RESOURCE_GROUP --internal-only --infrastructure-subnet-resource-id $CONTROL_PLANE_SUBNET_ID --logs-workspace-id $LOGS_WORKSPACE_ID --logs-workspace-key $LOGS_WORKSPACE_KEY --location $LOCATION
echo "CONTAINER APPS ENV created successfully"

export CA_ENV_DEFAULT_DOMAIN=$(az containerapp env show -n $CONTAINER_APP_ENV_NAME -g $RESOURCE_GROUP --query properties.defaultDomain -o tsv)
echo "CA ENV DEFAULT DOMAIN: $CA_ENV_DEFAULT_DOMAIN"

export CA_ENV_STATIC_IP=$(az containerapp env show -n $CONTAINER_APP_ENV_NAME -g $RESOURCE_GROUP --query properties.staticIp -o tsv)
echo "CA ENV STATIC IP: $CA_ENV_STATIC_IP"

echo "Creating Private DNS zone..."
az network private-dns zone create --resource-group $RESOURCE_GROUP --name $CA_ENV_DEFAULT_DOMAIN
echo "Private DNS zone created successfully"

echo "Linking VNET to Private DNS zone..."
az network private-dns link vnet create --resource-group $RESOURCE_GROUP --virtual-network $VNET_ID --zone-name $CA_ENV_DEFAULT_DOMAIN -n $CA_ENV_DEFAULT_DOMAIN -e true
echo "VNET linked to Private DNS zone successfully"

echo "Creating A record in Private DNS zone..."
az network private-dns record-set a add-record --resource-group $RESOURCE_GROUP --zone-name $CA_ENV_DEFAULT_DOMAIN --record-set-name "*" --ipv4-address $CA_ENV_STATIC_IP
echo "A record created in Private DNS zone successfully"

export CA_ENV_DEFAULT_DOMAIN = $(az containerapp env show -n $CONTAINER_APP_ENV_NAME -g $RESOURCE_GROUP --query properties.defaultDomain -o tsv)