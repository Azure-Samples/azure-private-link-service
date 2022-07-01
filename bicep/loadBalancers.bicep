// Parameters
@description('Specifies the name of the load balancer')
param name string

@description('Specifies the sku of the load balancer')
param skuName string = 'Standard'

@description('Specifies the name of the resource that is unique within the set of frontend IP configurations used by the load balancer. This name can be used to access the resource.')
param frontEndIpConfigurationName string = 'FrontendIp'

@description('Specifies the name of the resource that is unique within the set of backend address pools used by the load balancer. This name can be used to access the resource.')
param backendPoolName string = 'BackendPool'

@description('Specifies the name of the resource that is unique within the set of probes used by the load balancer. This name can be used to access the resource.')
param healthProbeName string = 'HealthProbe'

@description('Specifies the protocol of the endpoint. If Tcp is specified, a received ACK is required for the probe to be successful. If Http or Https is specified, a 200 OK response from the specifies URI is required for the probe to be successful.')
@allowed([
  'Http'
  'Https'
  'Tcp'
])
param healthProbeProtocol string = 'Tcp'

@description('Specifies the port for communicating the probe. Possible values range from 1 to 65535, inclusive.')
param healthProbePort int = 80

@description('Specifies the interval, in seconds, for how frequently to probe the endpoint for health status. Typically, the interval is slightly less than half the allocated timeout period (in seconds) which allows two full probes before taking the instance out of rotation. The default value is 15, the minimum value is 5.')
param healthProbeIntervalInSeconds int = 15

@description('Specifies the number of probes where if no response, will result in stopping further traffic from being delivered to the endpoint. This values allows endpoints to be taken out of rotation faster or slower than the typical times used in Azure..')
param healthProbeNumberOfProbes int = 2

@description('Specifies the name of the inbound NAT rule.')
param inboundNatRuleName string = 'SSH'

@description('Specifies the protocol of the inbound NAT rule.')
@allowed([
  'All'
  'Tcp'
  'Udp'
])
param inboundNatRuleProtocol string = 'Tcp'

@description('Specifies the frontend port of the inbound NAT rule.')
param inboundNatRuleFrontendPort int = 22

@description('Specifies the backend port of the inbound NAT rule.')
param inboundNatRuleBackendPort int = 22

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

@description('Specifies the name of the virtual network used by the load balancer.')
param virtualNetworkName string

@description('Specifies the name of the subnet used by the load balancer.')
param subnetName string

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
var loadBalancerMetricCategories = [
  'AllMetrics'
]
var loadBalancerMetrics = [for category in loadBalancerMetricCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: retentionInDays
  }
}]

// Resources
resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = {
  name: subnetName
  parent: vnet
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2021-08-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: frontEndIpConfigurationName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: backendPoolName
      }
    ]
    inboundNatRules: [
      {
        name: inboundNatRuleName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', name, frontEndIpConfigurationName)
          }
          protocol: inboundNatRuleProtocol
          frontendPort: inboundNatRuleFrontendPort
          backendPort: inboundNatRuleBackendPort
          enableFloatingIP: false
        }
      }
    ]
    loadBalancingRules: [
      {
        name: loadBalancingRuleName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', name, frontEndIpConfigurationName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', name, backendPoolName)
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', name, healthProbeName)
          }
          protocol: loadBalancingRuleProtocol
          frontendPort: loadBalancingRuleFrontendPort
          backendPort: loadBalancingRuleBackendPort
          idleTimeoutInMinutes: loadBalancingRuleidleTimeoutInMinutes
        }
      }
    ]
    probes: [
      {
        properties: {
          protocol: healthProbeProtocol
          port: healthProbePort
          intervalInSeconds: healthProbeIntervalInSeconds
          numberOfProbes: healthProbeNumberOfProbes
        }
        name: healthProbeName
      }
    ]
  }
  dependsOn: [
    subnet
  ]
}

resource loadBalancerDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: loadBalancer
  properties: {
    workspaceId: workspaceId
    metrics: loadBalancerMetrics
  }
}

// Outputs
output id string = loadBalancer.id
output name string = loadBalancer.name
output properties object = loadBalancer.properties
