param eusHubVnetName string = 'eus-hub-vnet'
param eusSpokeVnetName string = 'eus-spoke-vnet'
param cusHubVnetName string = 'cus-hub-vnet'
param cusSpokeVnetName string = 'cus-spoke-vnet'

resource eusHubVnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: eusHubVnetName
  location: 'eastus' 
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          // routeTable:{
          //   id: resourceId('Microsoft.Network/routeTables','eusafw-rt')
          // }
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
  // dependsOn:[
  //   eusafwrt
  // ]
}

resource eusSpokeVnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: eusSpokeVnetName
  location: 'eastus'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '10.1.0.0/24'
          // routeTable:{
          //   id: resourceId('Microsoft.Network/routeTables','eusspoke-rt')
          // }
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
  // dependsOn:[
  //   eusspokert
  // ]
}

resource eusHubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: concat(eusHubVnetName,'/hubtospoke')
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    // useRemoteGateways: true
    remoteVirtualNetwork: {
      id: resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', eusSpokeVnetName)
    }
  }
  dependsOn:[
    eusHubVnet
    eusSpokeVnet
  ]
}

resource eusSpokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: concat(eusSpokeVnetName,'/spoketohub')
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    // useRemoteGateways: true
    remoteVirtualNetwork: {
      id: resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', eusHubVnetName)
    }
  }
  dependsOn:[
    eusHubVnet
    eusSpokeVnet
  ]
}


resource cusHubVnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: cusHubVnetName
  location: 'centralus'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.10.0.0/24'
          // routeTable:{
          //   id: resourceId('Microsoft.Network/routeTables','cusafw-rt')
          // }
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '10.10.1.0/24'
        }
      }
    ]
  }
  // dependsOn:[
  //   cusafwrt
  // ]
}

resource cusSpokeVnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: cusSpokeVnetName
  location: 'centralus'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.11.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '10.11.0.0/24'
          routeTable:{
            id: resourceId('Microsoft.Network/routeTables','cusspoke-rt')
          }
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '10.11.1.0/24'
        }
      }
    ]
  }
  // dependsOn:[
  //   cusspokert
  // ]
}

resource cusHubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: concat(cusHubVnetName,'/hubtospoke')
  // name: '$(cusHubVnetName)/hubtospoke'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    // useRemoteGateways: true
    remoteVirtualNetwork: {
      id: resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', cusSpokeVnetName)
    }
  }
  dependsOn:[
    cusHubVnet
    cusSpokeVnet
  ]
}

resource cusSpokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  // name: '$(cusSpokeVnetName)/spoketohub'
  name: concat(cusSpokeVnetName,'/spoketohub')
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    // useRemoteGateways: true
    remoteVirtualNetwork: {
      id: resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', cusHubVnetName)
    }
  }
  dependsOn:[
    cusHubVnet
    cusSpokeVnet
  ]
}

// cus hub - eus hub peering
