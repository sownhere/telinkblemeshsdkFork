//
//  File.swift
//  
//
//  Created by maginawin on 2021/1/13.
//

import UIKit
import CryptoAction

public struct MeshCommand {
    
    private static var seqNo: Int = 0
    
    /// [0-2],
    /// 3 bytes, for data notify
    var seqNo: Int = 0
    
    /// [0-2],
    /// 3 bytes, for command data, will auto increment
    var seqNoForCommandData: Int {
        
        if MeshCommand.seqNo >= 0xFFFFFF {
            
            MeshCommand.seqNo = 0
        }
        
        MeshCommand.seqNo += 1
        return MeshCommand.seqNo
    }
    
    /// [3-4],
    /// 2 bytes
    var src: Int = 0
    
    /// [5-6],
    /// 2 bytes
    var dst: Int = 0
    
    /// [7],
    /// 1 bytes
    var tag: Tag = .appToNode
    
    /// [8-9],
    /// 2 bytes
    let vendorID: Int = 0x1102
    
    /// [10],
    /// 1 bytes, default is 0x10, transfer this command to the mesh network times
    var param: Int = 0x10
    
    /// [11, 19],
    /// 9 bytes
    var userData = Data(repeating: 0x00, count: 9)
    
    /// Data for send.
    var commandData: Data {
        
        var data = Data(repeating: 0, count: 20)
        
        let seqNo = self.seqNoForCommandData
        data[0] = UInt8((seqNo >> 16) & 0xFF)
        data[1] = UInt8((seqNo >> 8) & 0xFF)
        data[2] = UInt8(seqNo & 0xFF)
        
        data[3] = UInt8(src & 0xFF)
        data[4] = UInt8((src >> 8) & 0xFF)
        data[5] = UInt8(dst & 0xFF)
        data[6] = UInt8((dst >> 8) & 0xFF)
        
        data[7] = UInt8(tag.rawValue)
        data[8] = UInt8((vendorID >> 8) & 0xFF)
        data[9] = UInt8(vendorID & 0xFF)
        data[10] = UInt8(param)
        
        for i in 11..<20 {
            
            data[i] = userData[i - 11]
        }
        
        return data
    }
    
    init() {
        
    }
    
    /// Init with a notify data `(charactersistic.value)`.
    init?(notifyData data: Data) {
        
        guard data.count == 20 else { return nil }
        
        guard let tempTag = Tag(rawValue: data[7]) else {
            
            return
        }
        
        var tempSeqNo = Int(data[0]) << 16
        tempSeqNo |= Int(data[1]) << 8
        tempSeqNo |= Int(data[2])
        seqNo = tempSeqNo
        
        var tempSrc = Int(data[3])
        tempSrc |= Int(data[4]) << 8
        src = tempSrc
        
        var tempDst = Int(data[5])
        tempDst |= Int(data[6]) << 8
        dst = tempDst
        
        // data[7]
        tag = tempTag
        
        var tempVendorID = Int(data[8]) << 8
        tempVendorID |= Int(data[9])
        
        param = Int(data[10])
        userData = Data(data[11..<20])
    }
    
    init?(mqttCommandData data: Data) {
        
        guard data.count == 20 else { return nil }
        
        guard let tempTag = Tag(rawValue: data[7]) else {
            
            return
        }
        
        var tempSrc = Int(data[3])
        tempSrc |= Int(data[4]) << 8
        src = tempSrc
        
        var tempDst = Int(data[5])
        tempDst |= Int(data[6]) << 8
        dst = tempDst
        
        tag = tempTag
        
        var tempVendorID = Int(data[8]) << 8
        tempVendorID |= Int(data[9])
        
        param = Int(data[10])
        userData = Data(data[11..<20])
    }
    
}

extension MeshCommand {
    
    /// `data[7]`
    enum Tag: UInt8 {
        
        case appToNode = 0xEA
        
        case nodeToApp = 0xEB
        
        case getStatus = 0xDA
        case responseStatus = 0xDB
        
        case lightStatus = 0xDC
        
        case onOff = 0xD0
        
        case brightness = 0xD2
        
        case singleChannel = 0xE2
        
        case replaceAddress = 0xE0
        
        case deviceAddressNotify = 0xE1
        
        case resetNetwork = 0xE3
        
        case syncDatetime = 0xE4
        
        case getDatetime = 0xE8
        
        case datetimeResponse = 0xE9
        
        case getFirmware = 0xC7
        
        case firmwareResponse = 0xC8
        
        case getGroups = 0xDD
        
        case responseGroups = 0xD4
        
        case groupAction = 0xD7
        
        case scene = 0xEE
        
        case loadScene = 0xEF
        
        case getScene = 0xC0
        
        case getSceneResponse = 0xC1
        
        case editAlarm = 0xE5
        
        case getAlarm = 0xE6
        
        case getAlarmResponse = 0xE7
        
        case setRemoteGroups = 0xEC
        
        case responseLeadingGroups = 0xD5
        
        case responseTralingGroups = 0xD6
        
        case uartModule = 0xFD
    }
    
    /// Sunricher private protocol
    enum SrIndentifier: UInt8 {
        
        case mac = 0x76
        
        case lightControlMode = 0x01
        
        case lightSwitchType = 0x07
        
        case special = 0x12
        
        case timezone = 0x1E
        
        case setLocation = 0x1A
        case getLocation = 0x1B
        
        case sunrise = 0x1C
        case sunset = 0x1D
        
        case syncInfo = 0x11
        
        case smartSwitchId = 0x72
        
        case sensorReport = 0x05
    
        /// AT5810S Uart Tx BL9032A-MW-20210322
        case sensorUartTx = 0x09
        
        case doorSensorOpen = 0x41
        case doorSensorClosed = 0x51
        case pirDetected = 0x42
        case pirNotDetected = 0x52
        case microwaveDetected = 0x43
        case microwaveNotDetected = 0x53
        case waterLeakDetected = 0x47
        case waterLeakNotDetected = 0x57
        case smokeDetected = 0x48
        case smokeNotDetected = 0x58
        case coDetected = 0x49
        case coNotDetected = 0x59
        case gasDetected = 0x4A
        case gasNotDetected = 0x5A
        case airQualityDetected = 0x4B
        case airQualityNotDetected = 0x5B
        case glassBreakDetected = 0x4C
        case glassBreakNotDetected = 0x5C
        case vibrationDetected = 0x4D
        case vibrationNotDetected = 0x5D
        
        case universalRemote = 0x16
        case pwmChannelsStatus = 0x78
        
        case multiSensorAction = 0x19        
        case curtainReport = 0x25
    }
    
    enum SrLightControlMode: UInt8 {
        
        case lightGammaCurve = 0x0E
        case lightOnOffDuration = 0x0F
        
        case getLightRunningMode = 0x00
        
        case setLightRunningMode = 0x05
        
        case setSyncLightRunningMode = 0x08
        
        case setLightRunningSpeed = 0x03
        
        case customLightRunningMode = 0x01
        
        case lightPwmFrequency = 0x0A
        
        case channelMode = 0x07
        
        case powerOnState = 0x10
    }
    
    enum SingleChannel: UInt8 {
        
        case red = 0x01
        case green = 0x02
        case blue = 0x03
        case rgb = 0x04
        case colorTemperature = 0x05
        // 0-255
        case w1 = 0x06
        case w2 = 0x07
        case w3 = 0x08
        case www = 0x09
        case rgbwww = 0x0A
    }
    
    public enum SensorReportType: UInt8 {
        
        /// Reserved type.
        case reserved = 0x00
        
        /// Door Sensor State, false -> Closed, true -> Open.
        case doorState = 0x01
        
        /// PIR Motion State, false -> Not Detected, true -> Detected.
        case pirMotion = 0x02
        
        /// Microware Motion State, false -> Not Detected, true -> Detected.
        case microwareMotion = 0x03
        
        /// LUX, int value.
        case lux = 0x04
        
        /// Temperature, int value
        case temperature = 0x05
    }
    
    public enum SensorReportKey {
        
        /// false -> Closed, true -> Open.
        case doorState
        
        /// false -> Not Detected, true -> Detected.
        case isDetected
        
        /// LUX, int value.
        case lux
        
        /// Temperature, int value.
        case temperature
    }
    
}

extension MeshCommand {
    
    public struct Address {
        
        /// Send command to the connected node.
        public static let connectedNode = 0x0000
        
        /// Sned command to all mesh devices.
        public static let all = 0xFFFF
        
    }
    
}

extension MeshCommand {
    
    /**
     - Parameter isSample: Default value is `false`.
     */
    public func send(isSample: Bool = false) {
        
        MeshManager.shared.send(self, isSample: isSample)
    }
    
}

// MARK: - Mesh

extension MeshCommand {
    
    /**
     __@Telink__.
     */
    public static func requestAddressMac(_ address: Int = Address.all) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .replaceAddress
        cmd.dst = address
        cmd.param = 0xFF
        cmd.userData[0] = 0xFF
        cmd.userData[1] = 0x01
        cmd.userData[2] = 0x10
        return cmd
    }
    
    /**
     __@Telink__
     Change device address with new address.
     
     - Note: After change the address, you need to power off and restart all devices.
     
     - Parameters:
        - address: `Int(MeshDevice.address)` or `MeshCommand.Address.connectedNode`, default is `.connectedNode`
        - newAddress: The new address, range is [1, 255].
     */
    public static func changeAddress(_ address: Int, withNewAddress newAddress: Int, macData: Data) -> MeshCommand {
        
        assert(newAddress > 0 && newAddress <= 0xFF, "New address out of range [1, 255].")
        assert(macData.count == 6, "macData.count != 6")
        
        var cmd = MeshCommand()
        cmd.tag = .replaceAddress
        cmd.dst = address
        cmd.param = newAddress & 0xFF
        cmd.userData[0] = 0x00
        cmd.userData[1] = 0x01
        cmd.userData[2] = 0x10
        cmd.userData[3] = macData[5]
        cmd.userData[4] = macData[4]
        cmd.userData[5] = macData[3]
        cmd.userData[6] = macData[2]
        cmd.userData[7] = macData[1]
        cmd.userData[8] = macData[0]
        return cmd
    }
    
    public static func changeAddress(_ address: Int, withNewAddress newAddress: Int) -> MeshCommand {
        
        assert(newAddress > 0 && newAddress <= 0xFF, "New address out of range [1, 255].")
        
        var cmd = MeshCommand()
        cmd.tag = .replaceAddress
        cmd.dst = address
        cmd.param = newAddress & 0xFF
        cmd.userData[0] = 0x00
        return cmd
    }
    
    /**
     __@Telink__
     Restore to the default (factory) network.
     
     - Note: After reset the network, you need to power off and restart all devices.
     
     - Parameters:
        - address: `Int(MeshDevice.address)` or `MeshCommand.Address.connectedNode`, default is `.connectedNode`
     */
    public static func resetNetwork(_ address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .resetNetwork
        cmd.dst = address
        // 0x01 reset network name to default value, 0x00 reset to `out_of_mesh`.
        cmd.param = 0x01
        return cmd
    }
    
}

// MARK: - Request

extension MeshCommand {
    
    /**
     __@Sunricher__
     Request the MAC and MeshDeviceType of the MeshDevice.
     
     - Parameter address: `Int(MeshDevice.address)` or `MeshCommand.Address.connectedNode | .all`.
     */
    public static func requestMacDeviceType(_ address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.param = 0x20
        cmd.userData[0] = 0x76
        return cmd
    }
    
    /// Change the light type, if the deviceType isnot support change device type, will return a command `requestMacDeviceType`.
    public static func changeLightType(_ address: Int, currentDeviceType: MeshDeviceType, newLightType: MeshDeviceType.LightType) -> MeshCommand {
        guard currentDeviceType.isSupportChangeDeviceType else {
            NSLog("changeLightType command error, currentDeviceType doesn't support change light type function.", "")
            return requestMacDeviceType(address)
        }
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.param = 0x20
        cmd.userData[0] = 0x00
        cmd.userData[1] = 0x01
        cmd.userData[2] = newLightType.lightTypeValue | (currentDeviceType.rawValue2 & 0xF0)
        return cmd
    }
    
    /// Reset light to IO Settings. You have to re-power the device after reset.
    public static func resetLightType(_ address: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.param = 0x20
        cmd.userData[0] = 0x00
        cmd.userData[1] = 0xFF
        return cmd
    }
    
}

// MARK: - Control

extension MeshCommand {
    
    /**
     __@Sunricher__
     Turn on/off the device.
     
     - Parameters:
        - address: `Int(MeshDevice.address)` or `MeshCommand.Address.connectedNode | .all`.
        - isOn: Is turn on.
        - delay: Delay time (millisecond), range is [0x00, 0xFFFF], default is 0.
     */
    public static func turnOnOff(_ address: Int, isOn: Bool, delay: UInt16 = 0) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .onOff
        cmd.dst = address
        cmd.param = isOn ? 0x01 : 0x00
        cmd.userData[0] = UInt8(delay & 0xFF)
        cmd.userData[1] = UInt8((delay >> 8) & 0xFF)
        return cmd
    }
    
    /**
     __@Sunricher__
     
     - Parameters:
        - address: `Int(MeshDevice.address)` or `MeshCommand.Address.connectedNode | .all`.
        - value: Range [0, 100].
     */
    public static func setBrightness(_ address: Int, value: Int) -> MeshCommand {
        
        assert(value >= 0 && value <= 100, "value out of range [0, 100].")
        
        var cmd = MeshCommand()
        cmd.tag = .brightness
        cmd.dst = address
        cmd.param = value
        return cmd
    }
    
    /**
     __@Sunricher__
     
     - Parameters:
        - address: `Int(MeshDevice.address)` or `MeshCommand.Address.connectedNode | .all`.
        - value: Range [0, 100], 0 means the coolest color, 100 means the warmest color.
     */
    public static func setColorTemperature(_ address: Int, value: Int) -> MeshCommand {
        
        assert(value >= 0 && value <= 100, "value out of range [0, 100].")
        
        var cmd = MeshCommand()
        cmd.tag = .singleChannel
        cmd.dst = address
        cmd.param = Int(SingleChannel.colorTemperature.rawValue)
        cmd.userData[0] = UInt8(value)
        cmd.userData[1] = 0b0000_0000
        return cmd
    }
    
    /// Value range [0, 255]
    public static func setW1(_ address: Int, value: Int, ctwDisabled: Bool) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .singleChannel
        cmd.dst = address
        cmd.param = Int(SingleChannel.w1.rawValue)
        cmd.userData[0] = UInt8(value)
        cmd.userData[1] = ctwDisabled ? 1 : 0
        return cmd
    }
    
    /// Value range [0, 255]
    public static func setW2(_ address: Int, value: Int, ctwDisabled: Bool) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .singleChannel
        cmd.dst = address
        cmd.param = Int(SingleChannel.w2.rawValue)
        cmd.userData[0] = UInt8(value)
        cmd.userData[1] = ctwDisabled ? 1 : 0
        return cmd
    }
    
    /// Value range [0, 255]
    public static func setW3(_ address: Int, value: Int, ctwDisabled: Bool) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .singleChannel
        cmd.dst = address
        cmd.param = Int(SingleChannel.w3.rawValue)
        cmd.userData[0] = UInt8(value)
        cmd.userData[1] = ctwDisabled ? 1 : 0
        return cmd
    }
    
    /**
     2025-01-11 V7.4, ROM: 144K,
     更新内容：
     增加新两路继电器灯&窗帘的程序代码：
     a. 新两路继电器灯：dimmer26, 主类型：0x01, 子类型：0x16,
     b. 新两路继电器窗帘：curtain26, 主类型：0x07, 子类型：0x06,

     对于灯：
     a. 使用light_on\light_off指令时，2个灯同时亮和2个灯同时熄灭，
     b. 使用set_www指令，可以对2个灯任意控制，参考私有协议文档里之前增加的标准指令，1.1.8 set_www,
     /// 设置2路继电器灯：

     e2 11 02 09 00 01 00 00 00 00 00 00 00 // relay2 on,

     e2 11 02 09 00 00 00 00 00 00 00 00 00 // relay2 off,

     e2 11 02 09 01 00 00 00 00 00 00 00 00 // relay1 on,

     e2 11 02 09 00 00 00 00 00 00 00 00 00 // relay1 off,

     e2 11 02 09 01 01 00 00 00 00 00 00 00 // relay1\relay2 on,

     e2 11 02 09 00 00 00 00 00 00 00 00 00 // relay1\relay2 off,

     /// 上报状态：

     dc 11 02 26 3d 00 64 00 00 00 00 00 00 // relay2 on,

     dc 11 02 26 5f 00 00 00 00 00 00 00 00 // relay2 off,

     dc 11 02 26 7a 64 00 00 00 00 00 00 00 // relay1 on,

     dc 11 02 26 9e 00 00 00 00 00 00 00 00 // relay1 off,

     对于窗帘：
     a. 使用light_on\light_off指令时，light_on窗帘打开，light_off窗帘关闭，
     b. 窗帘控制，参考私有协议，1.6.15 遥控器控制马达命令，
     c. 也可以使用K5&RS-CMD和K12&RS-CMD的窗帘模式来控制，
     d. 由于不能确定窗帘的准确位置，所以，现在是没有场景的功能的，
     /// 窗帘控制：

     EA 11 02 10 25 20 00 00 00 00 00 00 00 // motor stop,

     EA 11 02 10 25 20 01 00 00 00 00 00 00 // motor forward\stop,

     EA 11 02 10 25 20 02 00 00 00 00 00 00 // motor backward\stop,
     */
    public static func setWww(_ address: Int, w1: Int, w2: Int, w3: Int, ctwDisabled: Bool) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .singleChannel
        cmd.dst = address
        cmd.param = Int(SingleChannel.www.rawValue)
        cmd.userData[0] = UInt8(w1)
        cmd.userData[1] = UInt8(w2)
        cmd.userData[2] = UInt8(w3)
        cmd.userData[3] = ctwDisabled ? 1 : 0
        return cmd
    }
    
    public static func setDoubleChannelsOnOff(_ address: Int, isChannel1On: Bool, isChannel2On: Bool) -> MeshCommand {
        return setWww(address, w1: isChannel1On ? 1 : 0, w2: isChannel2On ? 1 : 0, w3: 0, ctwDisabled: false)
    }
    
    /**
     __@Sunricher__
     
     - Parameters:
        - address: `Int(MeshDevice.address)` or `MeshCommand.Address.connectedNode | .all`.
        - value: Range [0, 100].
     */
    public static func setWhitePercentage(_ address: Int, value: Int) -> MeshCommand {
        
        var currentValue = Int(Float(value) * 2.55)
        if currentValue > 255 {
            currentValue = 255
        }
        
        var cmd = MeshCommand()
        cmd.tag = .singleChannel
        cmd.dst = address
        cmd.param = Int(SingleChannel.colorTemperature.rawValue)
        cmd.userData[0] = UInt8(currentValue)
        cmd.userData[1] = 0b0001_0000
        return cmd
    }
    
    /**
     __@Sunricher__
     
     - Parameters:
        - address: `Int(MeshDevice.address)` or `MeshCommand.Address.connectedNode | .all`.
        - value: Range [0, 255].
     */
    public static func setRed(_ address: Int, value: Int) -> MeshCommand {
        
        assert(value >= 0 && value <= 255, "value out of range [0, 255].")
        
        var cmd = MeshCommand()
        cmd.tag = .singleChannel
        cmd.dst = address
        cmd.param = Int(SingleChannel.red.rawValue)
        cmd.userData[0] = UInt8(value)
        return cmd
    }
    
    /**
      __@Sunricher__
     
     - Parameters:
        - address: `Int(MeshDevice.address)` or `MeshCommand.Address.connectedNode | .all`.
        - value: Range [0, 255].
     */
    public static func setGreen(_ address: Int, value: Int) -> MeshCommand {
        
        assert(value >= 0 && value <= 255, "value out of range [0, 255].")
        
        var cmd = MeshCommand()
        cmd.tag = .singleChannel
        cmd.dst = address
        cmd.param = Int(SingleChannel.green.rawValue)
        cmd.userData[0] = UInt8(value)
        return cmd
    }
    
    /**
     __@Sunricher__
     
     - Parameters:
        - address: `Int(MeshDevice.address)` or `MeshCommand.Address.connectedNode | .all`.
        - value: Range [0, 255].
     */
    public static func setBlue(_ address: Int, value: Int) -> MeshCommand {
        
        assert(value >= 0 && value <= 255, "value out of range [0, 255].")
        
        var cmd = MeshCommand()
        cmd.tag = .singleChannel
        cmd.dst = address
        cmd.param = Int(SingleChannel.blue.rawValue)
        cmd.userData[0] = UInt8(value)
        return cmd
    }
    
    /**
     __@Sunricher__
     
     - Parameters:
        - address: `Int(MeshDevice.address)` or `MeshCommand.Address.connectedNode | .all`.
        - red: Range [0, 255].
         - green: Range [0, 255].
         - blue: Range [0, 255].
     */
    public static func setRgb(_ address: Int, red: Int, green: Int, blue: Int) -> MeshCommand {
        
        assert(red >= 0 && red <= 255, "red out of range [0, 255].")
        assert(green >= 0 && green <= 255, "green out of range [0, 255].")
        assert(blue >= 0 && blue <= 255, "blue out of range [0, 255].")
        
        var cmd = MeshCommand()
        cmd.tag = .singleChannel
        cmd.dst = address
        cmd.param = Int(SingleChannel.rgb.rawValue)
        cmd.userData[0] = UInt8(red)
        cmd.userData[1] = UInt8(green)
        cmd.userData[2] = UInt8(blue)
        return cmd
    }
    
}

// MARK: - Date-time

extension MeshCommand {
    
    public static func syncDatetime(_ address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .syncDatetime
        cmd.dst = address
        
        let now = Date()
        let calendar = Calendar.current
        let dateComponent = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        let year = dateComponent.year ?? 2000
        let month = dateComponent.month ?? 1
        let day = dateComponent.day ?? 1
        let hour = dateComponent.hour ?? 0
        let minute = dateComponent.minute ?? 0
        let second = dateComponent.second ?? 0
        
        cmd.param = (year & 0xFF)
        cmd.userData[0] = UInt8((year >> 8) & 0xFF)
        cmd.userData[1] = UInt8(month & 0xFF)
        cmd.userData[2] = UInt8(day & 0xFF)
        cmd.userData[3] = UInt8(hour & 0xFF)
        cmd.userData[4] = UInt8(minute & 0xFF)
        cmd.userData[5] = UInt8(second & 0xFF)
        return cmd
    }
    
    public static func getDatetime(_ address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .getDatetime
        cmd.dst = address
        cmd.param = 0x10
        return cmd
    }
}

// MARK: - OTA

extension MeshCommand {
    
    public static func getFirmwareVersion(_ address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .getFirmware
        cmd.dst = address
        cmd.param = 0x20;
        return cmd
    }
    
}

// MARK: - Light Running Mode

extension MeshCommand {
    
    public struct LightRunningMode {
        
        public enum State: UInt8 {
            
            case stopped = 0x00
            case defaultMode = 0x01
            case customMode = 0x02
        }
        
        public enum DefaultMode: UInt8 {
            
            case colorfulMixed = 0x01
            case redShade = 0x02
            case greenShade = 0x03
            case blueShade = 0x04
            case yellowShade = 0x05
            case cyanShade = 0x06
            case purpleShade = 0x07
            case whiteShade = 0x08
            case redGreenShade = 0x09
            case redBlueShade = 0x0A
            case greenBlueShade = 0x0B
            case colorfulStrobe = 0x0C
            case redStrobe = 0x0D
            case greenStrobe = 0x0E
            case blueStrobe = 0x0F
            case yellowStrobe = 0x10
            case cyanStrobe = 0x11
            case purpleStrobe = 0x12
            case whiteStrobe = 0x13
            case colorfulJump = 0x14
            
            public static let all: [DefaultMode] = (0x01...0x14).map { return DefaultMode(rawValue: $0)! }
        }
        
        public enum CustomMode: UInt8 {
            
            case ascendShade = 0x01
            case descendShade = 0x02
            case ascendDescendShade = 0x03
            case mixedShade = 0x04
            case jump = 0x05
            case strobe = 0x06
            
            public static let all: [CustomMode] = (0x01...0x06).map { CustomMode(rawValue: $0)! }
        }
        
        public struct Color {
            
            public var red: UInt8
            public var green: UInt8
            public var blue: UInt8
            
            public var uiColor: UIColor {
                
                return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
            }
            
            public init(red: UInt8, green: UInt8, blue: UInt8) {
                
                self.red = red
                self.green = green
                self.blue = blue
            }
            
            public init(color: UIColor) {
                
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                color.getRed(&red, green: &green, blue: &blue, alpha: nil)
                
                self.red = UInt8(red * 255.0)
                self.green = UInt8(green * 255.0)
                self.blue = UInt8(blue * 255.0)
            }
        }
        
        public var address: Int
        
        public var state: State
        
        public var defaultMode: DefaultMode = .colorfulMixed
        
        public var customMode: CustomMode = .ascendShade
        
        /// range [0x00, 0x0F]
        public var speed: Int = 0x00
        
        /// range [0x01, 0x10]
        public var customModeId: Int = 0x01
        
        /// It's always empty if you don't change it.
        public var userValues: [String: Any] = [:]
        
        public init(address: Int, state: State) {
            
            self.address = address
            self.state = state
        }
        
        init?(address: Int, userData: Data) {
            
            guard userData[0] == SrIndentifier.lightControlMode.rawValue,
                  userData[1] == SrLightControlMode.getLightRunningMode.rawValue,
                  let state = State(rawValue: userData[4]) else {
                
                return nil
            }
            
            self.address = address
            self.speed = max(0x00, min(0x0F, Int(userData[2])))
            self.state = state
            
            switch state {
            
            case .stopped:
                break
                
            case .defaultMode:
                self.defaultMode = DefaultMode(rawValue: userData[5]) ?? self.defaultMode
                
            case .customMode:
                self.customModeId = max(0x01, min(0x10, Int(userData[5])))
                self.customMode = CustomMode(rawValue: userData[6]) ?? self.customMode
            }
        }
    }
    
    public static func getLightRunningMode(_ address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.lightControlMode.rawValue
        cmd.userData[1] = SrLightControlMode.getLightRunningMode.rawValue
        return cmd
    }
    
    public static func updateLightRunningMode(_ mode: LightRunningMode) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = mode.address
        cmd.userData[0] = SrIndentifier.lightControlMode.rawValue
        cmd.userData[1] = SrLightControlMode.setLightRunningMode.rawValue
        cmd.userData[2] = mode.state.rawValue
        
        switch mode.state {
        
        case .stopped:
            break
            
        case .defaultMode:
            cmd.userData[3] = mode.defaultMode.rawValue
            
        case .customMode:
            cmd.userData[3] = UInt8(mode.customModeId)
            cmd.userData[4] = mode.customMode.rawValue
        }
        
        return cmd
    }
    
    /// speed range: [0x00, 0x0F], 0x00 -> fastest, 0x0F -> slowest
    public static func updateLightRunningSpeed(_ address: Int, speed: Int) -> MeshCommand {
        
        assert(speed >= 0x00 && speed <= 0x0F, "speed \(speed) is out of range [0x00, 0x0F]")
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.lightControlMode.rawValue
        cmd.userData[1] = SrLightControlMode.setLightRunningSpeed.rawValue
        cmd.userData[2] = UInt8(speed)
        return cmd
    }
    
    // cmd.userData[2]
    // 0x00, read custom mode
    // 0x01, add
    // 0x02, remove
    
    public static func getLightRunningCustomModeIdList(_ address: Int) -> MeshCommand {
        
        // 0x00 for mode id list
        return getLightRunningCustomModeColors(address, modeId: 0x00)
    }
    
    /// modeId range [0x01, 0x10]
    public static func getLightRunningCustomModeColors(_ address: Int, modeId: Int) -> MeshCommand {
        
        assert(modeId >= 0x00 && modeId <= 0x10, "modeId out of range [0x00, 0x10]")
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.lightControlMode.rawValue
        cmd.userData[1] = SrLightControlMode.customLightRunningMode.rawValue
        cmd.userData[2] = 0x00
        cmd.userData[3] = UInt8(modeId)
        return cmd
    }
    
    /// - Parameters:
    ///     - modeId: range [0x01, 0x10]
    ///     - colors: colors.count range [1, 5]
    public static func updateLightRunningCustomModeColors(_ address: Int, modeId: Int, colors: [LightRunningMode.Color]) -> [MeshCommand] {
        
        assert(modeId >= 0x01 && modeId <= 0x10, "modeId out of range [0x00, 0x10]")
        assert(colors.count > 0 && colors.count <= 5, "colors.count out of range [1, 5]")
        
        var commands: [MeshCommand] = []
        
        for i in 0..<colors.count {
            
            let index = i + 1
            let color = colors[i]
            
            var cmd = MeshCommand()
            cmd.tag = .appToNode
            cmd.dst = address
            cmd.userData[0] = SrIndentifier.lightControlMode.rawValue
            cmd.userData[1] = SrLightControlMode.customLightRunningMode.rawValue
            cmd.userData[2] = 0x01
            cmd.userData[3] = UInt8(modeId)
            cmd.userData[4] = UInt8(index)
            cmd.userData[5] = color.red
            cmd.userData[6] = color.green
            cmd.userData[7] = color.blue
            
            commands.append(cmd)
        }
        
        return commands
    }
    
    public static func removeLightRunningCustomModeId(_  address: Int, modeId: Int) -> MeshCommand {
        
        assert(modeId >= 0x01 && modeId <= 0x10, "modeId out of range [0x00, 0x10]")
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.lightControlMode.rawValue
        cmd.userData[1] = SrLightControlMode.customLightRunningMode.rawValue
        cmd.userData[2] = 0x02
        cmd.userData[3] = UInt8(modeId)
        return cmd
    }
    
}

// MARK: - Groups

extension MeshCommand {
    
    public static func getGroups(_ address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .getGroups
        cmd.dst = address
        cmd.param = 0x20
        cmd.userData[0] = 0x01
        return cmd
    }
    
    public static func getGroupDevices(_ groupId: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .replaceAddress
        cmd.dst = groupId
        // !!!param and userData[0] must be 0xFF
        cmd.param = 0xFF
        cmd.userData[0] = 0xFF
        return cmd
    }
    
    public static func addGroup(_ groupId: Int, address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .groupAction
        cmd.dst = address
        cmd.param = 0x01
        cmd.userData[0] = UInt8(groupId & 0xFF)
        cmd.userData[1] = 0x80
        return cmd
    }
    
    public static func deleteGroup(_ groupId: Int, address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .groupAction
        cmd.dst = address
        cmd.param = 0x00
        cmd.userData[0] = UInt8(groupId & 0xFF)
        cmd.userData[1] = 0x80
        return cmd
    }
    
}

// MARK: - Group Sync

extension MeshCommand {
    
    public enum GroupSyncTag: UInt8 {
        case none = 0
        case bytes16 = 1
        case bytes32 = 2
    }
    
    public static func getGroupSyncInfo(_ address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x11
        cmd.userData[1] = 0x00
        return cmd
    }
    
    /// Add group and set as a sync master.
    public static func addGroupSync(_ groupId: Int, address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .groupAction
        cmd.dst = address
        cmd.param = 0x03
        cmd.userData[0] = UInt8(groupId & 0xFF)
        cmd.userData[1] = 0x80
        return cmd
    }
    
    /// Remove the sync master only.
    public static func deleteGroupSync(_ groupId: Int, address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .groupAction
        cmd.dst = address
        cmd.param = 0x02
        cmd.userData[0] = UInt8(groupId & 0xFF)
        cmd.userData[1] = 0x80
        return cmd
    }
    
}

// MARK: - Advanced Configuration

extension MeshCommand {
    
    public enum LightGamma: UInt8 {
        case gamma1_0 = 0
        case gamma1_5 = 1
        case gamma1_8 = 2
        case gamma2_0 = 3
        case gamma2_5 = 4
        case gamma3_5 = 5
        case gamma5_0 = 6
    }
    
    /// - Parameter gamma: 1.0, 1.5, 1.8, 2.0, 2.5, 3.5, 5.0
    public static func setLightGammaCurve(_ address: Int, gamma: LightGamma) -> MeshCommand {
                
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.lightControlMode.rawValue
        cmd.userData[1] = SrLightControlMode.lightGammaCurve.rawValue
        cmd.userData[2] = 0x01 // set
        cmd.userData[3] = gamma.rawValue
        return cmd
    }
    
    public static func getLightGammaCurve(_ address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.lightControlMode.rawValue
        cmd.userData[1] = SrLightControlMode.lightGammaCurve.rawValue
        cmd.userData[2] = 0x00 // get
        return cmd
    }
    
    
    /// - Parameter duration: Range `[1, 0xFFFF]`, unit `second(s)`.
    public static func setLightOnOffDuration(_ address: Int, duration: Int) -> MeshCommand {
                
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.lightControlMode.rawValue
        cmd.userData[1] = SrLightControlMode.lightOnOffDuration.rawValue
        cmd.userData[2] = 0x01 // set
        cmd.userData[3] = UInt8(duration & 0xFF)
        cmd.userData[4] = UInt8((duration >> 8) & 0xFF)
        return cmd
    }
    
    public static func getLightOnOffDuration(_ address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.lightControlMode.rawValue
        cmd.userData[1] = SrLightControlMode.lightOnOffDuration.rawValue
        cmd.userData[2] = 0x00 // get
        return cmd
    }
    
    // Light switch type - push button, 3 ways button
    
    public enum LightSwitchType: UInt8 {
        
        case normalOnOff = 0x01
        case pushButton = 0x02
        case threeChannels = 0x03
    }
    
    public static func setLightSwitchType(_ address: Int, switchType: LightSwitchType) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.lightSwitchType.rawValue
        cmd.userData[1] = 0x01 // set
        cmd.userData[2] = switchType.rawValue
        return cmd
    }
    
    public static func getLightSwitchType(_ address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.lightSwitchType.rawValue
        cmd.userData[1] = 0x00 // get
        return cmd
    }
    
    // Pwm frequency
    
    /// - Parameter frequency: Range `[500, 10_000]`, unit `Hz`.
    public static func setLightPwmFrequency(_ address: Int, frequency: Int) -> MeshCommand {
                
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.lightControlMode.rawValue
        cmd.userData[1] = SrLightControlMode.lightPwmFrequency.rawValue
        cmd.userData[2] = 0x01 // set
        cmd.userData[3] = UInt8(frequency & 0xFF)
        cmd.userData[4] = UInt8((frequency >> 8) & 0xFF)
        return cmd
    }
    
    public static func getLightPwmFrequency(_ address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.lightControlMode.rawValue
        cmd.userData[1] = SrLightControlMode.lightPwmFrequency.rawValue
        cmd.userData[2] = 0x00 // get
        return cmd
    }
    
    // Enable pairing
    
    /// The device enters pairing mode for 5 seconds after receiving this command.
    public static func enablePairing(_ address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.special.rawValue
        cmd.userData[1] = 0x01 // enable pairing
        return cmd
    }
    
    // Enable rgb independence
    
    /// If `true`, the other channels will be closed when change the RGB,
    /// the RGB will be closed when change the other channels.
    public static func setRgbIndependence(_ address: Int, isEnabled: Bool) -> MeshCommand {
                
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.lightControlMode.rawValue
        cmd.userData[1] = SrLightControlMode.channelMode.rawValue
        cmd.userData[2] = 0x04 // RGB independence
        cmd.userData[3] = 0x01 // set
        cmd.userData[4] = isEnabled ? 0x01 : 0x00
        return cmd
    }
    
    public static func getRgbIndependence(_ address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.lightControlMode.rawValue
        cmd.userData[1] = SrLightControlMode.channelMode.rawValue
        cmd.userData[2] = 0x04 // RGB independence
        cmd.userData[3] = 0x00 // get 
        return cmd
    }
    
    public static func getPowerOnState(_ address: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.lightControlMode.rawValue
        cmd.userData[1] = SrLightControlMode.powerOnState.rawValue
        cmd.userData[2] = 0x00 // get
        return cmd
    }
    
    public static func setPowerOnState(_ address: Int, level: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.lightControlMode.rawValue
        cmd.userData[1] = SrLightControlMode.powerOnState.rawValue
        cmd.userData[2] = 0x01 // set
        cmd.userData[3] = UInt8(level)
        return cmd 
    }
    
    // Sensor configuration
    
    // Smart switch configuration
    
}

// MARK: - Sunrise & Sunset

public enum SunriseSunsetType: UInt8 {
    
    case sunrise = 0x1C
    case sunset = 0x1D
}

public enum SunriseSunsetActionType: UInt8 {
    
    case onOff = 0x01
    case scene = 0x02
    case custom = 0x04
}

public protocol SunriseSunsetAction {
    
    var type: SunriseSunsetType { get set }
    
    var actionType: SunriseSunsetActionType { get }
    
    var isEnabled: Bool { get set }
    
    var description: String { get }
}

public struct SunriseSunsetOnOffAction: SunriseSunsetAction {
    
    public var type: SunriseSunsetType
    
    public let actionType: SunriseSunsetActionType = .onOff
    
    /// Default true
    public var isEnabled: Bool = true
    
    /// Default true
    public var isOn: Bool = true
    
    /// Range [0x0000, 0xFFFF], default 0
    public var duration: Int = 0
    
    public init(type: SunriseSunsetType) {
        self.type = type
    }
    
    public var description: String {
        
        return "OnOffAction \(type), isEnabled \(isEnabled), isOn \(isOn), duration \(duration)"
    }
}

public struct SunriseSunsetSceneAction: SunriseSunsetAction {
    
    public var type: SunriseSunsetType
    
    public let actionType: SunriseSunsetActionType = .scene
    
    /// Default rue
    public var isEnabled: Bool = true
    
    /// Range [1, 16], default 1
    public var sceneID: Int = 1
    
    public init(type: SunriseSunsetType) {
        self.type = type
    }
    
    public var description: String {
        
        return "SceneAction \(type), isEnabled \(isEnabled), sceneID \(sceneID)"
    }
}

public struct SunriseSunsetCustomAction: SunriseSunsetAction {
    
    public var type: SunriseSunsetType
    
    public let actionType: SunriseSunsetActionType = .custom
    
    /// Default true
    public var isEnabled: Bool = true
    
    /// Range [0, 100], default 100
    public var brightness: Int = 100
    
    /// Range [0, 255], default 255
    public var red: Int = 255
    
    /// Range [0, 255], default 255
    public var green: Int = 255
    
    /// Range [0, 255], default 255
    public var blue: Int = 255
    
    /// CT range [0, 100], White range [0, 255], default 100
    public var ctOrW: Int = 100
    
    /// Range [0x0000, 0xFFFF], default 0
    public var duration: Int = 0
    
    public init(type: SunriseSunsetType) {
        self.type = type
    }
    
    public var description: String {
        
        return "CustomAction \(type), isEnabled \(isEnabled), Brightness \(brightness), RGBW \(red) \(green) \(blue) \(ctOrW), duration \(duration)"
    }
}

extension MeshCommand {
    
    /// Only support single device address, don't use `0xFFFF` or `0x8---` as a adress.
    /// If it's East area, `isNegative = false`, else `isNegative = true`.
    public static func setTimezone(_ address: Int, hour: Int, minute: Int, isNegative: Bool) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        // the device won't sync the timezone to other devices, so I use the broadcast to send it.
        // cmd.dst = address
        cmd.dst = 0xFFFF
        cmd.userData[0] = SrIndentifier.timezone.rawValue
        cmd.userData[1] = 0x01 // set
        cmd.userData[2] = UInt8(abs(hour)) | (isNegative ? 0x80 : 0x00)
        cmd.userData[3] = UInt8(minute)
        return cmd
    }
    
    public static func getTimezone(_ address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.timezone.rawValue
        cmd.userData[1] = 0x00 // get
        return cmd
    }
    
    /// Only suuport single device address, don't use `0xFFFF` or `0x8---` as a adress.
    public static func setLocation(_ address: Int, longitude: Float, latitude: Float) -> MeshCommand {
        
        // 1-4
        let longitudeData = longitude.data
        // 5-8
        let latitudeData = latitude.data
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.setLocation.rawValue
        cmd.userData[1] = longitudeData[0]
        cmd.userData[2] = longitudeData[1]
        cmd.userData[3] = longitudeData[2]
        cmd.userData[4] = longitudeData[3]
        cmd.userData[5] = latitudeData[0]
        cmd.userData[6] = latitudeData[1]
        cmd.userData[7] = latitudeData[2]
        cmd.userData[8] = latitudeData[3]
        return cmd
    }
    
    public static func getLocation(_ address: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.getLocation.rawValue
        return cmd
    }
    
    public static func getSunriseSunset(_ address: Int, type: SunriseSunsetType) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = type.rawValue
        return cmd
    }
    
    public static func setSunriseSunsetAction(_ address: Int, action: SunriseSunsetAction) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = action.type.rawValue
        cmd.userData[1] = action.actionType.rawValue | (action.isEnabled ? 0x00 : 0x80)
        
        switch action.actionType {
            
        case .onOff:
            
            guard let onOffAction = action as? SunriseSunsetOnOffAction else { return cmd }
            cmd.userData[2] = onOffAction.isOn ? 0x01 : 0x00
            cmd.userData[3] = 0x00
            cmd.userData[4] = 0x00
            cmd.userData[5] = 0x00
            cmd.userData[6] = UInt8(onOffAction.duration & 0xFF)
            cmd.userData[7] = UInt8((onOffAction.duration >> 8) & 0xFF)
            cmd.userData[8] = 0x00 // light endpoint bit, unsupport now
            
        case .scene:
            
            guard let sceneAction = action as? SunriseSunsetSceneAction else { return cmd }
            cmd.userData[2] = UInt8(sceneAction.sceneID)
            
        case .custom:
            
            guard let customAction = action as? SunriseSunsetCustomAction else { return cmd }
            cmd.userData[2] = UInt8(customAction.brightness)
            cmd.userData[3] = UInt8(customAction.red)
            cmd.userData[4] = UInt8(customAction.green)
            cmd.userData[5] = UInt8(customAction.blue)
            cmd.userData[6] = UInt8(customAction.ctOrW)
            cmd.userData[7] = UInt8(customAction.duration & 0xFF)
            cmd.userData[8] = UInt8((customAction.duration >> 8) & 0xFF)
        }
        
        return cmd
    }
    
    public static func clearSunriseSunsetContent(_ address: Int, type: SunriseSunsetType) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = type.rawValue
        cmd.userData[1] = 0xC0 // clear
        return cmd
    }
    
    public static func enableSunriseSunset(_ address: Int, type: SunriseSunsetType, isEnabled: Bool) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = type.rawValue
        cmd.userData[1] = isEnabled ? 0xE0 : 0xF0 // enable 0xE0, disable 0xF0
        return cmd
    }
    
}

// MARK: - Scenes

extension MeshCommand {
    
    public struct Scene {
        
        public var sceneID: Int
        
        /// Range [0, 100], if `brightness = 0` means `power off`.
        public var brightness: Int = 100
        
        /// Range [0, 255]
        public var red: Int = 255
        
        /// Range [0, 255]
        public var green: Int = 255
        
        /// Range [0, 255]
        public var blue: Int = 255
        
        /// CCT range [0, 100], White range [0, 255]
        public var ctOrW = 100
        
        /// Range [0, 65535]
        public var duration: Int = 0
        
        public init(sceneID: Int) {
            
            self.sceneID = sceneID
        }
    }
    
    public static func addOrUpdateScene(_ address: Int, scene: Scene) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .scene
        cmd.dst = address
        cmd.param = 0x01 // add
        cmd.userData[0] = UInt8(scene.sceneID)
        cmd.userData[1] = UInt8(scene.brightness)
        cmd.userData[2] = UInt8(scene.red)
        cmd.userData[3] = UInt8(scene.green)
        cmd.userData[4] = UInt8(scene.blue)
        cmd.userData[5] = UInt8(scene.ctOrW)
        cmd.userData[6] = UInt8(scene.duration & 0xFF)
        cmd.userData[7] = UInt8(scene.duration >> 8)
        return cmd
    }
    
    public static func deleteScene(_ address: Int, sceneID: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .scene
        cmd.dst = address
        cmd.param = 0x00 // delete
        cmd.userData[0] = UInt8(sceneID)
        return cmd
    }
    
    public static func clearScenes(_ address: Int) -> MeshCommand {
        
        return deleteScene(address, sceneID: 0xFF)
    }
    
    public static func loadScene(_ address: Int, sceneID: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .loadScene
        cmd.dst = address
        cmd.param = sceneID
        return cmd
    }
    
    /// The `address` must be a device address. sceneID range [1, 16]
    public static func getSceneDetail(_ address: Int, sceneID: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .getScene
        cmd.dst = address
        cmd.param = 0x20
        cmd.userData[0] = UInt8(sceneID)
        return cmd
    }
    
}

// MARK: - Alarm

public enum AlarmActionType: UInt8 {
    
    case off = 0
    case on = 1
    case scene = 2
}

public enum AlarmDayType: UInt8 {
    
    case day = 0
    case week = 1
}

public protocol AlarmProtocol {
    
    var alarmID: Int { get set }
    
    var actionType: AlarmActionType { get set }
    
    var dayType: AlarmDayType { get }
    
    var isEnabled: Bool { get set }
    
    var hour: Int { get set }
    
    var minute: Int { get set }
    
    var second: Int { get set }
    
    var sceneID: Int { get set }
}

extension AlarmProtocol {
    
    var alarmEvent: UInt8 {
        
        return actionType.rawValue
            | (dayType.rawValue << 4)
            | UInt8(isEnabled ? 0x80 : 0x00)
    }
}

public struct DayAlarm: AlarmProtocol {
    
    public var alarmID: Int
    
    public var actionType: AlarmActionType = .off
    
    public let dayType: AlarmDayType = .day
    
    public var isEnabled: Bool = true
    
    public var hour: Int = 10
    
    public var minute: Int = 10
    
    public var second: Int = 0
    
    public var sceneID: Int = 0
    
    public var month: Int = 1
    
    public var day: Int = 1
    
    public init(alarmID: Int) {
        self.alarmID = alarmID
    }
    
}

public struct WeekAlarm: AlarmProtocol {
    
    public var alarmID: Int
    
    public var actionType: AlarmActionType = .off
    
    public let dayType: AlarmDayType = .week
    
    public var isEnabled: Bool = true
    
    public var hour: Int = 10
    
    public var minute: Int = 10
    
    public var second: Int = 0
    
    public var sceneID: Int = 0
    
    /// bit0 Sun, bit1 Mon, bit2 Tue, bit3 Wed, bit4 Thu, bit5 Fri, bit6 Sat,
    /// bit7 must be 0.
    public var week: Int = 0
    
    public init(alarmID: Int) {
        self.alarmID = alarmID
    }
}

extension MeshCommand {
    
    static func makeAlarm(_ command: MeshCommand) -> AlarmProtocol? {
        
        // 0xA5 is valid alarm
        guard command.param == 0xA5 else { return nil }
        let alarmID = Int(command.userData[0])
        guard alarmID > 0 && alarmID <= 16 else { return nil }
        
        let event = Int(command.userData[1])
        // bit0~bit3, 0 off, 1 on, 2 scene
        guard let actionType = AlarmActionType(rawValue: UInt8(event & 0b1111)) else { return nil }
        // bit4~bit6 0 day, 1 week
        guard let dayType = AlarmDayType(rawValue: UInt8((event & 0b0111_0000) >> 4)) else { return nil }
        let isEnabled = (event & 0x80) == 0x80
        let hour = Int(command.userData[4])
        let minute = Int(command.userData[5])
        let second = Int(command.userData[6])
        let sceneID = Int(command.userData[7])
        
        var alarm: AlarmProtocol?
        
        switch dayType {
        case .day:
            
            let month = Int(command.userData[2])
            guard month > 0 && month <= 12 else { return nil }
            let day = Int(command.userData[3])
            
            var dayAlarm = DayAlarm(alarmID: alarmID)
            dayAlarm.actionType = actionType
            dayAlarm.isEnabled = isEnabled
            dayAlarm.hour = hour
            dayAlarm.minute = minute
            dayAlarm.second = second
            dayAlarm.sceneID = sceneID
            dayAlarm.month = month
            dayAlarm.day = day
            
            alarm = dayAlarm
            
        case .week:
            
            let week = Int(command.userData[3]) & 0x7F
            
            var weekAlarm = WeekAlarm(alarmID: alarmID)
            weekAlarm.actionType = actionType
            weekAlarm.isEnabled = isEnabled
            weekAlarm.hour = hour
            weekAlarm.minute = minute
            weekAlarm.second = second
            weekAlarm.sceneID = sceneID
            weekAlarm.week = week
            
            alarm = weekAlarm
        }
        
        return alarm
    }
}

extension MeshCommand {
    
    // The `alarmID = 0` means get all alarms of the device.
    public static func getAlarm(_ address: Int, alarmID: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .getAlarm
        cmd.dst = address
        cmd.userData[0] = UInt8(alarmID)
        return cmd
    }
    
    /// Note: `alarm.alarmID` will be set to `0x00`, the device will automatically
    /// set the new `alarmID`.
    public static func addAlarm(_ address: Int, alarm: AlarmProtocol) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .editAlarm
        cmd.dst = address
        cmd.param = 0x00 // add
        cmd.userData[0] = 0x00 // automatically set alarmID
        cmd.userData[1] = alarm.alarmEvent
        
        // 2 day.month
        // 3 day.day, week.week
        if alarm.dayType == .day, let dayAlarm = alarm as? DayAlarm {
            
            cmd.userData[2] = UInt8(dayAlarm.month)
            cmd.userData[3] = UInt8(dayAlarm.day)
            
        } else if alarm.dayType == .week, let weekAlarm = alarm as? WeekAlarm {
            
            cmd.userData[3] = UInt8(weekAlarm.week & 0x7F)
        }
        
        cmd.userData[4] = UInt8(alarm.hour)
        cmd.userData[5] = UInt8(alarm.minute)
        cmd.userData[6] = UInt8(alarm.second)
        cmd.userData[7] = UInt8(alarm.sceneID)
        return cmd
    }
    
    public static func enableAlarm(_ address: Int, alarmID: Int, isEnabled: Bool) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .editAlarm
        cmd.dst = address
        // enable 0x03, disable 0x04
        cmd.param = isEnabled ? 0x03 : 0x04
        cmd.userData[0] = UInt8(alarmID)
        return cmd
    }
    
    public static func deleteAlarm(_ address: Int, alarmID: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .editAlarm
        cmd.dst = address
        cmd.param = 0x01 // delete
        cmd.userData[0] = UInt8(alarmID)
        return cmd
    }
    
    public static func updateAlarm(_ address: Int, alarm: AlarmProtocol) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .editAlarm
        cmd.dst = address
        cmd.param = 0x02 // update
        cmd.userData[0] = UInt8(alarm.alarmID)
        cmd.userData[1] = alarm.alarmEvent
        
        // 2 day.month
        // 3 day.day, week.week
        if alarm.dayType == .day, let dayAlarm = alarm as? DayAlarm {
            
            cmd.userData[2] = UInt8(dayAlarm.month)
            cmd.userData[3] = UInt8(dayAlarm.day)
            
        } else if alarm.dayType == .week, let weekAlarm = alarm as? WeekAlarm {
            
            cmd.userData[3] = UInt8(weekAlarm.week & 0x7F)
        }
        
        cmd.userData[4] = UInt8(alarm.hour)
        cmd.userData[5] = UInt8(alarm.minute)
        cmd.userData[6] = UInt8(alarm.second)
        cmd.userData[7] = UInt8(alarm.sceneID)
        return cmd
    }
    
}

// MARK: - Remotes

extension MeshCommand {
    
    /// The `groups.count <= 4`, the `groups[x]` range is [1, 254].
    public static func setRemoteGroups(_ address: Int, groups: [Int]) -> MeshCommand {
        
        return setRemoteGroups(address, groups: groups, isLeading: true, isEnd: true)
    }
    
    /// The `groups.count <= 4`, the `groups[x]` range is [1, 254].
    private static func setRemoteGroups(_ address: Int, groups: [Int], isLeading: Bool, isEnd: Bool) -> MeshCommand {
        
        let tempGroups = (groups.filter{ $0 > 0 && $0 <= 254 }).sorted()
        
        var cmd = MeshCommand()
        cmd.tag = .setRemoteGroups
        cmd.dst = address
        cmd.param = 0x00
        cmd.userData[0] = 0x80
        cmd.userData[1] = 0x00
        cmd.userData[2] = 0x80
        cmd.userData[3] = 0x00
        cmd.userData[4] = 0x80
        cmd.userData[5] = 0x00
        cmd.userData[6] = 0x80
        cmd.userData[7] = isLeading ? 0x01 : 0x02 // leading groups 4
        cmd.userData[8] = isEnd ? 0x00 : 0x01
        
        for (index, group) in tempGroups.enumerated() {
            
            let dataIndex = index * 2
            
            if index > 3 { break }
            if group <= 0 || group >= 254 { continue }
            
            if index == 0 {
                
                cmd.param = group
                cmd.userData[dataIndex] = 0x80
                
            } else {
                
                cmd.userData[dataIndex - 1] = UInt8(group)
                cmd.userData[dataIndex] = 0x80
            }
        }
        
        return cmd
    }
    
    public static func getRemoteGroups(_ address: Int, isLeading: Bool = true) -> MeshCommand {
        
        // GET_SW_GRP
        
        var cmd = MeshCommand()
        cmd.tag = .getGroups
        cmd.dst = address
        cmd.userData[0] = isLeading ? 0x02 : 0x03
        return cmd
    }
    
}

// MARK: - Smart Switch

extension MeshCommand {
    
    public static func getSmartSwitchSecretKey(_ mode: Int) -> MeshCommand {
        
        assert(false, "Please use `getSmartSwitchSecretKey(_: groupId:)` instead.")
        
        let switchId = Int.random(in: 0x0000FFFF..<0xFFFFFFFF)
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = MeshCommand.Address.connectedNode
        cmd.userData[0] = 0x38
        cmd.userData[1] = 0x01 // start
        cmd.userData[2] = UInt8(mode)
        cmd.userData[3] = UInt8(switchId & 0xFF)
        cmd.userData[4] = UInt8((switchId >> 8) & 0xFF)
        cmd.userData[5] = UInt8((switchId >> 16) & 0xFF)
        cmd.userData[6] = UInt8((switchId >> 24) & 0xFF)
        return cmd
    }
    
    public static func getSmartSwitchSecretKey(_ mode: Int, groupId: Int) -> MeshCommand {
        
        let switchId = getSmartSwitchIdWithGroupId(groupId)
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = MeshCommand.Address.connectedNode
        cmd.userData[0] = 0x38
        cmd.userData[1] = 0x01 // start
        cmd.userData[2] = UInt8(mode)
        cmd.userData[3] = UInt8(switchId & 0xFF)
        cmd.userData[4] = UInt8((switchId >> 8) & 0xFF)
        cmd.userData[5] = UInt8((switchId >> 16) & 0xFF)
        cmd.userData[6] = UInt8((switchId >> 24) & 0xFF)
        return cmd
    }
    
    /// - Parameters:
    ///     - address: Device address
    ///     - index: Switch index, range [0, 7]
    public static func getSmartSwitchId(_ address: Int, index: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = SrIndentifier.smartSwitchId.rawValue
        cmd.userData[1] = UInt8(index)
        return cmd
    }
    
    /// Note: The `address` must be a device address.
    public static func addSmartSwitchIdWithGroupId(_ address: Int, groupId: Int) -> MeshCommand {
        
        let switchId = getSmartSwitchIdWithGroupId(groupId)
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x03
        cmd.userData[2] = 0x01
        cmd.userData[3] = 0x01
        cmd.userData[4] = UInt8((switchId >> 24) & 0xFF)
        cmd.userData[5] = UInt8((switchId >> 16) & 0xFF)
        cmd.userData[6] = UInt8((switchId >> 8) & 0xFF)
        cmd.userData[7] = UInt8((switchId) & 0xFF)
        return cmd
    }
    
    public static func deleteSmartSwitchIdWithGroupId(_ address: Int, groupId: Int) -> MeshCommand {
        
        let switchId = getSmartSwitchIdWithGroupId(groupId)
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x03
        cmd.userData[2] = 0x02
        cmd.userData[3] = 0x01
        cmd.userData[4] = UInt8((switchId >> 24) & 0xFF)
        cmd.userData[5] = UInt8((switchId >> 16) & 0xFF)
        cmd.userData[6] = UInt8((switchId >> 8) & 0xFF)
        cmd.userData[7] = UInt8((switchId) & 0xFF)
        return cmd
    }
    
    public static func deleteSmartSwitchId(_ address: Int, switchId: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x03
        cmd.userData[2] = 0x02
        cmd.userData[3] = 0x01
        cmd.userData[4] = UInt8((switchId >> 24) & 0xFF)
        cmd.userData[5] = UInt8((switchId >> 16) & 0xFF)
        cmd.userData[6] = UInt8((switchId >> 8) & 0xFF)
        cmd.userData[7] = UInt8((switchId) & 0xFF)
        return cmd
    }
    
    private static func getSmartSwitchIdWithGroupId(_ groupId: Int) -> Int {
        
        let value = groupId << 16
        let trailing = 0x0001
        return value | trailing
    }
}

// MARK: - Sensor

extension MeshCommand {
    
    public enum SensorAttributeType: UInt8 {
        
        // command.userData[2]
        
        /// Value range is [0, 15], default is 1.
        case humanInductionSensitivity = 0x21
        
        /// 0x00 Off, 0x01 On, default is On.
        case microwaveModuleOnOffState = 0x22
        
        /// 0x00 Off, 0x01 On, default is On.
        case lightModuleOnOffState = 0x23
        
        /// Value range is [0, 1000], default is 0 LUX.
        case workingBrightnessThreshold = 0x24
        
        /// Value range is [0, 65535], default is 60 seconds.
        case detectedPwmOutputDelay = 0x25
        
        /// Value range is [0, 1000], default is 0 LUX.
        case detectedPwmOutputBrightness = 0x26
        
        /// Value range is [0, 100], default is 100%.
        case detectedPwmOutputPercentage = 0x27
        
        /// Value range is [0, 65535], default is 60 seconds.
        case notDetectedPwmOutputDelay = 0x28
        
        /// Value range is [0, 100], default is 10%.
        case notDetectedPwmOutputPercentage = 0x29
        
        /// Value range is [0, 100], default is 0%.
        case pwmOutputPercentageAfterNotDetectedDelay = 0x2A
        
        /// 0x00 Auto mode, 0x01 Independent, default is Auto mode.
        case workingMode = 0x30
        
        /// Readonly
        case sensorState = 0x31
        
        /// Value range is [100, 65535], default is 1000ms.
        case stateReportInterval = 0x32
        
        /// 0 Off, 1 On, default is On.
        case reportOnOffState = 0x33
        
        /// Value range is [-127, 127], default is 0.
        case luxZeroDeviationOfTheBrightnessSensor = 0x34
        
        /// Value range is [1, 100], K = (value / 10.0), default is 10 (K = 1.0).
        case luxScaleFactorOfTheBrightnessSensor = 0x35
        
        public var valueRange: ClosedRange<Int> {
            
            switch self {
                
            case .humanInductionSensitivity:
                return 0...15
            case .microwaveModuleOnOffState:
                return 0...1
            case .lightModuleOnOffState:
                return 0...1
            case .workingBrightnessThreshold:
                return 0...1000
            case .detectedPwmOutputDelay:
                return 0...65535
            case .detectedPwmOutputBrightness:
                return 0...1000
            case .detectedPwmOutputPercentage:
                return 0...100
            case .notDetectedPwmOutputDelay:
                return 0...65535
            case .notDetectedPwmOutputPercentage:
                return 0...100
            case .pwmOutputPercentageAfterNotDetectedDelay:
                return 0...100
            case .workingMode:
                return 0...1
            case .sensorState:
                return 0...1
            case .stateReportInterval:
                return 100...65535
            case .reportOnOffState:
                return 0...1
            case .luxZeroDeviationOfTheBrightnessSensor:
                return -127...127
            case .luxScaleFactorOfTheBrightnessSensor:
                return 1...100
            }
        }
        
        public var isReadonly: Bool {
            
            return self == .sensorState
        }
    }
    
    public static func getSensorAttribute(_ address: Int, type: SensorAttributeType) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x09
        cmd.userData[1] = 0x00 // get
        cmd.userData[2] = type.rawValue
        return cmd
    }
    
    public static func setSensorAttribute(_ address: Int, type: SensorAttributeType, value: Int) -> MeshCommand {
        
        assert(type.valueRange.contains(value), "value \(value) is out of range \(type.valueRange)")
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x09
        cmd.userData[1] = 0x01 // set
        cmd.userData[2] = type.rawValue
        
        if value < 0 && type == .luxZeroDeviationOfTheBrightnessSensor {
            
            let newValue = UInt8(value + 128) | 0x80
            cmd.userData[3] = newValue
            
        } else {
            
            cmd.userData[3] = UInt8(value & 0xFF)
            cmd.userData[4] = UInt8((value >> 8) & 0xFF)
        }
        
        return cmd
    }
}

extension MeshCommand {
    
    public enum SensorEvent: UInt8 {
        
        case doorOpen = 0x41
        case doorClosed = 0x51
        
        case pirDetected = 0x42
        case pirNotDetected = 0x52
        
        case microwaveDetected = 0x43
        case microwaveNotDetected = 0x53
        
        /*
        case luxSensor = 0x44
        case temperatureSesor = 0x45
        */
    }
    
    public enum SensorAction {
        
        /// - parameters:
        ///     - isOn: true for turn on, false for turn off.
        ///     - transition: Value range is [0, 65535] seconds, it's transition time.
        ///     - isEnabled: true for enable this action, false for disable.
        case turnOnOff(isOn: Bool, transition: Int, isEnabled: Bool)
        
        /// - parameters:
        ///     - sceneId: The scene's ID, value range is [1, 254].
        ///     - isEnabled: true for enable this action, false for disable.
        case recallScene(sceneId: Int, isEnabled: Bool)
        
        // ignore in this phase.
        // case recallCustomScene
        
        /// - parameters:
        ///     - brightness: Value range [0, 100].
        ///     - red: Value range [0, 255].
        ///     - green: Value range [0, 255].
        ///     - blue: Value range [0, 255].
        ///     - ctOrWhite: CT value range [0, 100], White value range [0, 255].
        ///     - transition: Value range is [0, 65535] seconds, it's transition time.
        ///     - isEnabled: true for enable this action, false for disable.
        case setState(brightness: Int, red: Int, green: Int, blue: Int, ctOrWhite: Int, transition: Int, isEnabled: Bool)
        
        /// - parameters:
        ///     - brightness: Value range [0, 100].
        ///     - transition: Value range is [0, 65535] seconds, it's transition time.
        ///     - isEnabled: true for enable this action, false for disable.
        case setBrightness(brightness: Int, transition: Int, isEnabled: Bool)
        
        /// - parameters:
        ///     - red: Value range [0, 255].
        ///     - green: Value range [0, 255].
        ///     - blue: Value range [0, 255].
        ///     - isEnabled: true for enable this action, false for disable.
        case setRGB(red: Int, green: Int, blue: Int, isEnabled: Bool)
        
        /// - parameters:
        ///     - red: Value range [0, 255].
        ///     - isEnabled: true for enable this action, false for disable.
        case setRed(red: Int, isEnabled: Bool)
        
        /// - parameters:
        ///     - green: Value range [0, 255].
        ///     - isEnabled: true for enable this action, false for disable.
        case setGreen(green: Int, isEnabled: Bool)
        
        /// - parameters:
        ///     - blue: Value range [0, 255].
        ///     - isEnabled: true for enable this action, false for disable.
        case setBlue(blue: Int, isEnabled: Bool)
        
        /// - parameters:
        ///     - ctOrWhite: CT value range [0, 100], White value range [0, 255].
        ///     - isEnabled: true for enable this action, false for disable.
        case setCtOrWhite(ctOrWhite: Int, isEnabled: Bool)
        
        /// - parameters:
        ///     - index: Value range [1, 20].
        ///     - isEnabled: true for enable this action, false for disable.
        case setRunning(index: Int, isEnabled: Bool)
        
        public enum CustomRunningMode: UInt8 {
            
            case ascendShade = 0x00
            case descendShade
            case ascendDescendShade
            case mixedShade
            case jump
            case strobe
        }
        
        /// - parameters:
        ///     - index: Value range [0x01, 0x10].
        ///     - mode:
        ///     - isEnabled: true for enable this action, false for disable.
        case setCustomRunning(index: Int, mode: CustomRunningMode, isEnabled: Bool)
        
        /// Stop running or custom running.
        ///
        /// - parameters:
        ///     - isEnabled: true for enable this action, false for disable.
        case stopRunning(isEnabled: Bool)
        
        case none
        
        public var commandCode: UInt8 {
            
            switch self {
                
            case .turnOnOff:
                return 0x01
            case .recallScene:
                return 0x02
            case .setState:
                return 0x04
            case .setBrightness:
                return 0x05
            case .setRGB: fallthrough
            case .setRed: fallthrough
            case .setGreen: fallthrough
            case .setBlue: fallthrough
            case .setCtOrWhite:
                return 0x06
            case .setRunning: fallthrough
            case .setCustomRunning: fallthrough
            case .stopRunning:
                return 0x07
            case .none:
                return 0xC0
            }
        }
        
        public var uniqueId: Int {
            
            switch self {
                
            case .turnOnOff:
                return 1
            case .recallScene:
                return 2
            case .setState:
                return 3
            case .setBrightness:
                return 4
            case .setRGB:
                return 5
            case .setRed:
                return 6
            case .setGreen:
                return 7
            case .setBlue:
                return 8
            case .setCtOrWhite:
                return 9
            case .setRunning:
                return 10
            case .setCustomRunning:
                return 11
            case .stopRunning:
                return 12
            case .none:
                return 13
            }
        }
    }
    
    public static func getSensorAction(_ address: Int, event: SensorEvent) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = event.rawValue
        cmd.userData[1] = 0x00 // get
        return cmd
    }
    
    public static func setSensorAction(_ address: Int, event: SensorEvent, action: SensorAction) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = event.rawValue

        switch action {
            
        case .turnOnOff(isOn: let isOn, transition: let transition, isEnabled: let isEnabled):
        
            cmd.userData[1] = isEnabled ? action.commandCode : action.commandCode | 0x80
            cmd.userData[2] = isOn ? 0x01 : 0x00
            cmd.userData[6] = UInt8(transition & 0xFF)
            cmd.userData[7] = UInt8(transition >> 8)
            
        case .recallScene(sceneId: let sceneId, isEnabled: let isEnabled):
            
            cmd.userData[1] = isEnabled ? action.commandCode : action.commandCode | 0x80
            cmd.userData[2] = UInt8(sceneId)
            
        case .setState(brightness: let brightness, red: let red, green: let green, blue: let blue, ctOrWhite: let ctOrWhite, transition: let transition, isEnabled: let isEnabled):
            
            cmd.userData[1] = isEnabled ? action.commandCode : action.commandCode | 0x80
            cmd.userData[2] = UInt8(brightness)
            cmd.userData[3] = UInt8(red)
            cmd.userData[4] = UInt8(green)
            cmd.userData[5] = UInt8(blue)
            cmd.userData[6] = UInt8(ctOrWhite)
            cmd.userData[7] = UInt8(transition & 0xFF)
            cmd.userData[8] = UInt8(transition >> 8)
            
        case .setBrightness(brightness: let brightness, transition: let transition, isEnabled: let isEnabled):
            
            cmd.userData[1] = isEnabled ? action.commandCode : action.commandCode | 0x80
            cmd.userData[2] = UInt8(brightness)
            cmd.userData[6] = UInt8(transition & 0xFF)
            cmd.userData[7] = UInt8(transition >> 8)
            
        case .setRGB(red: let red, green: let green, blue: let blue, isEnabled: let isEnabled):
            
            cmd.userData[1] = isEnabled ? action.commandCode : action.commandCode | 0x80
            cmd.userData[2] = 0x04
            cmd.userData[3] = UInt8(red)
            cmd.userData[4] = UInt8(green)
            cmd.userData[5] = UInt8(blue)
            
        case .setRed(red: let red, isEnabled: let isEnabled):
        
            cmd.userData[1] = isEnabled ? action.commandCode : action.commandCode | 0x80
            cmd.userData[2] = 0x01
            cmd.userData[3] = UInt8(red)
            
        case .setGreen(green: let green, isEnabled: let isEnabled):
            
            cmd.userData[1] = isEnabled ? action.commandCode : action.commandCode | 0x80
            cmd.userData[2] = 0x02
            cmd.userData[3] = UInt8(green)
            
        case .setBlue(blue: let blue, isEnabled: let isEnabled):
            
            cmd.userData[1] = isEnabled ? action.commandCode : action.commandCode | 0x80
            cmd.userData[2] = 0x03
            cmd.userData[3] = UInt8(blue)
            
        case .setCtOrWhite(ctOrWhite: let ctOrWhite, isEnabled: let isEnabled):
            
            cmd.userData[1] = isEnabled ? action.commandCode : action.commandCode | 0x80
            cmd.userData[2] = 0x05
            cmd.userData[3] = UInt8(ctOrWhite)
            
        case .setRunning(index: let index, isEnabled: let isEnabled):
            
            cmd.userData[1] = isEnabled ? action.commandCode : action.commandCode | 0x80
            cmd.userData[2] = 0x05
            cmd.userData[3] = 0x01
            cmd.userData[4] = UInt8(index)
            
        case .setCustomRunning(index: let index, mode: let mode, isEnabled: let isEnabled):
            
            cmd.userData[1] = isEnabled ? action.commandCode : action.commandCode | 0x80
            cmd.userData[2] = 0x05
            cmd.userData[3] = 0x02
            cmd.userData[4] = UInt8(index)
            cmd.userData[5] = mode.rawValue
            
        case .stopRunning(isEnabled: let isEnabled):
            
            cmd.userData[1] = isEnabled ? action.commandCode : action.commandCode | 0x80
            
        case .none:
            
            cmd.userData[1] = action.commandCode
        }
        
        return cmd
    }
    
}

extension MeshCommand {
    
    ///
    /// - parameters:
    ///     - address: Device address, target address, add sensor events for it.
    ///     - sensorType: Sensor type.
    ///     - sensorId: For example, the Mac of the device is `AA679C000001`, the sensorId is 0x9C000001, the last 4 bytes of the Mac.
    public static func bindSensorId(_ address: Int, sensorType: MeshCommand.SensorReportType, sensorId: Int) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x04 // bind sensor
        cmd.userData[2] = 0x01 // bind
        cmd.userData[3] = sensorType.rawValue
        cmd.userData[4] = UInt8((sensorId >> 24) & 0xFF)
        cmd.userData[5] = UInt8((sensorId >> 16) & 0xFF)
        cmd.userData[6] = UInt8((sensorId >> 8) & 0xFF)
        cmd.userData[7] = UInt8(sensorId & 0xFF)
        return cmd
    }
    
    public static func unbindSensorId(_ address: Int, sensorType: MeshCommand.SensorReportType) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x04 // bind sensor
        cmd.userData[2] = 0x02 // unbind
        cmd.userData[3] = sensorType.rawValue
        return cmd
    }
    
    public static func getSensorId(_ address: Int, sensorType: MeshCommand.SensorReportType) -> MeshCommand {
        
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x04 // bind sensor
        cmd.userData[2] = 0x00 // get
        cmd.userData[3] = sensorType.rawValue
        return cmd
    }
    
    public static func identify(_ address: Int) -> MeshCommand {
        return unbindSensorId(address, sensorType: .microwareMotion)
    }
    
}

extension MeshCommand {
    
    public struct SmartSwitchActions {
        
        public enum ShortPress: UInt8 {
            case turnOn = 0x01
            case turnOff = 0x02
            case turnOnOff = 0x03
            case turnOnWhite = 0x04
            case turnOffWhite = 0x05
            case turnOnOffWhite = 0x06
            case stepBrightnessUp = 0x07
            case stepBrightnessDown = 0x08
            case stepBrightnessUpDown = 0x09
            case recallScene1 = 0x29
            case recallScene2 = 0x2B
            case recallScene3 = 0x2D
            case recallScene4 = 0x2F
            case changeCct = 0x30
            case changeRgb = 0x32
            case runBuiltinRunningMode = 0x34
            case setBrightness = 0x35
            case setCct = 0x36
            case setRed = 0x37
            case setGreen = 0x38
            case setBlue = 0x39
            case setRgb = 0x3A
            
            public static let all: [ShortPress] = [
                .turnOn, .turnOff, .turnOnOff,
                .turnOnWhite, .turnOffWhite, .turnOnOffWhite,
                .stepBrightnessUp, .stepBrightnessDown, .stepBrightnessUpDown,
                .recallScene1, .recallScene2, .recallScene3, .recallScene4,
                .changeCct, .changeRgb,
                .runBuiltinRunningMode,
                .setBrightness,
                .setCct,
                .setRed, .setGreen, .setBlue,
                .setRgb
            ]
        }
        
        public enum LongPress: UInt8 {
            case undefined = 0x00
            case moveBrightnessUp = 0x11
            case moveBrightnessDown = 0x12
            case moveBrightnessUpDown = 0x13
            case moveCctWhiteUp = 0x15
            case moveCctWhiteDown = 0x16
            case moveCctWhiteUpDown = 0x17
            case moveRgbMixFadeUp = 0x1D
            case moveRgbMixFadeDown = 0x1E
            case moveRgbMixFadeUpDown = 0x1F
            case moveSpeedUp = 0x25
            case moveSpeedDown = 0x26
            case moveSpeedUpDown = 0x27
            case saveScene1 = 0x28
            case recallScene1 = 0x29
            case saveScene2 = 0x2A
            case recallScene2 = 0x2B
            case saveScene3 = 0x2C
            case recallScene3 = 0x2D
            case saveScene4 = 0x2E
            case recallScene4 = 0x2F
            
            public static let all: [LongPress] = [
                .undefined,
                .moveBrightnessUp, .moveBrightnessDown, .moveBrightnessUpDown,
                .moveCctWhiteUp, .moveCctWhiteDown, .moveCctWhiteUpDown,
                .moveRgbMixFadeUp, .moveRgbMixFadeDown, .moveRgbMixFadeUpDown,
                .moveSpeedUp, .moveSpeedDown, .moveSpeedUpDown,
                .saveScene1, .recallScene1,
                .saveScene2, .recallScene2,
                .saveScene3, .recallScene3,
                .saveScene4, .recallScene4,
            ]
        }
        
        public enum LongPressStop: UInt8 {
            case moveBrightnessStop = 0x10
            case moveCctStop = 0x14
            case moveRgbMixFadeStop = 0x1C
            case moveSpeedStop = 0x24
        }
        
        public enum ButtonCount {
            case key1
            case key2
            case key4
            
            public static let all: [ButtonCount] = [
                .key1, .key2, .key4
            ]
            
            public var switchModel: UInt8 {
                switch self {
                case .key1:
                    return 9
                case .key2:
                    return 8
                case .key4:
                    return 7
                }
            }
            
            public var positions: [ButtonPosition] {
                switch self {
                case .key1:
                    return [.key1]
                case .key2:
                    return [.key2Left, .key2Right]
                case .key4:
                    return [.key4TopLeft, .key4TopRight, .key4BottomLeft, .key4BottomRight]
                }
            }
        }
        
        public enum ButtonPosition {
            case key4TopLeft
            case key4BottomLeft
            case key4TopRight
            case key4BottomRight
            case key2Left
            case key2Right
            case key1
            
            public var groupIndex: UInt8 {
                return 1 << (keyIndex - 1)
            }
            
            public var keyIndex: UInt8 {
                switch self {
                case .key4TopRight: fallthrough
                case .key2Right: fallthrough
                case .key1:
                    return 1
                case .key4BottomRight: fallthrough
                case .key2Left:
                    return 2
                case .key4TopLeft:
                    return 3
                case .key4BottomLeft:
                    return 4
                }
            }
        }
        
        public var buttonCount: ButtonCount = .key4
        public var buttonPosition: ButtonPosition = .key4TopLeft
        public var shortPress: ShortPress = .turnOnOff
        public var longPress: LongPress = .undefined
        
        /// For setBrightness
        public var brightness: UInt8 = 100
        /// For setCct
        public var cct: UInt8 = 50
        /// For setRed or setRgb
        public var red: UInt8 = 255
        /// For setGreen or setRgb
        public var green: UInt8 = 255
        /// For setBlue or setRgb
        public var blue: UInt8 = 255
        
        public static let `default` = SmartSwitchActions()
    }
    
    public static func getSmartSwitchId(_ switchIdText: String?) -> UInt32? {
        guard let text = switchIdText else {
            return nil
        }
        if text.count == 8 {
            // For example, enter "7000000D", return 0x7000000D.
            return UInt32(text, radix: 16)
        } else if text.count > 8 {
            // 30SE21530EE050E+Z4175EF4A7363217261950F6A53833992+30PS3221-A215+2PDD07+S10000000001101
            // 0x30EE050E
            if let item = text.split(separator: "+").first, item.count >= 8 {
                let start = item.index(item.endIndex, offsetBy: -8)
                let itemText = item[start..<item.endIndex]
                return UInt32(itemText, radix: 16)
            }
        }
        return nil
    }
    
    /// You must invoke `MeshManaget.shared.sendCommands(commands)` for this command.
    public static func saveSmartSwitch(_ address: Int, switchId: UInt32, actions: SmartSwitchActions) -> [MeshCommand] {
        
        var commands: [MeshCommand] = []
        
        var bind = MeshCommand()
        bind.tag = .appToNode
        bind.dst = address
        bind.userData[0] = 0x12
        bind.userData[1] = 0x03 // smart switch
        bind.userData[2] = 0x01 // bind
        bind.userData[3] = actions.buttonPosition.groupIndex
        bind.userData[4] = UInt8((switchId >> 24) & 0xFF)
        bind.userData[5] = UInt8((switchId >> 16) & 0xFF)
        bind.userData[6] = UInt8((switchId >> 8) & 0xFF)
        bind.userData[7] = UInt8(switchId & 0xFF)
        commands.append(bind)
        
        // Press Type
        // Short press 1
        // Long press start 2
        // Long press end 3
        
        // Short press action
        var shortPress = MeshCommand()
        shortPress.tag = .appToNode
        shortPress.dst = address
        shortPress.userData[0] = 0x13
        shortPress.userData[1] = 0x00 // default group
        shortPress.userData[2] = actions.buttonPosition.keyIndex
        shortPress.userData[3] = 1 // press type, short press
        shortPress.userData[4] = actions.shortPress.rawValue // action index
        shortPress.userData[5] = 0x07 // Switch Model is always Mode 7
        switch actions.shortPress {
        case .setBrightness:
            shortPress.userData[6] = actions.brightness
        case .setCct:
            shortPress.userData[6] = actions.cct
        case .setRed:
            shortPress.userData[6] = actions.red
        case .setGreen:
            shortPress.userData[6] = actions.green
        case .setBlue:
            shortPress.userData[6] = actions.blue
        case .setRgb:
            shortPress.userData[6] = actions.red
            shortPress.userData[7] = actions.green
            shortPress.userData[8] = actions.blue
        default:
            break
        }
        commands.append(shortPress)
        
        // Long press start action
        var longPress = MeshCommand()
        longPress.tag = .appToNode
        longPress.dst = address
        longPress.userData[0] = 0x13
        longPress.userData[1] = 0x00 // default group
        longPress.userData[2] = actions.buttonPosition.keyIndex
        longPress.userData[3] = 2 // press type, long press
        longPress.userData[4] = actions.longPress.rawValue // action index
        longPress.userData[5] = 0x07 // Switch Model is always Mode 7
        commands.append(longPress)
        
        // Long press stop action
        typealias ActionStop = SmartSwitchActions.LongPressStop
        
        var temp = MeshCommand()
        temp.tag = .appToNode
        temp.dst = address
        temp.userData[0] = 0x13
        temp.userData[1] = 0x00 // default group
        temp.userData[2] = actions.buttonPosition.keyIndex
        temp.userData[3] = 3 // press type, long press stop
        temp.userData[4] =  ActionStop.moveBrightnessStop.rawValue // action index
        temp.userData[5] = 0x07 // Switch Model is always Mode 7
        
        var stop: MeshCommand?
        switch actions.longPress {
        case .moveBrightnessUp: fallthrough
        case .moveBrightnessDown: fallthrough
        case .moveBrightnessUpDown:
            temp.userData[4] =  ActionStop.moveBrightnessStop.rawValue // action index
            stop = temp
            
        case .moveCctWhiteUp: fallthrough
        case .moveCctWhiteDown: fallthrough
        case .moveCctWhiteUpDown:
            temp.userData[4] =  ActionStop.moveCctStop.rawValue // action index
            stop = temp
            
        case .moveRgbMixFadeUp: fallthrough
        case .moveRgbMixFadeDown: fallthrough
        case .moveRgbMixFadeUpDown:
            temp.userData[4] =  ActionStop.moveRgbMixFadeStop.rawValue // action index
            stop = temp
            
        case .moveSpeedUp: fallthrough
        case .moveSpeedDown: fallthrough
        case .moveSpeedUpDown:
            temp.userData[4] =  ActionStop.moveSpeedStop.rawValue // action index
            stop = temp
            
        default:
            break
        }
        
        if let stopCommand = stop {
            commands.append(stopCommand)
        }        
        return commands
    }
    
    /**
     Delete the smart switch save by `saveSmartSwitch`.
     */
    public static func deleteSavedSmartSwitch(_ address: Int, switchId: UInt32, buttonPosition: SmartSwitchActions.ButtonPosition) -> MeshCommand {
        
        var unbind = MeshCommand()
        unbind.tag = .appToNode
        unbind.dst = address
        unbind.userData[0] = 0x12
        unbind.userData[1] = 0x03 // smart switch
        unbind.userData[2] = 0x02 // unbind
        unbind.userData[3] = buttonPosition.groupIndex
        unbind.userData[4] = UInt8((switchId >> 24) & 0xFF)
        unbind.userData[5] = UInt8((switchId >> 16) & 0xFF)
        unbind.userData[6] = UInt8((switchId >> 8) & 0xFF)
        unbind.userData[7] = UInt8(switchId & 0xFF)
        return unbind
    }
}

extension MeshCommand {
    
    /**
     If you have many devices, please get status one by one, don't send 0xFFFF for all devices.
     */
    public static func getStatus(_ address: Int) -> MeshCommand {
        return getStatusV2(address)
//        var cmd = MeshCommand()
//        cmd.tag = .getStatus
//        cmd.dst = address
//        return cmd
    }
    
    public static func getStatusV2(_ address: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x78
        cmd.userData[1] = 0x00
        return cmd
    }
    
}

// MARK: - Universal Remote

extension MeshCommand {
    
    public enum UniversalRemoteIndex: UInt8 {
        case first = 1
        case second = 2
    }
    
    public enum UniversalKeyType: UInt8 {
        case shortPress = 1
        case longPress = 2
        case rotationOrLongPressEnding = 3
        
        public var title: String {
            switch self {
            case .shortPress: "Short Press"
            case .longPress: "Long Press"
            case .rotationOrLongPressEnding: "Rotation or Long Press Ending"
            }
        }
    }
    
    public static func getUniversalRemoteId(_ address: Int, remoteIndex: UniversalRemoteIndex) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x06 // universal remote
        cmd.userData[2] = 0x00 // get (read)
        cmd.userData[3] = remoteIndex.rawValue
        return cmd
    }
    
    /// remoteId must be a hex string, ex. the mac of the device is `010203040506` then the remote ID must be `03040506`.
    public static func setUniversalRemoteId(_ address: Int, remoteIndex: UniversalRemoteIndex, remoteId: String) -> MeshCommand {
        let value = Int(remoteId, radix: 16) ?? 0
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x06 // universal remote
        cmd.userData[2] = 0x01 // bind
        cmd.userData[3] = remoteIndex.rawValue
        cmd.userData[4] = UInt8((value >> 24) & 0xFF)
        cmd.userData[5] = UInt8((value >> 16) & 0xFF)
        cmd.userData[6] = UInt8((value >> 8) & 0xFF)
        cmd.userData[7] = UInt8((value) & 0xFF)
        return cmd
    }
    
    public static func unbindUniversalRemoteId(_ address: Int, remoteIndex: UniversalRemoteIndex) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x06 // universal remote
        cmd.userData[2] = 0x02 // unbind
        cmd.userData[3] = remoteIndex.rawValue
        return cmd
    }
    
    /// keyIndex range 1-17.
    /// 1-16 are for normal key.
    /// 17 is for rotation action.
    /// arg0 contains brightness, cct, red, (green, blue, sceneId, steps)
    /// arg1 = green
    /// arg2 = blue
    public static func setUniversalRemoteAction(_ address: Int, remoteIndex: UniversalRemoteIndex, action: UniversalRemoteAction) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x16
        cmd.userData[1] = 0x01 // set
        cmd.userData[2] = remoteIndex.rawValue
        cmd.userData[3] = action.keyIndex
        cmd.userData[4] = action.keyType.rawValue
        cmd.userData[5] = action.actionType.actionNo(isRotation: action.isRotation)
        cmd.userData[6] = action.arg0
        cmd.userData[7] = action.arg1
        cmd.userData[8] = action.arg2
        return cmd
    }
    
    /// Send this command will reponse short press, long press and rotation actions together.
    public static func getUniversalRemoteAction(_ address: Int, remoteIndex: UniversalRemoteIndex, keyIndex: UInt8) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x16
        cmd.userData[1] = 0x00 // get
        cmd.userData[2] = remoteIndex.rawValue
        cmd.userData[3] = keyIndex
        return cmd
    }
    
    /// `MeshManager.shared.sendCommands(commands, intervalSeconds: 0.5)`
    /// You ave to send there commands with a 500ms interval.
    public static func saveUniversalRemoteActions(_ address: Int, remoteIndex: UniversalRemoteIndex, remoteId: String, actions: [UniversalRemoteAction]) -> [MeshCommand] {
        var commands: [MeshCommand] = []
        // bind remote index
        let setRemoteIdCmd = setUniversalRemoteId(address, remoteIndex: remoteIndex, remoteId: remoteId)
        commands.append(setRemoteIdCmd)
        // set actions
        actions.forEach { action in
            let actionCmd = setUniversalRemoteAction(address, remoteIndex: remoteIndex, action: action)
            commands.append(actionCmd)
            // If this action needs to stop, add stop action for it automatically.
            if let stopAction = action.stopAction {
                let stopCmd = setUniversalRemoteAction(address, remoteIndex: remoteIndex, action: stopAction)
                commands.append(stopCmd)
            }
        }
        return commands
    }
    
    public static func getUniversalRemoteActions(_ address: Int, remoteIndex: UniversalRemoteIndex, actions: [UniversalRemoteAction]) -> [MeshCommand] {
        var commands: [MeshCommand] = []
        actions.forEach { action in
            let cmd = getUniversalRemoteAction(address, remoteIndex: remoteIndex, keyIndex: action.keyIndex)
            commands.append(cmd)
        }
        return commands
    }
    
    public static func deleteUniversalRemoteId(_ address: Int, remoteIndex: UniversalRemoteIndex) -> MeshCommand {
        return unbindUniversalRemoteId(address, remoteIndex: remoteIndex)
    }
    
    public struct UniversalRemoteAction {
        public var keyIndex: UInt8
        public var keyType: UniversalKeyType
        public var actionType: ActionType
        public var args: [UInt8]
        
        public var arg0: UInt8 {
            return args.count > 0 ? args[0] : 0xFF
        }
        public var arg1: UInt8 {
            return args.count > 1 ? args[1] : 0xFF
        }
        public var arg2: UInt8 {
            return args.count > 2 ? args[2] : 0xFF
        }
        
        public var isRotation: Bool {
            return keyIndex == 17
        }
        
        public var stopAction: UniversalRemoteAction? {
            if let stopType = actionType.stopActionType {
                return UniversalRemoteAction(keyIndex: keyIndex, keyType: .rotationOrLongPressEnding, actionType: stopType, args: [])
            } else {
                return nil
            }
        }
        
        public var actionTypes: [ActionType] {
            if isRotation {
                return ActionType.rotationActionTypes
            } else {
                switch keyType {
                case .shortPress:
                    return ActionType.shortPressActionTypes
                case .longPress:
                    return ActionType.longPressActionTypes
                case .rotationOrLongPressEnding:
                    return []
                }
            }
        }
        
        public var title: String {
            return isRotation ? "Rotation" : "Key \(keyIndex) - \(keyType.title)"
        }
        
        public var detail: String {
            return "\(actionType) \(arg0), \(arg1), \(arg2)"
        }
        
        public static func rotationAction(actionType: ActionType, args: [UInt8] = []) -> UniversalRemoteAction {
            return UniversalRemoteAction(keyIndex: 17, keyType: .rotationOrLongPressEnding, actionType: actionType, args: args)
        }
        
        public static func keyAction(keyIndex: UInt8, keyType: UniversalKeyType, actionType: ActionType, args: [UInt8] = []) -> UniversalRemoteAction {
            return UniversalRemoteAction(keyIndex: keyIndex, keyType: keyType, actionType: actionType, args: args)
        }
        
        public static func setCtOrWhiteAction(keyIndex: UInt8, ctOrWhite: UInt8, isRgbEnabled: Bool) -> UniversalRemoteAction {
            return keyAction(keyIndex: keyIndex, keyType: .shortPress, actionType: .setCt, args: [ctOrWhite, isRgbEnabled ? 0 : 1])
        }
        
        public static func setRedAction(keyIndex: UInt8, red: UInt8, isCtOrWhiteEnabled: Bool, isRgbEnabled: Bool) -> UniversalRemoteAction {
            return keyAction(keyIndex: keyIndex, keyType: .shortPress, actionType: .setRed, args: [red, isCtOrWhiteEnabled ? 0 : 1, isRgbEnabled ? 0 : 1])
        }
        
        public static func setGreenAction(keyIndex: UInt8, green: UInt8, isCtOrWhiteEnabled: Bool, isRgbEnabled: Bool) -> UniversalRemoteAction {
            return keyAction(keyIndex: keyIndex, keyType: .shortPress, actionType: .setGreen, args: [green, isCtOrWhiteEnabled ? 0 : 1, isRgbEnabled ? 0 : 1])
        }
        
        public static func setBlueAction(keyIndex: UInt8, blue: UInt8, isCtOrWhiteEnabled: Bool, isRgbEnabled: Bool) -> UniversalRemoteAction {
            return keyAction(keyIndex: keyIndex, keyType: .shortPress, actionType: .setBlue, args: [blue, isCtOrWhiteEnabled ? 0 : 1, isRgbEnabled ? 0 : 1])
        }
        
        public static func k5EmptyActions() -> [UniversalRemoteAction] {
            return [
                rotationAction(actionType: .none),
                // keys 1, 2, 3, 4, 5
                keyAction(keyIndex: 1, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 1, keyType: .longPress, actionType: .none),
                keyAction(keyIndex: 2, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 2, keyType: .longPress, actionType: .none),
                keyAction(keyIndex: 3, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 3, keyType: .longPress, actionType: .none),
                keyAction(keyIndex: 4, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 4, keyType: .longPress, actionType: .none),
                keyAction(keyIndex: 5, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 5, keyType: .longPress, actionType: .none),
            ]
        }
        
        public static func k12EmptyActions() -> [UniversalRemoteAction] {
            return [
                rotationAction(actionType: .none),
                // keys 1, 2, 3, 4, 5, 6, 7, 8, 11, 12, 15, 16
                keyAction(keyIndex: 1, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 1, keyType: .longPress, actionType: .none),
                keyAction(keyIndex: 2, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 2, keyType: .longPress, actionType: .none),
                keyAction(keyIndex: 3, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 3, keyType: .longPress, actionType: .none),
                keyAction(keyIndex: 4, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 4, keyType: .longPress, actionType: .none),
                keyAction(keyIndex: 5, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 5, keyType: .longPress, actionType: .none),
                keyAction(keyIndex: 6, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 6, keyType: .longPress, actionType: .none),
                keyAction(keyIndex: 7, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 7, keyType: .longPress, actionType: .none),
                keyAction(keyIndex: 8, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 8, keyType: .longPress, actionType: .none),
                /// Key index 9 is the rotation click and press key index.
                keyAction(keyIndex: 9, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 9, keyType: .longPress, actionType: .none),
                keyAction(keyIndex: 11, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 11, keyType: .longPress, actionType: .none),
                keyAction(keyIndex: 12, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 12, keyType: .longPress, actionType: .none),
                keyAction(keyIndex: 15, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 15, keyType: .longPress, actionType: .none),
                keyAction(keyIndex: 16, keyType: .shortPress, actionType: .none),
                keyAction(keyIndex: 16, keyType: .longPress, actionType: .none),
            ]
        }
        
        public static func copyActionsWithRemoteType(_ remoteType: MeshDeviceType.UniversalRemoteType, sourceActions: [UniversalRemoteAction]) -> [UniversalRemoteAction] {
            var actions: [UniversalRemoteAction] = []
            switch remoteType {
            case .none:
                break
            case .k5WithKnob:
                actions = UniversalRemoteAction.k5EmptyActions()
            case .k12WithKnob:
                actions = UniversalRemoteAction.k12EmptyActions()
            }
            sourceActions.forEach { source in
                if (source.isRotation) {
                    // rotation shouldn't check the keyIndex or keyType
                    if let index = actions.firstIndex(where: { $0.isRotation }) {
                        actions[index] = source
                    }
                } else {
                    // if the keyIndex and keyType are the same, replace the action
                    if let index = actions.firstIndex(where: { $0.keyIndex == source.keyIndex && $0.keyType == source.keyType }) {
                        actions[index] = source
                    }
                }
            }
            return actions
        }
    }
}

extension MeshCommand.UniversalRemoteAction {
    
    public enum ActionType: UInt8 {
        case none = 0x00
        case lightOn
        case lightOff
        case lightOnOff
        case whiteOnRgbEnableForRgbw
        case whiteOffRgbEnableForRgbw
        case whiteOnOffRgbEnableForRgbw
        case stepLevelUp
        case stepLevelDown
        case stepLevelUpDown
        case stepCtOrWhiteUpEnableRgb
        case stepCtOrWhiteDownEnableRgb
        case stepCtOrWhiteUpDownEnableRgb
        case stepCtOrWhiteUpDisableRgb
        case stepCtOrWhiteDownDisableRgb
        case stepCtOrWhiteUpDownDisableRgb
        case moveLevelStop
        case moveLevelUp
        case moveLevelDown
        case moveLevelUpDown
        case moveCtOrWhiteStopEnableRgb
        case moveCtOrWhiteUpEnableRgb
        case moveCtOrWhiteDownEnableRgb
        case moveCtOrWhiteUpDownEnableRgb
        case moveCtOrWhiteStopDisableRgb
        case moveCtOrWhiteUpDisableRgb
        case moveCtOrWhiteDownDisableRgb
        case moveCtOrWhiteUpDownDisableRgb
        case moveRgbMixFadeStopEnableCtOrWhite
        case moveRgbMixFadeUpEnableCtOrWhite
        case moveRgbMixFadeDownEnableCtOrWhite
        case moveRgbMixFadeUpDownEnableCtOrWhite
        case moveRgbMixFadeStopDisableCtOrWhite
        case moveRgbMixFadeUpDisableCtOrWhite
        case moveRgbMixFadeDownDisableCtOrWhite
        case moveRgbMixFadeUpDownDisableCtOrWhite
        case stopRunningSpeedChanging
        case runningSpeedUp
        case runningSpeedDown
        case runningSpeedUpDown
        case saveCustomScene1
        case recallCustomScene1
        case saveCustomScene2
        case recallCustomScene2
        case saveCustomScene3
        case recallCustomScene3
        case saveCustomScene4
        case recallCustomScene4
        case ctDefault3ModesLoopEnableRgb
        case ctDefault3ModesLoopDisableRgb
        case rgbDefault9ModesLoopEnableCtOrWhite
        case rgbDefault9ModesLoopDisableCtOrWhite
        case startBuiltin20RunningMode
        case setLevel
        /// arg0 ctOrWhtie, arg1 (0 enable rgb, 1 disable rgb)
        case setCt
        /// arg0 red, arg1 (enable ct/w, 1 disable ct/w), arg2 (0 enable rgb, 1 disable rgb)
        case setRed
        /// as red
        case setGreen
        /// as red
        case setBlue
        case setRgbEnableCtOrWhite
        case setRgbDisableCtOrWhite
        case savePrivateScene
        case recallPrivateScene
        case recallStandardScene
        
        public func actionNo(isRotation: Bool) -> UInt8 {
            if isRotation {
                switch self {
                case .setLevel: return 0x01
                case .setCt: return 0x02
                case .setRed: return 0x03
                case .setGreen: return 0x04
                case .setBlue: return 0x05
                default: break
                }
            }
            return rawValue
        }
        
        public static func makeRotationActionType(rawValue: UInt8) -> ActionType {
            switch rawValue {
            case 0x01: return .setLevel
            case 0x02: return .setCt
            case 0x03: return .setRed
            case 0x04: return .setGreen
            case 0x05: return .setBlue
            default: return .none 
            }
        }
        
        public var argsCount: Int {
            switch self {
            case .setLevel: fallthrough
            case .recallStandardScene: fallthrough
            case .savePrivateScene: fallthrough
            case .recallPrivateScene: 
                return 1
            case .setCt:
                return 2
            case .setRgbEnableCtOrWhite: fallthrough
            case .setRgbDisableCtOrWhite: fallthrough
            case .setRed: fallthrough
            case .setGreen: fallthrough
            case .setBlue:
                return 3
            default:
                return 0
            }
        }
        
        public static let rotationActionTypes: [ActionType] = [
            .none,
            .setLevel, .setCt,
            .setRed, setGreen, setBlue,
        ]
        
        public static let shortPressActionTypes: [ActionType] = [
            .none,
            .lightOn, .lightOff, .lightOnOff,
            .stepLevelUp, .stepLevelDown, .stepLevelUpDown,
            .stepCtOrWhiteUpEnableRgb, .stepCtOrWhiteDownEnableRgb, .stepCtOrWhiteUpDownEnableRgb,
            .stepCtOrWhiteUpDisableRgb, .stepCtOrWhiteDownDisableRgb, .stepCtOrWhiteUpDownDisableRgb,
            .recallCustomScene1, .recallCustomScene2, .recallCustomScene3, .recallCustomScene4,
            .ctDefault3ModesLoopEnableRgb, .ctDefault3ModesLoopDisableRgb,
            .rgbDefault9ModesLoopEnableCtOrWhite, .rgbDefault9ModesLoopDisableCtOrWhite,
            .startBuiltin20RunningMode,
            .setLevel, .setCt,
            .setRed,
            .setGreen,
            .setBlue,
            .setRgbEnableCtOrWhite, .setRgbDisableCtOrWhite,
            .recallStandardScene,
        ]
        
        public static let longPressActionTypes: [ActionType] = [
            .none,
            .moveLevelUp, .moveLevelDown, .moveLevelUpDown,
            .moveCtOrWhiteUpEnableRgb, .moveCtOrWhiteDownEnableRgb, .moveCtOrWhiteUpDownEnableRgb,
            .moveCtOrWhiteUpDisableRgb, .moveCtOrWhiteDownDisableRgb, .moveCtOrWhiteUpDownDisableRgb,
            .moveRgbMixFadeUpEnableCtOrWhite, .moveRgbMixFadeDownEnableCtOrWhite, .moveRgbMixFadeUpDownEnableCtOrWhite,
            .moveRgbMixFadeUpDisableCtOrWhite, .moveRgbMixFadeDownDisableCtOrWhite, .moveRgbMixFadeUpDownDisableCtOrWhite,
            .runningSpeedUp, .runningSpeedDown, .runningSpeedUpDown,
            .saveCustomScene1, .saveCustomScene2, .saveCustomScene3, .saveCustomScene4,
        ]
        
        var stopActionType: ActionType? {
            switch self {
            case .moveLevelUp: fallthrough
            case .moveLevelDown: fallthrough
            case .moveLevelUpDown:
                return .moveLevelStop
            case .moveCtOrWhiteUpEnableRgb: fallthrough
            case .moveCtOrWhiteDownEnableRgb: fallthrough
            case .moveCtOrWhiteUpDownEnableRgb:
                return .moveCtOrWhiteStopEnableRgb
            case .moveCtOrWhiteUpDisableRgb: fallthrough
            case .moveCtOrWhiteDownDisableRgb: fallthrough
            case .moveCtOrWhiteUpDownDisableRgb:
                return .moveCtOrWhiteStopDisableRgb
            case .moveRgbMixFadeUpEnableCtOrWhite: fallthrough
            case .moveRgbMixFadeDownEnableCtOrWhite: fallthrough
            case .moveRgbMixFadeUpDownEnableCtOrWhite:
                return .moveRgbMixFadeStopEnableCtOrWhite
            case .moveRgbMixFadeUpDisableCtOrWhite: fallthrough
            case .moveRgbMixFadeDownDisableCtOrWhite: fallthrough
            case .moveRgbMixFadeUpDownDisableCtOrWhite:
                return .moveRgbMixFadeStopDisableCtOrWhite
            case .runningSpeedUp: fallthrough
            case .runningSpeedDown: fallthrough
            case .runningSpeedUpDown:
                return .stopRunningSpeedChanging
            default:
                return nil
            }
        }
    }
}

extension MeshCommand {
    
    public struct MultiSensorAction {
        
        let command: UInt8 = 0x19
        // range is [1, 4]
        public var sensorIndex: UInt8 = 1
        // range is [1, 2]
        public var actionIndex: UInt8 = 1
        public var actionNo: ActionNo = .undefined
        public var arg1: UInt8 = 0x00
        public var arg2: UInt8 = 0x00
        public var arg3: UInt8 = 0x00
        
        public var desc: String {
            return "\(actionIndex): \(actionNo), \(arg1) \(arg2) \(arg3)"
        }
         
        public static func makeUndefinedAction(_ sensorIndex: UInt8, actionIndex: UInt8) -> MultiSensorAction {
            return MultiSensorAction(sensorIndex: sensorIndex, actionIndex: actionIndex, actionNo: .undefined)
        }
        
        public static func makeTurnOnAction(_ sensorIndex: UInt8, actionIndex: UInt8) -> MultiSensorAction {
            return MultiSensorAction(sensorIndex: sensorIndex, actionIndex: actionIndex, actionNo: .turnOn)
        }
        
        public static func makeTurnOffAction(_ sensorIndex: UInt8, actionIndex: UInt8) -> MultiSensorAction {
            return MultiSensorAction(sensorIndex: sensorIndex, actionIndex: actionIndex, actionNo: .turnOff)
        }
        
        public static func makeSetBrightnessAction(_ sensorIndex: UInt8, actionIndex: UInt8, brightness: Int) -> MultiSensorAction {
            return MultiSensorAction(sensorIndex: sensorIndex, actionIndex: actionIndex, actionNo: .setBrightness, arg1: UInt8(brightness))
        }
        
        public static func makeSetCctAction(_ sensorIndex: UInt8, actionIndex: UInt8, cct: Int, isRgbEnabled: Bool) -> MultiSensorAction {
            return MultiSensorAction(sensorIndex: sensorIndex, actionIndex: actionIndex, actionNo: .setCct, arg1: UInt8(cct), arg2: isRgbEnabled ? 0x00 : 0x01)
        }
        
        public static func makeSetRgbAction(_ sensorIndex: UInt8, actionIndex: UInt8, red: Int, green: Int, blue: Int, isCctWhiteEnabled: Bool) -> MultiSensorAction {
            return MultiSensorAction(sensorIndex: sensorIndex, actionIndex: actionIndex, actionNo: isCctWhiteEnabled ? .setRgbEnableCctWhite : .setRgbDisableCctWhite, arg1: UInt8(red), arg2: UInt8(green), arg3: UInt8(blue))
        }
        
        public static func makeRecallSceneAction(_ sensorIndex: UInt8, actionIndex: UInt8, sceneId: Int) -> MultiSensorAction {
            return MultiSensorAction(sensorIndex: sensorIndex, actionIndex: actionIndex, actionNo: .recallScene, arg1: UInt8(sceneId))
        }
        
        public static func makeSetLightModeAction(_ sensorIndex: UInt8, actionIndex: UInt8, lightMode: LightMode, brightnessModel: BrightnessMode, colorMode: ColorMode) -> MultiSensorAction {
            return MultiSensorAction(sensorIndex: sensorIndex, actionIndex: actionIndex, actionNo: .setLightMode, arg1: lightMode.rawValue, arg2: brightnessModel.rawValue, arg3: colorMode.rawValue)
        }
        
        public static func makeActionWithActionNo(_ sensorIndex: UInt8, actionIndex: UInt8, actionNo: ActionNo, args: [Int]) -> MultiSensorAction {
            let argsCount = actionNo.argsCount
            if argsCount == 0 {
                return MultiSensorAction(sensorIndex: sensorIndex, actionIndex: actionIndex, actionNo: actionNo)
            } else {
                var finalArgs: [UInt8] = [0, 0, 0]
                let count = min(args.count, 3)
                for i in 0..<count {
                    finalArgs[i] = UInt8(args[i])
                }
                return MultiSensorAction(sensorIndex: sensorIndex, actionIndex: actionIndex, actionNo: actionNo, arg1: finalArgs[0], arg2: finalArgs[1], arg3: finalArgs[2])
            }
        }
        
        public static func makeActionWithUserData(_ userData: Data) -> MultiSensorAction? {
            guard userData.count >= 9 else {
                NSLog("makeActionWithUserData failed, userData.count < 9", "")
                return nil
            }
            guard userData.first == 0x19 else {
                NSLog("makeActionWithUserData failed, userData.first != 0x19", "")
                return nil
            }
            let sensorIndex = userData[2]
            let actionIndex = userData[4] + 1
            guard actionIndex >= 1 && actionIndex <= 2 else {
                NSLog("makeActionWithUserData failed, actionIndex \(actionIndex) is not in 1...2", "")
                return nil
            }
            guard let actionNo = ActionNo(rawValue: userData[5]) else {
                NSLog("makeActionWithUserData failed, actionNo is unsuppored \(userData[5])", "")
                return nil
            }
            return MultiSensorAction(sensorIndex: sensorIndex, actionIndex: actionIndex, actionNo: actionNo, arg1: userData[6], arg2: userData[7], arg3: userData[8])
        }
        
        public enum SensorType {
            case unknown
            case doorContact
            case waterLeak
        }
    }
    
    // sensorId just like `0x9000000C`
    public static func linkMultiSensor(_ address: Int, sensorId: Int, action1: MultiSensorAction, action2: MultiSensorAction, sensorType: MultiSensorAction.SensorType) -> [MeshCommand] {
        var clearCommand: MeshCommand?
        if (sensorType == .doorContact) {
            clearCommand = clearManualLinkedDoorSensorId(address)
        } else {
            clearCommand = clearManualLinkedWaterLeakSensorId(address)
        }
        let idCommand = linkMultiSensorId(address, sensorId: sensorId, sensorIndex: Int(action1.sensorIndex))
        let action1Command = linkMultiSensorAction(address, action: action1)
        let action2Command = linkMultiSensorAction(address, action: action2)
        if let clearCommand = clearCommand {
            return [clearCommand, idCommand, action1Command, action2Command]
        }
        return [idCommand, action1Command, action2Command]
    }
    
    public static func linkMultiSensorId(_ address: Int, sensorId: Int, sensorIndex: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x04 // bind sensor
        cmd.userData[2] = 0x01 // bind
        cmd.userData[3] = UInt8((sensorIndex & 0x0F) | 0xF0)
        cmd.userData[4] = UInt8((sensorId >> 24) & 0xFF)
        cmd.userData[5] = UInt8((sensorId >> 16) & 0xFF)
        cmd.userData[6] = UInt8((sensorId >> 8) & 0xFF)
        cmd.userData[7] = UInt8(sensorId & 0xFF)
        return cmd
    }
    
    public static func linkMultiSensorAction(_ address: Int, action: MultiSensorAction) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x19
        cmd.userData[1] = 0x01 // set action
        cmd.userData[2] = action.sensorIndex
        cmd.userData[3] = 0x01 // reserved
        cmd.userData[4] = action.actionIndex == 1 ? 0 : 1
        cmd.userData[5] = action.actionNo.rawValue
        cmd.userData[6] = action.arg1
        cmd.userData[7] = action.arg2
        cmd.userData[8] = action.arg3
        return cmd
    }
    
    public static func unlinkMultiSensorId(_ address: Int, sensorIndex: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x04 // bind sensor
        cmd.userData[2] = 0x02 // unbind
        cmd.userData[3] = UInt8((sensorIndex & 0x0F) | 0xF0)
        return cmd
    }
    
    public static func getLinkedMultiSensorId(_ address: Int, sensorIndex: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x04 // bind sensor
        cmd.userData[2] = 0x00 // get
        cmd.userData[3] = UInt8((sensorIndex & 0x0F) | 0xF0)
        return cmd
    }
    
    public static func getLinkedMultiSensorAction(_ address: Int, sensorIndex: Int, actionIndex: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x19
        cmd.userData[1] = 0x00 // get action
        cmd.userData[2] = UInt8(sensorIndex)
        cmd.userData[3] = 0x01 // reserved
        cmd.userData[4] = actionIndex == 1 ? 0 : 1
        return cmd
    }
}

/// Protocol: 手机app定义机械能开关的按键功能
extension MeshCommand.MultiSensorAction {
    
    public enum ActionNo: UInt8 {
        case undefined = 0
        case turnOn = 1
        case turnOff = 2
        case setBrightness = 0x35
        case setCct = 0x36
        case setRgbEnableCctWhite = 0x3A
        case setRgbDisableCctWhite = 0x3B
        case recallScene = 0x3E
        case setLightMode = 0x3F
        
        public static let all: [ActionNo] = [
            .undefined, .turnOn, .turnOff, .setBrightness,
            .setCct, .setRgbEnableCctWhite, .setRgbDisableCctWhite, .recallScene,
            .setLightMode,
        ]
        
        public var argsCount: Int {
            switch self {
            case .undefined: fallthrough
            case .turnOn: fallthrough
            case .turnOff:
                return 0
            case .setBrightness: fallthrough
            case .setCct: fallthrough
            case .recallScene:
                return 1
            case .setRgbEnableCctWhite: fallthrough
            case .setRgbDisableCctWhite:
                return 3
            case .setLightMode:
                return 3
            }
        }
    }
    
    public enum LightMode: UInt8 {
        case turnOn = 1
        case turnOff
        case flash0_5Hz
        case flash1Hz
        case flash2Hz
        case flash3Hz
    }
    
    public enum BrightnessMode: UInt8 {
        case current = 1
        case percent100
        case percent50
        case percent25
    }
    
    public enum ColorMode: UInt8 {
        case current = 1
        case red
        case green
        case blue
        /// redGreen
        case yellow
        /// greenBlue
        case cyan
        /// redBlue
        case magenta
        case warmWhite
        case coolWhite
        case white
    }
}

/// Protocol: 手机APP定义传感器的功能
extension MeshCommand {
    public struct SingleSensorAction {
        public var sensorType: SensorType
        // range is [1, 2]
        public var actionIndex: UInt8 = 1
        public var actionNo: ActionNo = .undefined
        // [0, 100]
        public var brightness: Int = 100
        // [0, 255]
        public var red: Int = 255
        public var green: Int = 255
        public var blue: Int = 255
        // cct [0, 100], white [0, 255]
        public var cctOrWhite: Int = 0
        // scene ID [1, 254]
        public var sceneId: Int = 1
        public var isEnabled = true
        // [0, 65535] seconds
        public var transition: Int = 0
        
        public var desc: String {
            return "\(sensorType), action \(actionIndex), \(actionNo)"
        }
        
        public var sensorTypeValue: UInt8 {
            return actionIndex == 1 ? sensorType.action1Value : sensorType.action2Value
        }
        
        public var actionNoValue: UInt8 {
            switch actionNo {
            case .undefined:
                return 0xF0
            case .turnOn: fallthrough
            case .turnOff:
                return 0x01
            case .setBrightness:
                return 0x05
            case .setCctOrWhite: fallthrough
            case .setRgb:
                return 0x06
            case .recallScene:
                return 0x02
            }
        }
        
        public init(sensorType: SensorType, actionIndex: UInt8, actionNo: ActionNo) {
            self.sensorType = sensorType
            self.actionIndex = actionIndex
            self.actionNo = actionNo
        }
    }
    
    // sensorId just like `0x9000000C`
    public static func linkSingleSensor(_ address: Int, sensorId: Int, action1: SingleSensorAction, action2: SingleSensorAction) -> [MeshCommand] {
        return [
            linkSingleSensorId(address, sensorId: sensorId, sensorType: action1.sensorType),
            linkSingleSensorAction(address, action: action1),
            linkSingleSensorAction(address, action: action2),
        ]
    }
    
    public static func linkSingleSensorId(_ address: Int, sensorId: Int, sensorType: SingleSensorAction.SensorType) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x04 // bind sensor
        cmd.userData[2] = 0x01 // bind
        cmd.userData[3] = sensorType.rawValue
        cmd.userData[4] = UInt8((sensorId >> 24) & 0xFF)
        cmd.userData[5] = UInt8((sensorId >> 16) & 0xFF)
        cmd.userData[6] = UInt8((sensorId >> 8) & 0xFF)
        cmd.userData[7] = UInt8(sensorId & 0xFF)
        return cmd
    }
    
    public static func linkSingleSensorAction(_ address: Int, action: SingleSensorAction) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = action.sensorTypeValue
        cmd.userData[1] = action.actionNoValue
        switch action.actionNo {
        case .undefined:
            break
        case .turnOn:
            cmd.userData[2] = 0x01
            cmd.userData[6] = UInt8(action.transition & 0xFF)
            cmd.userData[7] = UInt8(action.transition >> 8)
        case .turnOff:
            cmd.userData[2] = 0x00
            cmd.userData[6] = UInt8(action.transition & 0xFF)
            cmd.userData[7] = UInt8(action.transition >> 8)
        case .setBrightness:
            cmd.userData[2] = UInt8(action.brightness)
            cmd.userData[6] = UInt8(action.transition & 0xFF)
            cmd.userData[7] = UInt8(action.transition >> 8)
        case .setCctOrWhite:
            cmd.userData[2] = 0x05 // ctw
            cmd.userData[3] = UInt8(action.cctOrWhite)
        case .setRgb:
            cmd.userData[2] = 0x04 // rgb
            cmd.userData[3] = UInt8(action.red)
            cmd.userData[4] = UInt8(action.green)
            cmd.userData[5] = UInt8(action.blue)
        case .recallScene:
            cmd.userData[2] = UInt8(action.sceneId)
        }
        return cmd
    }
    
    public static func unlinkSingleSensorId(_ address: Int, sensorType: SingleSensorAction.SensorType) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x04 // bind sensor
        cmd.userData[2] = 0x02 // unbind
        cmd.userData[3] = sensorType.rawValue
        return cmd
    }
    
    public static func getLinkedSingleSensorId(_ address: Int, sensorType: SingleSensorAction.SensorType) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x04 // bind sensor
        cmd.userData[2] = 0x00 // get
        cmd.userData[3] = sensorType.rawValue
        return cmd
    }
    
    public static func getLinkedSingleSensorAction(_ address: Int, sensorType: SingleSensorAction.SensorType, actionIndex: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = actionIndex == 1 ? sensorType.action1Value : sensorType.action2Value
        cmd.userData[1] = 0x00 // get action
        return cmd
    }
}

extension MeshCommand.SingleSensorAction {
    public enum SensorType: UInt8 {
        case doorContactSensor = 0x01 // closed, open
        case waterLeakSensor = 0x07 // normal, water leak detected
        case smokeSensor = 0x08 // normal, smoke detected
        case coSensor = 0x09 // normal, co detected
        case gasSensor = 0x0A // normal, gas detected
        case airQualitySensor = 0x0B // good, poor air quality
        case glassBreakSensor = 0x0C // normal, glass break detected
        case vibrationSesnor = 0x0D // no vibration, vibration detected
        
        public static let all: [SensorType] = [
            .doorContactSensor, .waterLeakSensor, .smokeSensor, .coSensor,
            .gasSensor, .airQualitySensor, .glassBreakSensor, .vibrationSesnor,
        ]
        
        public var action1Value: UInt8 {
            return rawValue | 0x50
        }
        
        public var action2Value: UInt8 {
            return rawValue | 0x40
        }
    }
    
    public enum ActionNo {
        case undefined
        case turnOn
        case turnOff
        case setBrightness
        case setCctOrWhite
        case setRgb
        case recallScene
        
        public static let all: [ActionNo] = [
            .undefined, .turnOn, .turnOff, .setBrightness,
            .setCctOrWhite, .setRgb, .recallScene,
        ]
    }
}

// MARK: - Curtain

extension MeshCommand {
    
    public static var curtainStates: [Int: String] = [:]

    public struct CurtainCalibrationReport {
        var isSuccess: Bool
        /// ms
        var motorStartTime: Int = 0
        /// ms
        var totalTravelTime: Int = 0
        
        public init(isSuccess: Bool) {
            self.isSuccess = isSuccess
        }
        
        public init?(state: UInt8) {
            if state == 0x66 {
                isSuccess = true
            } else if state == 0xE2 || state == 0xE3 {
                isSuccess = false
            } else {
                return nil
            }
        }
    }
    
    public static func openCurtain(_ address: Int, curtainType: MeshDeviceType.CurtainType) -> MeshCommand {
        curtainStates[address] = curtainStates[address] == "Opening" ? "Stopped" : "Opening"
        return turnOnOff(address, isOn: true)
    }
    
    public static func closeCurtain(_ address: Int, curtainType: MeshDeviceType.CurtainType) -> MeshCommand {
        curtainStates[address] = curtainStates[address] == "Closing" ? "Stopped" : "Closing"
        return turnOnOff(address, isOn: false)
    }
    
    public static func stopCurtainMoving(_ address: Int, curtainType: MeshDeviceType.CurtainType) -> MeshCommand? {
        let state = curtainStates[address] ?? "Stopped"
        var command: MeshCommand?
        switch state {
        case "Opening":
            command = openCurtain(address, curtainType: curtainType)
        case "Closing":
            command = closeCurtain(address, curtainType: curtainType)
        default:
            break
        }
        return command
    }
    
    public static func calibrateCurtain(_ address: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x25
        cmd.userData[1] = 0xAC
        return cmd
    }
    
}

// Mark: - 20241119 New water leak sensor features

extension MeshCommand {
    
    public static func getManualLinkedDoorSensorId(_ address: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x00
        cmd.userData[2] = 0x10
        return cmd
    }
    
    public static func getManualLinkedWaterLeakSensorId(_ address: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x00
        cmd.userData[2] = 0x16
        return cmd
    }
    
    public static func clearManualLinkedDoorSensorId(_ address: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x10
        cmd.userData[2] = 0x02
        return cmd
    }
    
    public static func clearManualLinkedWaterLeakSensorId(_ address: Int) -> MeshCommand {
        var cmd = MeshCommand()
        cmd.tag = .appToNode
        cmd.dst = address
        cmd.userData[0] = 0x12
        cmd.userData[1] = 0x16
        cmd.userData[2] = 0x02
        return cmd
    }
    
}
