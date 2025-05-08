//
//  File.swift
//  
//
//  Created by 王文东 on 2023/5/17.
//

import Foundation

public protocol NaturalLightManagerDelegate: NSObjectProtocol {
    
    func naturalLightManager(_ manager: NaturalLightManager, address: Int, didGetInvalidDataAt mode: MeshCommand.NaturalLight.Mode)
    
    func naturalLightManager(_ manager: NaturalLightManager, address: Int, didGetItem item: MeshCommand.NaturalLight.Item, at mode: MeshCommand.NaturalLight.Mode)
    
    func naturalLightManagerDidResetOK(_ manager: NaturalLightManager, address: Int)
    
    func naturalLightManagerDidSetEnd(_ manager: NaturalLightManager, address: Int)
    
    func naturalLightManagerDidGetEnd(_ manager: NaturalLightManager, address: Int)
    
    func naturalLightManager(manager: NaturalLightManager, didStateEnabled address: Int, mode: MeshCommand.NaturalLight.Mode)

    func naturalLightManager(manager: NaturalLightManager, didStateDisabled address: Int)
}

public class NaturalLightManager {
    
    public static let shared = NaturalLightManager()
    
    public weak var delegate: NaturalLightManagerDelegate?
    private var isGettingState = false
    private var isGettingNatural = false
    private var isSettingNatural = false
    private let sendQueue = DispatchQueue(label: "NaturalLightManager.send")
    
    private init() {
        
    }
    
    public func getCurrentState(address: Int) {
        isGettingState = true
        MeshCommand.getNaturalLightCurrentState(address).send()
    }
    
    public func startGetNaturalLight(address: Int, mode: MeshCommand.NaturalLight.Mode) {
        isGettingNatural = true
        sendQueue.async {
            Thread.sleep(forTimeInterval: 1)
            var commands: [MeshCommand] = []
            for i in 0...23 {
                let cmd = MeshCommand.getNaturalLight(address, mode: mode, hour: UInt8(i))
                commands.append(cmd)
            }
            while (self.isGettingNatural && !commands.isEmpty) {
                commands.removeFirst().send()
                Thread.sleep(forTimeInterval: 1)
            }
            if (self.isGettingNatural) {
                DispatchQueue.main.async {
                    self.delegate?.naturalLightManagerDidGetEnd(self, address: address)
                }
            }
        }
    }
    
    public func stopGetNaturalLight() {
        isGettingNatural = false
    }
    
    public func startSetNaturalLight(address: Int, naturalLight: MeshCommand.NaturalLight, mode: MeshCommand.NaturalLight.Mode, isEnabled: Bool) {
        isSettingNatural = true
        sendQueue.async {
            Thread.sleep(forTimeInterval: 1)
            MeshCommand.disableNaturalLight(address).send()
            Thread.sleep(forTimeInterval: 2)
            var commands = MeshCommand.setNaturalLight(address, naturalLight: naturalLight, mode: mode)
            while (self.isSettingNatural && !commands.isEmpty) {
                commands.removeFirst().send()
                // Sometimes the setting fails, maybe the interval is too short.
                // Thread.sleep(forTimeInterval: 0.5)
                Thread.sleep(forTimeInterval: 1.0)
            }
            if isEnabled {
                Thread.sleep(forTimeInterval: 2)
                MeshCommand.enableNaturalLight(address, mode: mode).send()
            }
        }
    }
    
    public func stopSetNaturalLight() {
        isSettingNatural = false
    }
    
    func handleCommand(_ command: MeshCommand) {
        let cmd = command.userData[0]
        if cmd < 0x60 || cmd > 0x63 {
            // Available cmds are 0x60, 0x61, 0x62, 0x63
            return
        }
        if (isGettingState) {
            isGettingState = false;
            DispatchQueue.main.async {
                let modeRaw = command.userData[1]
                if modeRaw == 0xFF {
                    self.delegate?.naturalLightManager(manager: self, didStateDisabled: command.src)
                } else if let mode = MeshCommand.NaturalLight.Mode(rawValue: modeRaw + 1) {
                    self.delegate?.naturalLightManager(manager: self, didStateEnabled: command.src, mode: mode)
                }
            }
            return;
        }
        let modeRaw = cmd - 0x5F
        guard let mode = MeshCommand.NaturalLight.Mode(rawValue: modeRaw) else {
            return
        }
        let cmd1 = command.userData[1]
        switch cmd1 {
        case 0...23:
            let hour = cmd1
            // let minute = 0 // minute always 0
            let brightness = command.userData[3]
            // let red = command.userData[4]
            // let green = command.userData[5]
            // let blue = command.userData[6]
            let whiteOrCt = command.userData[7]
            // let isCtEnabled = command.userData[8] == 0x00
            var item = MeshCommand.NaturalLight.Item()
            item.hour = hour
            // item.minute = minute
            item.brightness = brightness
            item.cct = whiteOrCt
            DispatchQueue.main.async {
                self.delegate?.naturalLightManager(self, address: command.src, didGetItem: item, at: mode)
            }
            
        case 0xA0:
            NSLog("didGetEnableResponse natural light", "")
            
        case 0xB0:
            NSLog("didGetDisableResponse natural light", "")
            
        case 0xC0:
            NSLog("didResetResponse natural light", "")
            DispatchQueue.main.async {
                self.delegate?.naturalLightManagerDidResetOK(self, address: command.src)
            }
            
        case 0x80:
            DispatchQueue.main.async {
                self.delegate?.naturalLightManagerDidSetEnd(self, address: command.src)
            }
            
        case 0xFF:
            // Invalid data
            if isGettingNatural {
                stopGetNaturalLight()
            }
            DispatchQueue.main.async {
                self.delegate?.naturalLightManager(self, address: command.src, didGetInvalidDataAt: mode)
            }
            
        default:
            break
        }
        
    }
}
