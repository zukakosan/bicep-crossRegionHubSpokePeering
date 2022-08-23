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
resource eusHubTocusHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  // name: '$(eusHubVnetName)/eushubtocushub'
  name: concat(eusHubVnetName,'/eushubtocushub')
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    // useRemoteGateways: true
    remoteVirtualNetwork: {
      id: resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', cusHubVnetName)
    }
  }
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
      id: resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', eusHubVnetName)
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
    // applicationRuleCollections: [
    //   {
    //     name: 'name'
    //     properties: {
    //       priority: 'priority'
    //       action: {
    //         type: 'Allow'
    //       }
    //       rules: [
    //         {
    //           name: 'name'
    //           description: 'description'
    //           sourceAddresses: [
    //             'sourceAddress'
    //           ]
    //           protocols: [
    //             {
    //               protocolType: 'Http'
    //               port: 80
    //             }
    //           ]
    //           targetFqdns: [
    //             'www.microsoft.com'
    //           ]
    //         }
    //       ]
    //     }
    //   }
    // ]
    // natRuleCollections: [
    //   {
    //     name: 'name'
    //     properties: {
    //       priority: 'priority'
    //       action: {
    //         type: 'Dnat'
    //       }
    //       rules: [
    //         {
    //           name: 'name'
    //           description: 'description'
    //           sourceAddresses: [
    //             'sourceAddress'
    //           ]
    //           destinationAddresses: [
    //             'destinationAddress'
    //           ]
    //           destinationPorts: [
    //             'port'
    //           ]
    //           protocols: [
    //             'TCP'
    //           ]
    //           translatedAddress: 'translatedAddress'
    //           translatedPort: 'translatedPort'
    //         }
    //       ]
    //     }
    //   }
    // ]
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
            id: resourceId('Microsoft.Network/publicIPAddresses','eusafw-pip')
          }
        }
      }
    ]
  }
  dependsOn:[
    eusafwpip
  ]
}


resource cusafw 'Microsoft.Network/azureFirewalls@2020-11-01' = {
  name: 'cusafw'
  location: 'centralus'
  properties: {
    // applicationRuleCollections: [
    //   {
    //     name: 'name'
    //     properties: {
    //       priority: 'priority'
    //       action: {
    //         type: 'Allow'
    //       }
    //       rules: [
    //         {
    //           name: 'name'
    //           description: 'description'
    //           sourceAddresses: [
    //             'sourceAddress'
    //           ]
    //           protocols: [
    //             {
    //               protocolType: 'Http'
    //               port: 80
    //             }
    //           ]
    //           targetFqdns: [
    //             'www.microsoft.com'
    //           ]
    //         }
    //       ]
    //     }
    //   }
    // ]
    // natRuleCollections: [
    //   {
    //     name: 'name'
    //     properties: {
    //       priority: 'priority'
    //       action: {
    //         type: 'Dnat'
    //       }
    //       rules: [
    //         {
    //           name: 'name'
    //           description: 'description'
    //           sourceAddresses: [
    //             'sourceAddress'
    //           ]
    //           destinationAddresses: [
    //             'destinationAddress'
    //           ]
    //           destinationPorts: [
    //             'port'
    //           ]
    //           protocols: [
    //             'TCP'
    //           ]
    //           translatedAddress: 'translatedAddress'
    //           translatedPort: 'translatedPort'
    //         }
    //       ]
    //     }
    //   }
    // ]
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
            id: resourceId('Microsoft.Network/publicIPAddresses','cusafw-pip')
          }
        }
      }
    ]
  }
  dependsOn:[
    cusafwpip
  ]
}

resource eusafwrt 'Microsoft.Network/routeTables@2019-11-01' = {
  name: 'eusafwrt'
  location: 'eastus'
  properties: {
    routes: [
      {
        name: 'Internet'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'Internet'
          // nextHopIpAddress: 'nextHopIp'
        }
      }
      {
        name: 'cusSpoke'
        properties: {
          addressPrefix: '10.11.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: 'nextHopIp'
        }
      }
    ]
    disableBgpRoutePropagation: true
  }
}
