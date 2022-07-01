// Parameters
@description('Specifies the name of the virtual network.')
param virtualNetworkName string

@description('Specifies the address prefixes of the virtual network.')
param virtualNetworkAddressPrefixes string

@description('Specifies the name of the subnet hosting the worker nodes of the AKS cluster.')
param frontendSubnetName string = 'FrontendSubnet'

@description('Specifies the address prefix of the subnet hosting the worker nodes of the AKS cluster.')
param frontendSubnetAddressPrefix string

@description('Specifies the name of the subnet which contains the virtual machine.')
param backendSubnetName string = 'BackendSubnet'

@description('Specifies the address prefix of the subnet which contains the virtual machine.')
param backendSubnetAddressPrefix string

@description('Enable or Disable apply network policies on private end point in the subnet.')
@allowed([
  'Disabled'
  'Enabled'
])
param backendSubnetPrivateEndpointNetworkPolicies string = 'Enabled'

@description('Enable or Disable apply network policies on private link client in the subnet.')
@allowed([
  'Disabled'
  'Enabled'
])
param backendSubnetPrivateLinkServiceNetworkPolicies string = 'Disabled'

@description('Enable or Disable apply network policies on private end point in the subnet.')
@allowed([
  'Disabled'
  'Enabled'
])
param frontendSubnetPrivateEndpointNetworkPolicies string = 'Enabled'

@description('Enable or Disable apply network policies on private link client in the subnet.')
@allowed([
  'Disabled'
  'Enabled'
])
param frontendSubnetPrivateLinkServiceNetworkPolicies string = 'Disabled'

@description('Specifies the name of the network security group associated to the subnet hosting the virtual machine.')
param backendSubnetNsgName string = ''

@description('Specifies the Bastion subnet IP prefix. This prefix must be within vnet IP prefix address space.')
param bastionSubnetAddressPrefix string

@description('Specifies the name of the network security group associated to the subnet hosting Azure Bastion.')
param bastionSubnetNsgName string = ''

@description('Specifies the name of the Azure Bastion resource.')
param bastionHostName string

@description('Enable/Disable Copy/Paste feature of the Bastion Host resource.')
param bastionHostDisableCopyPaste bool = false

@description('Enable/Disable File Copy feature of the Bastion Host resource.')
param bastionHostEnableFileCopy bool = false

@description('Enable/Disable IP Connect feature of the Bastion Host resource.')
param bastionHostEnableIpConnect bool = false

@description('Enable/Disable Shareable Link of the Bastion Host resource.')
param bastionHostEnableShareableLink bool = false

@description('Enable/Disable Tunneling feature of the Bastion Host resource.')
param bastionHostEnableTunneling bool = false

@description('Specifies the name of the NAT Gateway')
param natGatewayName string = ''

@description('Specifies the resource id of the Log Analytics workspace.')
param workspaceId string

@description('Specifies the workspace data retention in days.')
param retentionInDays int = 60

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the resource tags.')
param tags object

// Variables
var diagnosticSettingsName = 'diagnosticSettings'
var nsgLogCategories = [
  'NetworkSecurityGroupEvent'
  'NetworkSecurityGroupRuleCounter'
]
var nsgLogs = [for category in nsgLogCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: retentionInDays
  }
}]
var vnetLogCategories = [
  'VMProtectionAlerts'
]
var vnetMetricCategories = [
  'AllMetrics'
]
var vnetLogs = [for category in vnetLogCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: retentionInDays
  }
}]
var vnetMetrics = [for category in vnetMetricCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: retentionInDays
  }
}]
var bastionLogCategories = [
  'BastionAuditLogs'
]
var bastionMetricCategories = [
  'AllMetrics'
]
var bastionLogs = [for category in bastionLogCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: retentionInDays
  }
}]
var bastionMetrics = [for category in bastionMetricCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: retentionInDays
  }
}]
var bastionSubnetName = 'AzureBastionSubnet'
var bastionPublicIpAddressName = '${bastionHostName}PublicIp'

// Resources

// Network Security Groups
resource bastionSubnetNsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = if (!empty(bastionSubnetNsgName)) {
  name: bastionSubnetNsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowGatewayManagerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowLoadBalancerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowSshRdpOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowAzureCloudCommunicationOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowGetSessionInformationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRanges: [
            '80'
            '443'
          ]
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyAllOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource backendSubnetNsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = if (!empty(backendSubnetNsgName)) {
  name: backendSubnetNsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowSshInbound'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '22'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowHttpInbound'
        properties: {
          priority: 200
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '80'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// NAT Gateway
resource publicIp 'Microsoft.Network/publicIPAddresses@2021-05-01' = if (!empty(natGatewayName)) {
  name: '${natGatewayName}PublicIp'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

resource natGateway 'Microsoft.Network/natGateways@2021-08-01' = if (!empty(natGatewayName)){
  name: !empty(natGatewayName) ? natGatewayName : 'placeholder'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: empty(natGatewayName) ? [] : [
      {
        id: publicIp.id
      }
    ]
  }
}

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefixes
      ]
    }
    subnets: [
      {
        name: frontendSubnetName
        properties: {
          addressPrefix: frontendSubnetAddressPrefix
          privateEndpointNetworkPolicies: frontendSubnetPrivateEndpointNetworkPolicies
          privateLinkServiceNetworkPolicies: frontendSubnetPrivateLinkServiceNetworkPolicies
        }
      }
      {
        name: backendSubnetName
        properties: {
          addressPrefix: backendSubnetAddressPrefix
          networkSecurityGroup: !empty(backendSubnetNsgName) ? {
            id:  backendSubnetNsg.id
          } : json('null')
          natGateway:  !empty(natGatewayName) ? {
            id: natGateway.id
          } : json('null')
          privateEndpointNetworkPolicies: backendSubnetPrivateEndpointNetworkPolicies
          privateLinkServiceNetworkPolicies: backendSubnetPrivateLinkServiceNetworkPolicies
        }
      }
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetAddressPrefix
          networkSecurityGroup: !empty(bastionSubnetNsgName) ? {
            id:  bastionSubnetNsg.id
          } : json('null')
        }
      }
    ]
  }
}

// Azure Bastion Host
resource bastionPublicIpAddress 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: bastionPublicIpAddressName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2021-08-01' = {
  name: bastionHostName
  location: location
  tags: tags
  properties: {
    disableCopyPaste: bastionHostDisableCopyPaste
    enableFileCopy: bastionHostEnableFileCopy
    enableIpConnect: bastionHostEnableIpConnect
    enableShareableLink: bastionHostEnableShareableLink
    enableTunneling: bastionHostEnableTunneling
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/${bastionSubnetName}'
          }
          publicIPAddress: {
            id: bastionPublicIpAddress.id
          }
        }
      }
    ]
  }
}

// Diagnostic Settings
resource backendSubnetNsgDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: backendSubnetNsg
  properties: {
    workspaceId: workspaceId
    logs: nsgLogs
  }
}

resource bastionSubnetNsgDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: bastionSubnetNsg
  properties: {
    workspaceId: workspaceId
    logs: nsgLogs
  }
}

resource vnetDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: vnet
  properties: {
    workspaceId: workspaceId
    logs: vnetLogs
    metrics: vnetMetrics
  }
}

resource bastionDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: bastionHost
  properties: {
    workspaceId: workspaceId
    logs: bastionLogs
    metrics: bastionMetrics
  }
}

// Outputs
output virtualNetworkId string = vnet.id
output virtualNetworkName string = vnet.name
output frontendSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, frontendSubnetName)
output backendSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, backendSubnetName)
output bastionSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, bastionSubnetName)
output frontendSubnetName string = frontendSubnetName
output backendSubnetName string = backendSubnetName
output bastionSubnetName string = bastionSubnetName
