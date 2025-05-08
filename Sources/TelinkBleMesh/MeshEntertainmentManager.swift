//
//  File.swift
//  
//
//  Created by maginawin on 2022/1/15.
//

import UIKit

public struct MeshEntertainmentAction {
    
    /// Action target address.
    public var target: Int
    
    /// Delay seconds, range [0, 60], default is 1
    public var delay: Int
    
    public var isOn: Bool?
    
    /// Range [0, 100]
    public var brightness: Int?
    
    /// Range [0, 100]
    public var white: Int?
    
    /// Range [0, 100]
    public var colorTemperature: Int?
    
    /// Range [0x000000, 0xFFFFFF],
    /// 0xFF0000 = red,
    /// 0x00FF00 = green,
    /// 0x0000FF = blue, ...
    public var rgb: Int?
    
    public init(target: Int, delay: Int = 1) {
        self.target = target
        self.delay = delay
    }
    
}

public class MeshEntertainmentManager {
    
    public static let shared = MeshEntertainmentManager()
    
    /// action index, begin from 0.
    public var index: Int = 0
    private var timer: Timer?
    private var isStarted = false
    private var actions: [MeshEntertainmentAction]?
    
    private init() {
        
    }
    
    public func start(_ actions: [MeshEntertainmentAction]) {
        self.actions = actions
        index = 0
        timer?.invalidate()
        if actions.count > 0 {
            isStarted = true
            let delay = TimeInterval(actions[0].delay)
            timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(self.execute), userInfo: nil, repeats: false)
        }
    }
    
    @objc private func execute() {
        if let actions = self.actions, actions.count > 0 {
            isStarted = true
            let action = actions[index]
            let count = sendAction(action)
            var newIndex = index + 1
            if newIndex >= actions.count {
                newIndex = 0
            }
            index = newIndex
            let newAction = actions[newIndex]
            let delay = TimeInterval(newAction.delay) + Double(count) * MeshManager.shared.sendingTimeInterval
            timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(self.execute), userInfo: nil, repeats: false)
        } else {
            isStarted = false
        }
    }
    
    public func stop() {
        timer?.invalidate()
        actions = nil
        isStarted = false
    }
    
}

extension MeshEntertainmentManager {
    
    /// return commands count
    private func sendAction(_ action: MeshEntertainmentAction) -> Int {
        
        NSLog("entertainment send action \(action)", "")
        var count = 0
        
        if let rgb = action.rgb {
            let red = (rgb >> 16) & 0xFF
            let green = (rgb >> 8) & 0xFF
            let blue = rgb & 0xFF
            MeshCommand.setRgb(action.target, red: red, green: green, blue: blue).send()
            count += 1
        }
        
        if let isOn = action.isOn {
            MeshCommand.turnOnOff(action.target, isOn: isOn).send()
            count += 1
        }
        
        if let cct = action.colorTemperature {
            MeshCommand.setColorTemperature(action.target, value: cct).send()
            count += 1
        }
        
        if let white = action.white {
            MeshCommand.setWhitePercentage(action.target, value: white).send()
            count += 1
        }
        
        if let brightness = action.brightness {
            MeshCommand.setBrightness(action.target, value: brightness).send()
            count += 1
        }
        return count
    }
    
}
