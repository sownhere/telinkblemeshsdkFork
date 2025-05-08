//
//  NfcToolManager.swift
//  
//
//  Created by 王文东 on 2023/4/12.
//

import UIKit
import CoreNFC

public protocol NfcToolManagerDelegate: NSObjectProtocol {
    
    /// Nfc read, write failed.
    func nfcToolManagerDidFailed(_ manager: NfcToolManager)
    
    /// Got an unsupported device.
    func nfcToolManagerGotUnsupportedDevice(_ manager: NfcToolManager)
    
    // Nfc read, write succeeded.
    func nfcToolManagerDidSucceeded(_ manager: NfcToolManager)
}

extension NfcToolManagerDelegate {
    
    public func nfcToolManagerDidFailed(_ manager: NfcToolManager) {}
    
    public func nfcToolManagerGotUnsupportedDevice(_ manager: NfcToolManager) {}
    
    public func nfcToolManagerDidSucceeded(_ manager: NfcToolManager) {}
    
}

/**
 This class includes the features from the SRNFCTool App. It's only available for the BLE NFC devices.
 */
public class NfcToolManager: NSObject {
    
    public static let shared = NfcToolManager()
    
    public weak var delegate: NfcToolManagerDelegate?
    
    private var succeededMessage = "Succeeded!"
    private var failedMessage = "Failed!"
    private var unsupportedDeviceMessage = "Unsupported Device!"
    private var action = Action.none
    
    private override init() {
        super.init()
        
    }
    
    private enum Action {
        
        case none
        case resetDevice
    }
    
    private enum DeviceType: Int {
        
        case bleDim = 0x03000001
        case bleCct = 0x03000002
        
        static let all: [DeviceType] = [
            .bleDim, .bleCct
        ]
    }
    
}

extension NfcToolManager {
    
    /**
     - parameters:
        - alertMessage: Will display on the alert view.
        - succeeded: Succeeded message.
        - failed: Failed message.
     */
    @available(iOS 13.0, *)
    public func resetDevice(alertMessage: String, succeededMessage: String, failedMessage: String, unsupportedDeviceMessage: String) {
                
        self.succeededMessage = succeededMessage
        self.failedMessage = failedMessage
        self.unsupportedDeviceMessage = unsupportedDeviceMessage
        
        action = .resetDevice
        let session = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self)
        session?.alertMessage = alertMessage
        session?.begin()
    }
    
}


@available(iOS 13.0, *)
extension NfcToolManager: NFCTagReaderSessionDelegate {
    
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        
        NSLog("tagReaderSessionDidBecomeActive", "")
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        
        NSLog("tagReaderSession didInvalidateWithError \(error.localizedDescription)", "")
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        
        NSLog("tagReaderSession didDetect tags \(tags.count)", "")
        
        guard tags.count > 0 else {
            
            session.invalidate(errorMessage: failedMessage)
            self.delegate?.nfcToolManagerDidFailed(self)
            return
        }
        
        for tag in tags {
            
            switch tag {
                
            case .miFare(let miFareTag):
                
                NSLog("connect to miFareTag \(miFareTag)", "")
                
                session.connect(to: tag) { connectError in
                    
                    guard connectError == nil else {
                        
                        NSLog("connectError \(connectError!.localizedDescription)", "")
                        session.invalidate(errorMessage: self.failedMessage)
                        self.delegate?.nfcToolManagerDidFailed(self)
                        return
                    }
                    
                    self.sendAuth(session: session, tag: miFareTag) {
                        
                        switch self.action {
                        case .none:
                            break
                        case .resetDevice:
                            self.resetDevice(session: session, tag: miFareTag)
                        }
                    }
                }
                
            default:
                session.invalidate(errorMessage: failedMessage)
                self.delegate?.nfcToolManagerDidFailed(self)
            }
        }
    }
    
    private func sendAuth(session: NFCTagReaderSession, tag: NFCMiFareTag, success: @escaping () -> Void) {
        
        let authData = Data([0x1B, 0x33, 0x38, 0x33, 0x39])
        tag.sendMiFareCommand(commandPacket: authData) { _, error in
            
            guard error == nil else {
                
                NSLog("Write auth error \(error!.localizedDescription)", "")
                
                session.invalidate(errorMessage: self.failedMessage)
                self.delegate?.nfcToolManagerDidFailed(self)
                return
            }
            
            success()
        }
    }
    
    private func resetDevice(session: NFCTagReaderSession, tag: NFCMiFareTag) {
        
        readProductId(session: session, tag: tag) {
            
            let resetData = Data([0xA2, 69, 0x55, 0x01, 0x01, 0x01])
            tag.sendMiFareCommand(commandPacket: resetData) { data, error in
                
                guard error == nil else {
                    
                    session.invalidate(errorMessage: self.failedMessage)
                    self.delegate?.nfcToolManagerDidFailed(self)
                    return
                }
                
                self.action = .none
                session.alertMessage = self.succeededMessage
                session.invalidate()
                self.delegate?.nfcToolManagerDidSucceeded(self)
            }
        }
    }
    
    private func readProductId(session: NFCTagReaderSession, tag: NFCMiFareTag, success: @escaping () -> Void) {
        
        let readData = Data([0x30, 0x07])
        tag.sendMiFareCommand(commandPacket: readData) { data, error in
            
            guard error == nil else {
                session.invalidate(errorMessage: self.failedMessage)
                self.delegate?.nfcToolManagerDidFailed(self)
                return
            }
            
            NSLog("readProductId \(data.hexString)", "")
            let v1 = Int(data[0]) << 24
            let v2 = Int(data[1]) << 16
            let v3 = Int(data[2]) << 8
            let v4 = Int(data[3]) << 0
            let productIdInt = v1 | v2 | v3 | v4
            guard DeviceType.all.contains(where: { $0.rawValue == productIdInt }) else {
                
                session.invalidate(errorMessage: self.unsupportedDeviceMessage)
                self.delegate?.nfcToolManagerGotUnsupportedDevice(self)
                return
            }
            
            success()
        }
    }
}
