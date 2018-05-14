//
//  Connection.swift
//  CoinKit
//
//  Created by Elliott Minns on 23/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

protocol ConnectionDelegate {
  func connection(_ connection: Connection, didReceiveData data: Data)
  func connectionDidClose(_ connection: Connection)
}

extension Data {
  init(reading input: InputStream) {
    self.init()
    let bufferSize = 1024
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    while input.hasBytesAvailable {
      let read = input.read(buffer, maxLength: bufferSize)
      self.append(buffer, count: read)
    }
    buffer.deallocate()
  }
}

class Connection: NSObject {
  
  enum Error: Swift.Error {
    case somethingWentWrong
  }
  
  fileprivate var inputStream: InputStream?
  fileprivate var outputStream: OutputStream?
  
  let queue: DispatchQueue
  
  var callback: ((Result<Void>) -> Void)?
  
  var delegate: ConnectionDelegate?
  
  let address: String
  
  let port: UInt32
  
  var inputOpened: Bool {
    didSet {
      checkConnection()
    }
  }
  
  var outputOpened: Bool {
    didSet {
      checkConnection()
    }
  }
  
  init(address: String, port: UInt32) {
    self.address = address
    self.port = port
    self.inputOpened = false
    self.outputOpened = false
    self.queue = DispatchQueue(label: "\(self.address).queue")
    super.init()
  }
  
  func connect(callback: @escaping (Result<Void>) -> Void) {
    self.callback = callback
    
    Stream.getStreamsToHost(withName: address,
                            port: Int(port),
                            inputStream: &inputStream,
                            outputStream: &outputStream)
    
    if inputStream != nil && outputStream != nil {
      
      // Set delegate
      inputStream!.delegate = self
      outputStream!.delegate = self
      
      // Schedule
      inputStream!.schedule(in: .main, forMode: .commonModes)
      outputStream!.schedule(in: .main, forMode: .commonModes)
      
      // Open!
      inputStream!.open()
      outputStream!.open()
    }
  }
  
  func read() {
  }
  
  func close() {
    self.inputStream?.close()
    self.outputStream?.close()
    self.delegate?.connectionDidClose(self)
  }
  
  func checkConnection() {
    guard inputOpened && outputOpened, let callback = callback else { return }
    DispatchQueue.main.async {
      callback(.success(Void()))
    }
  }
  
  func on(error: Swift.Error) {
    if !inputOpened || !outputOpened {
      DispatchQueue.main.async {
        self.callback?(.failure(error))
      }
    }
  }
  
  func write(data: Data) {
    guard let os = outputStream, outputOpened else { return }
    queue.async {
      _ = data.withUnsafeBytes {
        os.write($0, maxLength: data.count)
      }
    }
  }
}

extension Connection: StreamDelegate {
  func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    if aStream === inputStream {
      switch eventCode {
      case Stream.Event.errorOccurred:
        self.on(error: aStream.streamError ?? Error.somethingWentWrong)
      case Stream.Event.openCompleted:
        inputOpened = true
      case Stream.Event.endEncountered:
        close()
      case Stream.Event.hasBytesAvailable:
        if let input = inputStream {
          let data = Data(reading: input)
          queue.async {
            self.delegate?.connection(self, didReceiveData: data)
          }
        }
        
      default:
        break
      }
    }
    else if aStream === outputStream {
      switch eventCode {
      case Stream.Event.errorOccurred:
        self.on(error: aStream.streamError ?? Error.somethingWentWrong)
      case Stream.Event.openCompleted:
        outputOpened = true
      case Stream.Event.hasSpaceAvailable: break
      case Stream.Event.endEncountered:
        close()
      default: break
      }
    }
  }
}
