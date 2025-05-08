//
//  File.swift
//  
//
//  Created by maginawin on 2021/1/13.
//

import Foundation

public struct MeshNetwork {
    
    public var name: String
    
    public var password: String
    
    /**
     - Parameters:
        - name: At most 16 ASCII characters.
        - password: At most 16 ASCII characters.
     */
    public init?(name: String, password: String) {
        
        guard name.count > 0, name.count <= 16,
              password.count > 0, password.count <= 16 else {
            return nil 
        }
        
        self.name = name
        self.password = password
    }
    
}

extension MeshNetwork {
    
    /// The default network is `srbus: Srm@7478@a 475869`.
    public static var factory = MeshNetwork(name: "Srm@7478@a", password: "475869")!
    
    /// Srm@7478@a 475869
    public static let srbus = MeshNetwork(name: "Srm@7478@a", password: "475869")!
    
    /// Sun@7878@s 147258
    public static let sunSmart = MeshNetwork(name: "Sun@7878@s", password: "147258")!
    
    /// If you use the SunSmart App, you have to change the factory network to `MeshNetwork.sunSmart` manually.
    public static func changeFactoryNetwork(_ network: MeshNetwork) {
        Self.factory = network
    }
    
}

extension MeshNetwork: Equatable { }

public func == (lhs: MeshNetwork, rhs: MeshNetwork) -> Bool {
    
    return lhs.name == rhs.name && lhs.password == rhs.password
}
