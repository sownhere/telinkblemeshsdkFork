//
//  File.swift
//  
//
//  Created by 王文东 on 2023/8/22.
//

import Foundation

extension MeshCommand {
    
    public struct UartDali {
        
        public static func sendUartData(_ address: Int, data: Data) -> MeshCommand {
            var uartData = data
            if data.count != 10 {
                uartData = Data(repeating: 0xFF, count: 10)
            }
            var cmd = MeshCommand()
            cmd.tag = .uartModule
            cmd.dst = address
            cmd.param = Int(uartData[0])
            cmd.userData = Data(uartData[1...9])
            return cmd
        }
        
        /**
         
         address: DALI Gateway ble short address.
         daliAddr: Device address (0x00-0x3F), group address (0x80-0x8F), or broadcast 0xFF (all devices).
         */
        
        public enum CommandType: UInt8 {
            case discover = 0xA0
            case terminate = 0xAF
            case config = 0x01
            case control = 0x02
            case query = 0x03
            
            case setPowerOn = 0x30
            case setSystemFail = 0x31
            case setScene0 = 0x40
            case setScene1 = 0x41
            case setScene2 = 0x42
            case setScene3 = 0x43
            case setScene4 = 0x44
            case setScene5 = 0x45
            case setScene6 = 0x46
            case setScene7 = 0x47
            case setScene8 = 0x48
            case setScene9 = 0x49
            case setScene10 = 0x4A
            case setScene11 = 0x4B
            case setScene12 = 0x4C
            case setScene13 = 0x4D
            case setScene14 = 0x4E
            case setScene15 = 0x4F
            
            case commandOK = 0x80
            case commandError = 0x81
        }
        
        // MARK: - 1. Config
        
        public enum Config: UInt8 {
            case reset = 0x00
            case setMax = 0x01
            case setMin = 0x02
            case setSystemFailDt6 = 0x03
            case setPowerOnDt6 = 0x04
            case setFadeTime = 0x05
            case setFadeRate = 0x06
            case setExtendedFadeTime = 0x07
            case addToGroup = 0x08
            case removeFromGroup = 0x09
            case setDimmerCurve = 0x0A
            case setFastFadeTime = 0x0B
            case setOperateMode = 0x0C
            case storeDtrAsShortAddress = 0x0D
            case setSceneDt6 = 0x0E
            case removeFromScene = 0x0F
            
            case setCctStep = 0x20
            case setCctCoolest = 0x21
            case setCctWarmest = 0x22
            case setCctPhysicalCoolest = 0x23
            case setCctPhysicalWarmest = 0x24
            case setRgbwafControl = 0x25
            
            case setPowerOnDt8Xy = 0x30
            case setPowerOnDt8Cct = 0x31
            case setSystemFailDt8Xy = 0x32
            case setSystemFailDt8Cct = 0x33
            case setSceneDt8Xy = 0x34
            case setSceneDt8Cct = 0x35
        }
        
        public static func configDevice(_ address: Int, daliAddr: UInt8, config: Config, values: [UInt8] = []) -> MeshCommand {
            var data = Data(repeating: 0xFF, count: 10)
            data[0] = 0xA5
            data[1] = CommandType.config.rawValue
            data[2] = daliAddr
            data[3] = config.rawValue
            if values.count > 0 && values.count <= 6 {
                for i in 0..<values.count {
                    data[i + 4] = values[i]
                }
            }
            return sendUartData(address, data: data)
        }
        
        public static func setPowerOnDt8Rgb(_ address: Int, daliAddr: UInt8, values: [UInt8]) -> MeshCommand {
            var data = Data(repeating: 0xFF, count: 10)
            data[0] = 0xA5
            data[1] = CommandType.setPowerOn.rawValue
            data[2] = daliAddr
            if values.count == 7 {
                for i in 3...9 {
                    data[i] = values[i - 3]
                }
            }
            return sendUartData(address, data: data)
        }
        
        public static func setSystemFailDt8Rgb(_ address: Int, daliAddr: UInt8, values: [UInt8]) -> MeshCommand {
            var data = Data(repeating: 0xFF, count: 10)
            data[0] = 0xA5
            data[1] = CommandType.setSystemFail.rawValue
            data[2] = daliAddr
            if values.count == 7 {
                for i in 3...9 {
                    data[i] = values[i - 3]
                }
            }
            return sendUartData(address, data: data)
        }
        
        public static func setSceneDt8Rgb(_ address: Int, daliAddr: UInt8, sceneId: UInt8, values: [UInt8]) -> MeshCommand {
            var data = Data(repeating: 0xFF, count: 10)
            data[0] = 0xA5
            data[1] = CommandType.setScene0.rawValue + sceneId
            data[2] = daliAddr
            if values.count == 7 {
                for i in 3...9 {
                    data[i] = values[i - 3]
                }
            }
            return sendUartData(address, data: data)
        }
        
        // MARK: - 2. Control
        
        public enum Control: UInt8 {
            case directArcPowerControl = 0x00
            case off = 0x01
            case up = 0x02
            case down = 0x03
            case stepUp = 0x04
            case stepDown = 0x05
            case stepDownAndOff = 0x06
            case onAndStepUp = 0x07
            case recallMaxLevel = 0x08
            case recallMinLevel = 0x09
            case goToScene = 0x0A
            case goToLastLevel = 0x0B
            case xCoordinateStepUp = 0x10
            case xCoordinateStepDown = 0x11
            case yCoordinateStepUp = 0x12
            case yCoordinateStepDown = 0x13
            case cctStepCooler = 0x14
            case cctStepWarmer = 0x15
            
            case activateXy = 0x20
            case activateCct = 0x21
            case activateRgbwaf = 0x22
        }
        
        public static func controlDevice(_ address: Int, daliAddr: UInt8, control: Control, values: [UInt8] = []) -> MeshCommand {
            var data = Data(repeating: 0xFF, count: 10)
            data[0] = 0xA5
            data[1] = CommandType.control.rawValue
            data[2] = daliAddr
            data[3] = control.rawValue
            if values.count > 0 && values.count <= 6 {
                for i in 0..<values.count {
                    data[i + 4] = values[i]
                }
            }
            return sendUartData(address, data: data)
        }
        
        // MARK: - 3. Query
        
        public enum Query: UInt8 {
            case status = 0x00
            case controlGear = 0x01
            case lampFailure = 0x02
            case lampPowerOn = 0x03
            case limitError = 0x04
            case resetState = 0x05
            case missingShortAddress = 0x06
            case versionNumber = 0x07
            case contentDtr = 0x08
            case contentDtr1 = 0x09
            case contentDtr2 = 0x0A
            case deviceType = 0x0B
            case physicalMinimumLevel = 0x0C
            case powerFailure = 0x0D
            case maxLevel = 0x0E
            case minLevel = 0x0F
            case fadeTimeOrFadeRate = 0x10
            case groups0_7 = 0x11
            case groups8_15 = 0x12
            case memoryLocation = 0x013
            case lastLocation = 0x14
            case extendedVersionNumber = 0x15
            case cctCoolest = 0x16
            case physicalCoolest = 0x17
            case cctWarmest = 0x18
            case physicalWarmest = 0x19
            
            case actualLevel = 0x30
            case powerOnLevel = 0x34
            case systemFailureLevel = 0x38
            case sceneValue = 0x3C
        }
        
        public static func queryDevice(_ address: Int, daliAddr: UInt8, query: Query, values: [UInt8] = []) -> MeshCommand {
            var data = Data(repeating: 0xFF, count: 10)
            data[0] = 0xA5
            data[1] = CommandType.query.rawValue
            data[2] = daliAddr
            data[3] = query.rawValue
            if values.count > 0 && values.count <= 6 {
                for i in 0..<values.count {
                    data[i + 4] = values[i]
                }
            }
            return sendUartData(address, data: data)
        }
        
        // MARK: - 4. Discover
        
        public enum Discover: UInt8 {
            case allControlGearShallReact = 0x00
            case withoutShortAddressShallReact = 0x01
            case addressShallReact = 0x02
            case checkBusDevice = 0x03
        }
        
        public static func discoverDevice(_ address: Int, discover: Discover, values: [UInt8] = []) -> MeshCommand {
            var data = Data(repeating: 0xFF, count: 10)
            data[0] = 0xA5
            data[1] = CommandType.discover.rawValue
            data[2] = discover.rawValue
            if values.count > 0 && values.count <= 7 {
                for i in 0..<values.count {
                    data[i + 3] = values[i]
                }
            }
            return sendUartData(address, data: data)
        }
        
        public static func terminateDiscovering(_ address: Int) -> MeshCommand {
            var data = Data(repeating: 0xFF, count: 10)
            data[0] = 0xA5
            data[1] = CommandType.terminate.rawValue
            return sendUartData(address, data: data)
        }
        
    }
}

// MARK: - Smart Switches

extension MeshCommand.UartDali {
    
    public typealias ButtonCount = MeshCommand.SmartSwitchActions.ButtonCount
    public typealias ButtonPosition = MeshCommand.SmartSwitchActions.ButtonPosition
    
    /// - Parameters:
    ///     - address: The short address of the ble.
    ///     - switchId: The smart switch ID, such as `0x7000000D`.
    public static func setSmartSwitchId(_ address: Int, buttonPosition: ButtonPosition, switchId: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x03
        cmd.userData[2] = 0x01
        cmd.userData[3] = buttonPosition.groupIndex
        cmd.userData[4] = UInt8((switchId >> 24) & 0xFF)
        cmd.userData[5] = UInt8((switchId >> 16) & 0xFF)
        cmd.userData[6] = UInt8((switchId >> 8) & 0xFF)
        cmd.userData[7] = UInt8((switchId) & 0xFF)
        return cmd
    }
    
    public static func deleteSmartSwitch(_ address: Int, buttonPosition: ButtonPosition, switchId: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x03
        cmd.userData[2] = 0x02
        cmd.userData[3] = buttonPosition.groupIndex
        cmd.userData[4] = UInt8((switchId >> 24) & 0xFF)
        cmd.userData[5] = UInt8((switchId >> 16) & 0xFF)
        cmd.userData[6] = UInt8((switchId >> 8) & 0xFF)
        cmd.userData[7] = UInt8((switchId) & 0xFF)
        return cmd
    }
    
    /// index range 0-7
    public static func getSmartSwitchId(_ address: Int, index: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x72
        cmd.userData[1] = UInt8(index)
        return cmd
    }
    
    /// Key index [1, 2, 3, 4]
    private static func setSmartSwitchAction(_ address: Int, keyIndex: UInt8, buttonEvent: ButtonEvent, data: Data) -> [MeshCommand] {
        var cmd1 = MeshCommand()
        cmd1.tag = .appToNode
        cmd1.dst = address
        cmd1.userData[0] = 0x14
        cmd1.userData[1] = 0x71
        cmd1.userData[2] = keyIndex
        cmd1.userData[3] = buttonEvent.rawValue
        cmd1.userData[4] = data[0]
        cmd1.userData[5] = data[1]
        cmd1.userData[6] = data[2]
        cmd1.userData[7] = data[3]
        cmd1.userData[8] = data[4]
        
        var cmd2 = MeshCommand()
        cmd2.tag = .appToNode
        cmd2.dst = address
        cmd2.userData[0] = 0x14
        cmd2.userData[1] = 0x72
        cmd2.userData[2] = keyIndex
        cmd2.userData[3] = buttonEvent.rawValue
        cmd2.userData[4] = data[5]
        cmd2.userData[5] = data[6]
        cmd2.userData[6] = data[7]
        cmd2.userData[7] = data[8]
        cmd2.userData[8] = data[9]
        return [cmd1, cmd2]
    }
    
    public struct SmartSwitchAction {
        
        public struct Target {
            public enum TargetType {
                case device
                case group
                /// All devices
                case broadcast
                
                public static let all: [TargetType] = [.device, .group, .broadcast]
            }
            
            public var targetType: TargetType
            public var deviceAddress: Int = 0
            public var groupId: Int = 0
            
            public var daliAddress: UInt8 {
                switch targetType {
                case .device: return UInt8(deviceAddress)
                case .group: return UInt8(0x80 | groupId)
                case .broadcast: return UInt8(0xFF)
                }
            }
            
            fileprivate init(_ type: TargetType) {
                self.targetType = type
            }
            
            public init(targetType: TargetType, deviceAddress: Int?, groupId: Int?) {
                self.targetType = targetType
                if let address = deviceAddress {
                    self.deviceAddress = address
                }
                if let groupId = groupId {
                    self.groupId = groupId
                }
            }
        }
        
        public struct Action {
            public enum ActionType: UInt8 {
                case none = 0xFF
                case off = 0x01
                case level = 0x00
                case goToLastLevel = 0x0B
                case levelStepUp = 0x04
                case levelStepDown = 0x05
                case levelStepDownAndOff = 0x06
                case goToScene = 0x0A
                
                public static let all: [ActionType] = [
                    .none, .off, .level, .goToLastLevel, .levelStepUp, .levelStepDown, .levelStepDownAndOff, .goToScene
                ]
            }
            
            public var actionType: ActionType = .off
            /// Range 0x00-0xFE, default is 254.
            public var level: Int = 254
            /// Range 0x00-0x0F, default is 0.
            public var sceneId: Int = 0
            
            public var actionValue: UInt8 {
                switch actionType {
                case .level: return UInt8(level)
                case .goToScene: return UInt8(sceneId)
                default: return 0xFF
                }
            }
            
            fileprivate init(actionType: ActionType) {
                self.actionType = actionType
            }
            
            public init(actionType: ActionType, level: Int?, sceneId: Int?) {
                self.actionType = actionType
                if let level = level {
                    self.level = level
                }
                if let sceneId = sceneId {
                    self.sceneId = sceneId
                }
            }
        }
        
        public var target: Target
        public var action: Action
        
        public init(target: Target, action: Action) {
            self.target = target
            self.action = action
        }
    }
    
    public enum ButtonEvent: UInt8 {
        case shortPress = 0x01
        case longPressBegin = 0x02
        case longPressEnd = 0x03
        
        public static let all: [ButtonEvent] = [.shortPress, .longPressBegin, .longPressEnd]
    }
    
    public static func setSmartSwitch(_ address: Int, switchId: Int, buttonPosition: ButtonPosition, buttonEvent: ButtonEvent, smartSwitchAction: SmartSwitchAction) -> [MeshCommand] {
        let setCommand = Self.setSmartSwitchId(address, buttonPosition: buttonPosition, switchId: switchId)
        var commands = [setCommand]
        let daliAddress = smartSwitchAction.target.daliAddress
        let daliActionType = smartSwitchAction.action.actionType.rawValue
        let daliActionValue = smartSwitchAction.action.actionValue
        let data = Data([0xA5, 0x02, daliAddress, daliActionType, daliActionValue,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
        let actionCommands = setSmartSwitchAction(address, keyIndex: buttonPosition.keyIndex, buttonEvent: buttonEvent, data: data)
        commands.append(contentsOf: actionCommands)
        return commands
    }
    
}
