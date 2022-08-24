resource eusHubVnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'eus-hub-vnet'
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
}

resource eusSpokeVnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'eus-spoke-vnet'
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
}

resource eusHubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  parent: eusHubVnet
  name: 'hubtospoke'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    // useRemoteGateways: true
    remoteVirtualNetwork: {
      id: eusSpokeVnet.id
    }
  }
}

resource eusSpokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  parent: eusSpokeVnet
  name: 'spoketohub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    // useRemoteGateways: true
    remoteVirtualNetwork: {
      id: eusHubVnet.id
    }
  }
}


resource cusHubVnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'cus-hub-vnet'
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
}

resource cusSpokeVnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'cus-spoke-vnet'
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
}

resource cusHubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  parent: cusHubVnet
  name: 'hubtospoke'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    // useRemoteGateways: true
    remoteVirtualNetwork: {
      id: cusSpokeVnet.id
    }
  }
}

resource cusSpokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  parent: cusSpokeVnet
  name: 'spoketohub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    // useRemoteGateways: true
    remoteVirtualNetwork: {
      id: cusHubVnet.id
    }
  }
}

// cus hub - eus hub peering
resource eusHubTocusHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  parent: eusHubVnet
  name: 'eushubtocushub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    // useRemoteGateways: true
    remoteVirtualNetwork: {
      id: cusHubVnet.id
    }
  }
}

resource cusHubToeusHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  // name: 'cus-hub-vnet/cushubtoeushub'
  parent: cusHubVnet
  name: 'cushubtoeushub'
  // name: concat(cusHubVnetName,'/cushubtoeushub')
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    // useRemoteGateways: true
    remoteVirtualNetwork: {
      id: eusHubVnet.id
    }
  }
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
            id: resourceId('Microsoft.Network/VirtualNetworks/subnets', eusHubVnet.name, 'AzureFirewallSubnet')

          }
          publicIPAddress: {
            id: eusafwpip.id
          }
        }
      }
    ]
  }
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
            id: resourceId('Microsoft.Network/VirtualNetworks/subnets', cusHubVnet.name, 'AzureFirewallSubnet')

          }
          publicIPAddress: {
            id: cusafwpip.id
          }
        }
      }
    ]
  }
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
            id: resourceId('Microsoft.Network/VirtualNetworks/subnets', eusSpokeVnet.name, 'Subnet-1')
          }
        }
      }
    ]
  }
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
            id: resourceId('Microsoft.Network/VirtualNetworks/subnets', cusSpokeVnet.name, 'Subnet-1')
          }
        }
      }
    ]
  }
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

// UPDATE Subnet to apply RouteTable
// RouteTable cannot be applied during creating VNet/Subnet because it depends on Azure Firewall that depends on VNet/Subnet
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
