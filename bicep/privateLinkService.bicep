// Parameters
@description('Specifies the name of the Azure Private Link Service.')
param privatelinkServiceName string

@description('Specifies the name of the Azure Private Endpoint.')
param privateEndpointName string

@description('Specifies the name of the load balancer.')
param loadBalancerName string

@description('Specifies the name of the client virtual network.')
param virtualNetworkName string

@description('Specifies the name of the subnet used by the load balancer.')
param subnetName string

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the resource tags.')
param tags object

// Resources
resource loadBalancer 'Microsoft.Network/loadBalancers@2021-08-01' existing = {
  name: loadBalancerName
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = {
  name: subnetName
  parent: vnet
}

resource privatelinkService 'Microsoft.Network/privateLinkServices@2021-05-01' = {
  name: privatelinkServiceName
  location: location
  tags: tags
  properties: {
    enableProxyProtocol: false
    loadBalancerFrontendIpConfigurations: [
      {
        id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', loadBalancer.name, loadBalancer.properties.frontendIPConfigurations[0].name)
      }
    ]
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
          subnet: {
            id: loadBalancer.properties.frontendIPConfigurations[0].properties.subnet.id
          }
          primary: false
        }
      }
    ]
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: privatelinkService.id
        }
      }
    ]
  }
  dependsOn: [
    subnet
  ]
}
