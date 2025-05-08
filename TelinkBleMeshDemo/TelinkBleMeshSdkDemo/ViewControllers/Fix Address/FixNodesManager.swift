//
//  FixNodesManager.swift
//  TelinkBleMeshSdkDemo
//
//  Created by 王文东 on 2023/7/18.
//

import UIKit
import TelinkBleMesh

class FixNodesManager: NSObject {
    
    static let shared = FixNodesManager()
    
    // Key is MeshNetwork.name
    var networkNodes: [String: [MeshNode]] = [:]
    
    private override init() {
        super.init()
    }
    
    func clear(at network: MeshNetwork) {
        networkNodes[network.name] = []
    }
    
    /// return is added
    func appendNode(_ node: MeshNode) -> Bool {
        if networkNodes[node.name] == nil {
            networkNodes[node.name] = []
        }
        if let savedIndex = networkNodes[node.name]?.firstIndex(where: { $0.macValue == node.macValue }) {
            let savedNode = networkNodes[node.name]?[savedIndex]
            if savedNode?.shortAddress == node.shortAddress {
                return false
            }
            networkNodes[node.name]?[savedIndex] = node
            return true
        }        
        networkNodes[node.name]?.append(node)
        return true 
    }
    
    func isShortAddressRepeat(_ node: MeshNode) -> Bool {
        let theSame = networkNodes[node.name]?.filter({ $0.shortAddress == node.shortAddress }) ?? []
        return theSame.count > 1
    }
    
    func shortAddressRepeatNodes(_ network: MeshNetwork) -> [MeshNode] {
        let nodes = networkNodes(network)
        var result = [MeshNode]()
        nodes.forEach {
            if isShortAddressRepeat($0) {
                result.append($0)
            }
        }
        return result
    }
    
    func repeatCount(_ network: MeshNetwork) -> Int {
        return shortAddressRepeatNodes(network).count
    }
    
    func networkNodes(_ network: MeshNetwork) -> [MeshNode] {
        return networkNodes[network.name] ?? []
    }
    
    func newAddressList(_ network: MeshNetwork) -> [Int] {
        let nodes = networkNodes(network)
        let addressList = nodes.map { Int($0.shortAddress) }
        var all = Set<Int>(1...253)
        all.subtract(addressList)
        return all.sorted()
    }
    
    func updateNewAddress(_ newAddress: Int, mac: String, network: MeshNetwork) {
        let nodes = networkNodes(network)
        nodes.first(where: { mac.contains($0.macAddress) })?.shortAddress = UInt16(newAddress)
    }
}
