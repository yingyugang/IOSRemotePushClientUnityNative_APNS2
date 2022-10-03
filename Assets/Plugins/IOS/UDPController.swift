//
//  UDPController.swift
//  Unity-iPhone
//
//  Created by 应彧刚 on 2022/10/3.
//

import Foundation
import Network

var connection: NWConnection?
var hostUDP: NWEndpoint.Host = "192.168.11.2"
var portUDP: NWEndpoint.Port = 9091

class UDPController : NSObject{
   
    func connet(){
        connectToUDP(hostUDP,portUDP)
    }

    func connectToUDP(_ hostUDP: NWEndpoint.Host, _ portUDP: NWEndpoint.Port) {
        // Transmited message:
        let messageToUDP = "Test message"

        self.connection = NWConnection(host: hostUDP, port: portUDP, using: .udp)

        self.connection?.stateUpdateHandler = { (newState) in
            print("This is stateUpdateHandler:")
            switch (newState) {
                case .ready:
                    print("State: Ready\n")
                    self.sendUDP(messageToUDP)
                    self.receiveUDP()
                case .setup:
                    print("State: Setup\n")
                case .cancelled:
                    print("State: Cancelled\n")
                case .preparing:
                    print("State: Preparing\n")
                default:
                    print("ERROR! State not defined!\n")
            }
        }

        self.connection?.start(queue: .global())
    }

    func sendUDP(_ content: Data) {
        self.connection?.send(content: content, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                print("Data was sent to UDP")
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }

    func sendUDP(_ content: String) {
        let contentToSendUDP = content.data(using: String.Encoding.utf8)
        self.connection?.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                print("Data was sent to UDP")
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }

    func receiveUDP() {
        self.connection?.receiveMessage { (data, context, isComplete, error) in
            if (isComplete) {
                print("Receive is complete")
                if (data != nil) {
                    let backToString = String(decoding: data!, as: UTF8.self)
                    print("Received message: \(backToString)")
                } else {
                    print("Data == nil")
                }
            }
        }
    }
}
