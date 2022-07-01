// Parameters
@description('Specifies the name prefix.')
param prefix string = '$uniqueString(resourceGroup().id)'

@description('Specifies the location of AKS cluster.')
param location string = resourceGroup().location

@description('Specifies the name of the service virtual network.')
param serviceVirtualNetworkName string = '${prefix}ServiceVnet'

@description('Specifies the address prefixes of the service virtual network.')
param serviceVirtualNetworkAddressPrefixes string = '10.0.0.0/16'

@description('Specifies the name of the frontend subnet hosting the Azure Private Link Service.')
param serviceFrontendSubnetName string = 'FrontendSubnet'

@description('Specifies the address prefix of the subnet hosting the Azure Private Link Service.')
param serviceFrontendSubnetAddressPrefix string = '10.0.0.0/24'

@description('Enable or Disable apply network policies on private end point in the subnet.')
@allowed([
  'Disabled'
  'Enabled'
])
param serviceFrontendSubnetPrivateEndpointNetworkPolicies string = 'Enabled'

@description('Enable or Disable apply network policies on private link service in the subnet.')
@allowed([
  'Disabled'
  'Enabled'
])
param serviceFrontendSubnetPrivateLinkServiceNetworkPolicies string = 'Disabled'

@description('Specifies the name of the subnet hosting the backend service virtual machine.')
param serviceBackendSubnetName string = 'BackendSubnet'

@description('Specifies the address prefix of the subnet which contains the backend service virtual machine.')
param serviceBackendSubnetAddressPrefix string = '10.0.1.0/24'

@description('Enable or Disable apply network policies on private end point in the subnet.')
@allowed([
  'Disabled'
  'Enabled'
])
param serviceBackendSubnetPrivateEndpointNetworkPolicies string = 'Disabled'

@description('Enable or Disable apply network policies on private link service in the subnet.')
@allowed([
  'Disabled'
  'Enabled'
])
param serviceBackendSubnetPrivateLinkServiceNetworkPolicies string = 'Enabled'

@description('Specifies the name of the bastion host in the service virtual network.')
param serviceBastionHostName string = '${prefix}ServiceBastionHost'

@description('Specifies the Bastion subnet IP prefix. This prefix must be within vnet IP prefix address space.')
param serviceBastionSubnetAddressPrefix string = '10.0.2.0/24'

@description('Specifies the name of the client virtual network.')
param clientVirtualNetworkName string = '${prefix}ClientVnet'

@description('Specifies the address prefixes of the client virtual network.')
param clientVirtualNetworkAddressPrefixes string = '10.1.0.0/16'

@description('Specifies the name of the frontend subnet hosting the client virtual machine and Azure Private Endpoint.')
param clientFrontendSubnetName string = 'FrontendSubnet'

@description('Specifies the address prefix of the subnet hosting the client virtual machine and Azure Private Endpoint.')
param clientFrontendSubnetAddressPrefix string = '10.1.0.0/24'

@description('Enable or Disable apply network policies on private end point in the subnet.')
@allowed([
  'Disabled'
  'Enabled'
])
param clientFrontendSubnetPrivateEndpointNetworkPolicies string = 'Disabled'

@description('Enable or Disable apply network policies on private link client in the subnet.')
@allowed([
  'Disabled'
  'Enabled'
])
param clientFrontendSubnetPrivateLinkServiceNetworkPolicies string = 'Enabled'

@description('Specifies the name of the backend subnet in the client virtual network.')
param clientBackendSubnetName string = 'BackendSubnet'

@description('Specifies the address prefix of the backend subnet in the client virtual network.')
param clientBackendSubnetAddressPrefix string = '10.1.1.0/24'

@description('Enable or Disable apply network policies on private end point in the subnet.')
@allowed([
  'Disabled'
  'Enabled'
])
param clientBackendSubnetPrivateEndpointNetworkPolicies string = 'Disabled'

@description('Enable or Disable apply network policies on private link client in the subnet.')
@allowed([
  'Disabled'
  'Enabled'
])
param clientBackendSubnetPrivateLinkServiceNetworkPolicies string = 'Enabled'

@description('Specifies the name of the bastion host in the client virtual network.')
param clientBastionHostName string = '${prefix}ClientBastionHost'

@description('Specifies the Bastion subnet IP prefix. This prefix must be within vnet IP prefix address space.')
param clientBastionSubnetAddressPrefix string = '10.1.2.0/24'

@description('Specifies the name of the service Log Analytics Workspace.')
param serviceLogAnalyticsWorkspaceName string = '${prefix}ServiceWorkspace'

@description('Specifies the name of the service Log Analytics Workspace.')
param clientLogAnalyticsWorkspaceName string = '${prefix}ClientWorkspace'

@description('Specifies the service tier of the workspace: Free, Standalone, PerNode, Per-GB.')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param logAnalyticsSku string = 'PerNode'

@description('Specifies the workspace data retention in days. -1 means Unlimited retention for the Unlimited Sku. 730 days is the maximum allowed for all other Skus.')
param logAnalyticsRetentionInDays int = 60

@description('Specifies the name of the backend service virtual machine.')
param serviceVmName string = '${prefix}ServiceVm'

@description('Specifies the size of the backend service virtual machine.')
param serviceVmSize string = 'Standard_DS3_v2'

@description('Specifies the name of the backend client virtual machine.')
param clientVmName string = '${prefix}ClientVm'

@description('Specifies the size of the backend client virtual machine.')
param clientVmSize string = 'Standard_DS3_v2'

@description('Specifies the image publisher of the disk image used to create the virtual machine.')
param imagePublisher string = 'Canonical'

@description('Specifies the offer of the platform image or marketplace image used to create the virtual machine.')
param imageOffer string = 'UbuntuServer'

@description('Specifies the Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.')
param imageSku string = '18.04-LTS'

@description('Specifies the type of authentication when accessing the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'

@description('Specifies the name of the administrator account of the virtual machine.')
param vmAdminUsername string = 'azadmin'

@description('Specifies the SSH Key or password for the virtual machine. SSH key is recommended.')
@secure()
param vmAdminPasswordOrKey string

@description('Specifies the storage account type for OS and data disk.')
@allowed([
  'Premium_LRS'
  'StandardSSD_LRS'
  'Standard_LRS'
  'UltraSSD_LRS'
])
param diskStorageAccountType string = 'Premium_LRS'

@description('Specifies the number of data disks of the virtual machine.')
@minValue(0)
@maxValue(64)
param numDataDisks int = 1

@description('Specifies the size in GB of the OS disk of the VM.')
param osDiskSize int = 50

@description('Specifies the size in GB of the OS disk of the virtual machine.')
param dataDiskSize int = 50

@description('Specifies the caching requirements for the data disks.')
param dataDiskCaching string = 'ReadWrite'

@description('Specifies the globally unique name for the service storage account used to store the boot diagnostics logs of the virtual machine.')
param serviceBlobStorageAccountName string = 'serverboot${uniqueString(resourceGroup().id)}'

@description('Specifies the globally unique name for the client storage account used to store the boot diagnostics logs of the virtual machine.')
param clientBlobStorageAccountName string = 'clientboot${uniqueString(resourceGroup().id)}'

@description('Specifies the relative path of the scripts used to initialize the virtual machine.')
param scriptFilePath string = 'https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/'

@description('Specifies the script to download from the URI specified by the scriptFilePath parameter.')
param scriptFileName string = 'automate_nginx.sh'

@description('Specifies the resource tags.')
param tags object = {
  IaC: 'Bicep'
}

@description('Specifies the name of the load balancer')
param loadBalancerName string = '${prefix}LoadBalancer'

@description('Specifies the sku of the load balancer')
param loadBalancerSkuName string = 'Standard'

@description('Specifies the name of the resource that is unique within the set of frontend IP configurations used by the load balancer. This name can be used to access the resource.')
param loadBalancerFrontEndIpConfigurationName string = 'FrontendIp'

@description('Specifies the name of the resource that is unique within the set of backend address pools used by the load balancer. This name can be used to access the resource.')
param loadBalancerBackendPoolName string = 'BackendPool'

@description('Specifies the name of the inbound NAT rule.')
param loadBalancerInboundNatRuleName string = 'SSH'

@description('Specifies the protocol of the inbound NAT rule.')
param loadBalancerInboundNatRuleProtocol string = 'Tcp'

@description('Specifies the frontend port of the inbound NAT rule.')
param loadBalancerInboundNatRuleFrontendPort int = 22

@description('Specifies the backend port of the inbound NAT rule.')
param loadBalancerInboundNatRuleBackendPort int = 22

@description('Specifies the name of the load balancing rule.')
param loadBalancingRuleName string = 'Http'

@description('Specifies the protocol of the load balancing rule.')
param loadBalancingRuleProtocol string = 'Tcp'

@description('Specifies the frontend port of the load balancing rule.')
param loadBalancingRuleFrontendPort int = 80

@description('Specifies the backend port of the load balancing rule.')
param loadBalancingRuleBackendPort int = 80

@description('Specifies the idle timeout in minutes of the load balancing rule.')
param loadBalancingRuleidleTimeoutInMinutes int = 15

@description('Specifies the name of the resource that is unique within the set of probes used by the load balancer. This name can be used to access the resource.')
param loadBalancerHealthProbeName string = 'HealthProbe'

@description('Specifies the protocol of the endpoint. If Tcp is specified, a received ACK is required for the probe to be successful. If Http or Https is specified, a 200 OK response from the specifies URI is required for the probe to be successful.')
@allowed([
  'Http'
  'Https'
  'Tcp'
])
param loadBalancerHealthProbeProtocol string = 'Tcp'

@description('Specifies the port for communicating the probe. Possible values range from 1 to 65535, inclusive.')
param loadBalancerHealthProbePort int = 80

@description('Specifies the interval, in seconds, for how frequently to probe the endpoint for health status. Typically, the interval is slightly less than half the allocated timeout period (in seconds) which allows two full probes before taking the instance out of rotation. The default value is 15, the minimum value is 5.')
param loadBalancerHealthProbeIntervalInSeconds int = 15

@description('Specifies the number of probes where if no response, will result in stopping further traffic from being delivered to the endpoint. This values allows endpoints to be taken out of rotation faster or slower than the typical times used in Azure..')
param loadBalancerHealthProbeNumberOfProbes int = 2

@description('Specifies the name of the Azure Private Link Service.')
param privateLinkServiceName string = '${prefix}PrivateLinkService'

@description('Specifies the name of the Azure Private Endpoint to the Azure Private Link Service.')
param privateLinkServicePrivateEndpointName string = '${prefix}PrivateLinkServicePrivateEndpoint'

// Modules

//****************************
//* Service Provider Modules *
//****************************

module serviceWorkspace 'logAnalytics.bicep' = {
  name: 'serviceWorkspace'
  params: {
    name: serviceLogAnalyticsWorkspaceName
    location: location
    sku: logAnalyticsSku
    retentionInDays: logAnalyticsRetentionInDays
    tags: tags
  }
}

module serviceStorageAccount 'storageAccount.bicep' = {
  name: 'serviceStorageAccount'
  params: {
    name: serviceBlobStorageAccountName
    createContainers: true
    containerNames: [
      'todoapi'
      'todoweb'
    ]
    workspaceId: serviceWorkspace.outputs.id
    retentionInDays: logAnalyticsRetentionInDays
    location: location
    tags: tags
  }
}

module serviceVirtualNetwork 'network.bicep' = {
  name: 'serviceNetwork'
  params: {
    virtualNetworkName: serviceVirtualNetworkName
    virtualNetworkAddressPrefixes: serviceVirtualNetworkAddressPrefixes
    frontendSubnetName: serviceFrontendSubnetName
    frontendSubnetAddressPrefix: serviceFrontendSubnetAddressPrefix
    frontendSubnetPrivateEndpointNetworkPolicies: serviceFrontendSubnetPrivateEndpointNetworkPolicies
    frontendSubnetPrivateLinkServiceNetworkPolicies: serviceFrontendSubnetPrivateLinkServiceNetworkPolicies
    backendSubnetName: serviceBackendSubnetName
    backendSubnetAddressPrefix: serviceBackendSubnetAddressPrefix
    backendSubnetPrivateEndpointNetworkPolicies: serviceBackendSubnetPrivateEndpointNetworkPolicies
    backendSubnetPrivateLinkServiceNetworkPolicies: serviceBackendSubnetPrivateLinkServiceNetworkPolicies
    bastionSubnetAddressPrefix: serviceBastionSubnetAddressPrefix
    backendSubnetNsgName: '${prefix}Service${serviceBackendSubnetName}Nsg'
    bastionSubnetNsgName: '${prefix}ServiceAzureBastionSubnetNsg'
    bastionHostName: serviceBastionHostName
    natGatewayName: '${prefix}ServiceNatGateway'
    workspaceId: serviceWorkspace.outputs.id
    retentionInDays: logAnalyticsRetentionInDays
    location: location
    tags: tags
  }
}

module loadBalancer 'loadBalancers.bicep' = {
  name: 'loadBalancer'
  params: {
    name: loadBalancerName
    skuName: loadBalancerSkuName
    frontEndIpConfigurationName: loadBalancerFrontEndIpConfigurationName
    backendPoolName: loadBalancerBackendPoolName
    healthProbeName: loadBalancerHealthProbeName
    healthProbeProtocol: loadBalancerHealthProbeProtocol
    healthProbeNumberOfProbes: loadBalancerHealthProbeNumberOfProbes
    healthProbeIntervalInSeconds: loadBalancerHealthProbeIntervalInSeconds
    healthProbePort: loadBalancerHealthProbePort
    inboundNatRuleName: loadBalancerInboundNatRuleName
    inboundNatRuleProtocol: loadBalancerInboundNatRuleProtocol
    inboundNatRuleFrontendPort: loadBalancerInboundNatRuleFrontendPort
    inboundNatRuleBackendPort: loadBalancerInboundNatRuleBackendPort
    loadBalancingRuleName: loadBalancingRuleName
    loadBalancingRuleProtocol: loadBalancingRuleProtocol
    loadBalancingRuleFrontendPort: loadBalancingRuleFrontendPort
    loadBalancingRuleBackendPort: loadBalancingRuleBackendPort
    loadBalancingRuleidleTimeoutInMinutes: loadBalancingRuleidleTimeoutInMinutes
    virtualNetworkName: serviceVirtualNetwork.outputs.virtualNetworkName
    subnetName: serviceVirtualNetwork.outputs.frontendSubnetName
    workspaceId: serviceWorkspace.outputs.id
    retentionInDays: logAnalyticsRetentionInDays
    location: location
    tags: tags
  }
}

module serviceVirtualMachine 'virtualMachine.bicep' = {
  name: 'serviceVirtualMachine'
  params: {
    vmName: serviceVmName
    vmSize: serviceVmSize
    vmSubnetId: serviceVirtualNetwork.outputs.backendSubnetId
    storageAccountName: serviceStorageAccount.outputs.name
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSku: imageSku
    authenticationType: authenticationType
    vmAdminUsername: vmAdminUsername
    vmAdminPasswordOrKey: vmAdminPasswordOrKey
    loadBalancerName: loadBalancer.outputs.name
    diskStorageAccountType: diskStorageAccountType
    numDataDisks: numDataDisks
    osDiskSize: osDiskSize
    dataDiskSize: dataDiskSize
    dataDiskCaching: dataDiskCaching
    scriptFilePath: scriptFilePath
    scriptFileName: scriptFileName
    workspaceName: serviceWorkspace.outputs.name
    location: location
    tags: tags
  }
}

module privateLinkService 'privateLinkService.bicep' = {
  name: 'privateLinkService'
  params: {
    loadBalancerName: loadBalancer.outputs.name
    privateEndpointName: privateLinkServicePrivateEndpointName
    privatelinkServiceName: privateLinkServiceName
    virtualNetworkName: clientVirtualNetwork.outputs.virtualNetworkName
    subnetName: clientVirtualNetwork.outputs.frontendSubnetName
    location: location
    tags: tags
  }
}

//****************************
//* Service Consumer Modules *
//****************************
module clientWorkspace 'logAnalytics.bicep' = {
  name: 'clientWorkspace'
  params: {
    name: clientLogAnalyticsWorkspaceName
    location: location
    sku: logAnalyticsSku
    retentionInDays: logAnalyticsRetentionInDays
    tags: tags
  }
}

module clientStorageAccount 'storageAccount.bicep' = {
  name: 'clientStorageAccount'
  params: {
    name: clientBlobStorageAccountName
    createContainers: true
    containerNames: [
      'todoapi'
      'todoweb'
    ]
    workspaceId: clientWorkspace.outputs.id
    retentionInDays: logAnalyticsRetentionInDays
    location: location
    tags: tags
  }
}

module clientVirtualNetwork 'network.bicep' = {
  name: 'clientNetwork'
  params: {
    virtualNetworkName: clientVirtualNetworkName
    virtualNetworkAddressPrefixes: clientVirtualNetworkAddressPrefixes
    frontendSubnetName: clientFrontendSubnetName
    frontendSubnetAddressPrefix: clientFrontendSubnetAddressPrefix
    frontendSubnetPrivateEndpointNetworkPolicies: clientFrontendSubnetPrivateEndpointNetworkPolicies
    frontendSubnetPrivateLinkServiceNetworkPolicies: clientFrontendSubnetPrivateLinkServiceNetworkPolicies
    backendSubnetName: clientBackendSubnetName
    backendSubnetAddressPrefix: clientBackendSubnetAddressPrefix
    backendSubnetPrivateEndpointNetworkPolicies: clientBackendSubnetPrivateEndpointNetworkPolicies
    backendSubnetPrivateLinkServiceNetworkPolicies: clientBackendSubnetPrivateLinkServiceNetworkPolicies
    bastionSubnetAddressPrefix: clientBastionSubnetAddressPrefix
    backendSubnetNsgName: '${prefix}Client${clientBackendSubnetName}Nsg'
    bastionSubnetNsgName: '${prefix}ClientAzureBastionSubnetNsg'
    bastionHostName: clientBastionHostName
    workspaceId: clientWorkspace.outputs.id
    retentionInDays: logAnalyticsRetentionInDays
    location: location
    tags: tags
  }
}

module clientVirtualMachine 'virtualMachine.bicep' = {
  name: 'clientVirtualMachine'
  params: {
    vmName: clientVmName
    vmSize: clientVmSize
    vmSubnetId: clientVirtualNetwork.outputs.backendSubnetId
    storageAccountName: clientStorageAccount.outputs.name
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSku: imageSku
    authenticationType: authenticationType
    vmAdminUsername: vmAdminUsername
    vmAdminPasswordOrKey: vmAdminPasswordOrKey
    diskStorageAccountType: diskStorageAccountType
    numDataDisks: numDataDisks
    osDiskSize: osDiskSize
    dataDiskSize: dataDiskSize
    dataDiskCaching: dataDiskCaching
    workspaceName: clientWorkspace.outputs.name
    location: location
    tags: tags
  }
}
