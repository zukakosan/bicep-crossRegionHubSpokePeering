param eusHubVnetName string = 'eus-hub-vnet'
param eusSpokeVnetName string = 'eus-spoke-vnet'
param cusHubVnetName string = 'cus-hub-vnet'
param cusSpokeVnetName string = 'cus-spoke-vnet'
// param baseTime string = utcNow('yyyymmddth')


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
      id: eusSpokeVnet.id
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
      id: eusHubVnet.id
    }
  }
  dependsOn:[
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
      id: cusSpokeVnet.id
    }
  }
  dependsOn:[
    cusHubVnet
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
      id: cusHubVnet.id
    }
  }
  dependsOn:[
    cusSpokeVnet
  ]
}

// cus hub - eus hub peering
resource eusHubTocusHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  // name: '$(eusHubVnetName)/eushubtocushub'
  name: concat(eusHubVnetName,'/eushubtocushub')
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    // useRemoteGateways: true
    remoteVirtualNetwork: {
      id: cusHubVnet.id
    }
  }
  dependsOn:[
    eusHubVnet
  ]
}

resource cusHubToeusHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  // name: 'cus-hub-vnet/cushubtoeushub'
  name: concat(cusHubVnetName,'/cushubtoeushub')
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    // useRemoteGateways: true
    remoteVirtualNetwork: {
      id: eusHubVnet.id
    }
  }
  dependsOn:[
    cusHubVnet
  ]
}

resource eusafwpip 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'eusafw-pip'
  location: 'eastus'
  sku:{
    name:'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    // dnsSettings: {
    //   domainNameLabel: 'dnsname'
    // }
  }
}

resource cusafwpip 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'cusafw-pip'
  location: 'centralus'
  sku:{
    name:'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    // dnsSettings: {
    //   domainNameLabel: 'dnsname'
    // }
  }
}

resource eusafw 'Microsoft.Network/azureFirewalls@2020-11-01' = {
  name: 'eusafw'
  location: 'eastus'
  properties: {
    networkRuleCollections: [
      {
        name: 'spokehubhubspoke'
        properties: {
          priority: '1000'
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'fromeusspoke'
              description: 'description'
              sourceAddresses: [
                '10.1.0.0/16'
              ]
              destinationAddresses: [
                '10.11.0.0/16'
              ]
              destinationPorts: [
                '*'
              ]
              protocols: [
                'Any'
              ]
            }
            {
              name: 'fromcusspoke'
              description: 'description'
              sourceAddresses: [
                '10.11.0.0/16'
              ]
              destinationAddresses: [
                '10.1.0.0/16'
              ]
              destinationPorts: [
                '*'
              ]
              protocols: [
                'Any'
              ]
            }
          ]
        }
      }
    ]
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/VirtualNetworks/subnets', eusHubVnetName, 'AzureFirewallSubnet')

          }
          publicIPAddress: {
            id: eusafwpip.id
          }
        }
      }
    ]
  }
  dependsOn:[
    eusHubVnet
  ]
}


resource cusafw 'Microsoft.Network/azureFirewalls@2020-11-01' = {
  name: 'cusafw'
  location: 'centralus'
  properties: {
    
    networkRuleCollections: [
      {
        name: 'spokehubhubspoke'
        properties: {
          priority: '1000'
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'fromeusspoke'
              description: 'description'
              sourceAddresses: [
                '10.1.0.0/16'
              ]
              destinationAddresses: [
                '10.11.0.0/16'
              ]
              destinationPorts: [
                '*'
              ]
              protocols: [
                'Any'
              ]
            }
            {
              name: 'fromcusspoke'
              description: 'description'
              sourceAddresses: [
                '10.11.0.0/16'
              ]
              destinationAddresses: [
                '10.1.0.0/16'
              ]
              destinationPorts: [
                '*'
              ]
              protocols: [
                'Any'
              ]
            }
          ]
        }
      }
    ]
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/VirtualNetworks/subnets', cusHubVnetName, 'AzureFirewallSubnet')

          }
          publicIPAddress: {
            id: cusafwpip.id
          }
        }
      }
    ]
  }
  dependsOn:[
    cusHubVnet
  ]
}

resource eusafwrt 'Microsoft.Network/routeTables@2019-11-01' = {
  name: 'eusafw-rt'
  location: 'eastus'
  properties: {
    routes: [
      {
        name: 'Internet'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'Internet'
          // nextHopIpAddress: ''
        }
      }
      {
        name: 'cusSpoke'
        properties: {
          addressPrefix: '10.11.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: cusafw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
    disableBgpRoutePropagation: true
  }
}

resource cusafwrt 'Microsoft.Network/routeTables@2019-11-01' = {
  name: 'cusafw-rt'
  location: 'centralus'
  properties: {
    routes: [
      {
        name: 'Internet'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'Internet'
          // nextHopIpAddress: ''
        }
      }
      {
        name: 'eusSpoke'
        properties: {
          addressPrefix: '10.1.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: eusafw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
    disableBgpRoutePropagation: true
  }
}

// from east us vm to Azure Firewall
resource eusspokert 'Microsoft.Network/routeTables@2019-11-01' = {
  name: 'eusspoke-rt'
  location: 'eastus'
  properties: {
    routes: [
      {
        name: 'default-rt'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: eusafw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
    disableBgpRoutePropagation: true
  }
}

// from central us vm to Azure Firewall
resource cusspokert 'Microsoft.Network/routeTables@2019-11-01' = {
  name: 'cusspoke-rt'
  location: 'centralus'
  properties: {
    routes: [
      {
        name: 'default-rt'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: cusafw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
    disableBgpRoutePropagation: true
  }
}

resource eusvm1nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'eusvm1nic'
  location: 'eastus'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/VirtualNetworks/subnets', eusSpokeVnetName, 'Subnet-1')
          }
        }
      }
    ]
  }
  dependsOn:[
    eusSpokeVnet
  ]
}

resource cusvm1nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'cusvm1nic'
  location: 'centralus'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/VirtualNetworks/subnets', cusSpokeVnetName, 'Subnet-1')
          }
        }
      }
    ]
  }
  dependsOn:[
    cusSpokeVnet
  ]
}

resource eusvm1 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: 'eusvm1'
  location: 'eastus'
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    osProfile: {
      computerName: 'eusvm1'
      adminUsername: 'AzureAdmin'
      adminPassword: '#Pa55w0rd'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '16.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: 'eusvm1-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: eusvm1nic.id
        }
      ]
    }
    // diagnosticsProfile: {
    //   bootDiagnostics: {
    //     enabled: false
    //     storageUri: 'storageUri'
    //   }
    // }
  }
}

resource cusvm1 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: 'cusvm1'
  location: 'centralus'
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    osProfile: {
      computerName: 'cusvm1'
      adminUsername: 'AzureAdmin'
      adminPassword: '#Pa55w0rd'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '16.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: 'cusvm1-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: cusvm1nic.id
        }
      ]
    }
    // diagnosticsProfile: {
    //   bootDiagnostics: {
    //     enabled: false
    //     storageUri: 'storageUri'
    //   }
    // }
  }
}

resource eusafwSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  name: 'AzureFirewallSubnet'
  parent: eusHubVnet
  properties:{
    addressPrefix: '10.0.0.0/24'
    routeTable: {
      id: eusafwrt.id
    } 
  } 
}

resource cusafwSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  name: 'AzureFirewallSubnet'
  parent: cusHubVnet
  properties:{
    addressPrefix: '10.10.0.0/24'
    routeTable: {
      id: cusafwrt.id
    }
  }
}
resource eusSpokeSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  name: 'Subnet-1'
  parent: eusSpokeVnet
  properties:{
    addressPrefix: '10.1.0.0/24'
    routeTable: {
      id: eusspokert.id
    }
  }
}

resource cusSpokeSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  name: 'Subnet-1'
  parent: cusSpokeVnet
  properties:{
    addressPrefix: '10.11.0.0/24'
    routeTable: {
      id: cusspokert.id
    }
  }
}
