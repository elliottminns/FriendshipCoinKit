//
//  DNS.swift
//  CoinKit
//
//  Created by Elliott Minns on 22/04/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

enum Result<T> {
  case success(T)
  case failure(Error)
}

final class DNSResolver {
  
  let hostName: String
  
  let host: CFHost
  
  var callback: ((_ addresses: Result<[String]>) -> Void)?
  
  private var targetRunLoop: RunLoop? = nil
  
  init(hostName: String) {
    self.hostName = hostName
    let cAddr: CFString = hostName as CFString
    host = CFHostCreateWithName(nil, cAddr).takeRetainedValue()
  }
  
  func resolve(callback: @escaping (_ addresses: Result<[String]>) -> Void) {
    precondition(self.targetRunLoop == nil)
    self.targetRunLoop = RunLoop.current
    var context = CFHostClientContext()
    self.callback = callback
    context.info = Unmanaged.passRetained(self).toOpaque()
    var success = CFHostSetClient(host, { (_ host: CFHost, _: CFHostInfoType, _ streamErrorPtr: UnsafePointer<CFStreamError>?, _ info: UnsafeMutableRawPointer?) in
      let obj = Unmanaged<DNSResolver>.fromOpaque(info!).takeUnretainedValue()
      if let streamError = streamErrorPtr?.pointee, (streamError.domain != 0 || streamError.error != 0) {
        obj.stop(streamError: streamError, notify: true)
      } else {
        obj.stop(streamError: nil, notify: true)
      }
    }, &context)
    assert(success)
    CFHostScheduleWithRunLoop(host, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    
    var streamError = CFStreamError()
    success = CFHostStartInfoResolution(host, .names, &streamError)
    if !success {
      self.stop(streamError: streamError, notify: true)
    }
  }
  
  private func stop(streamError: CFStreamError?, notify: Bool) {
    let error: Error?
    if let streamError = streamError {
      // Convert a CFStreamError to a NSError.  This is less than ideal because I only handle
      // a limited number of error domains.  Wouldn't it be nice if there was a public API to
      // do this mapping <rdar://problem/5845848> or a CFHost API that used CFError
      // <rdar://problem/6016542>.
      switch streamError.domain {
      case CFStreamErrorDomain.POSIX.rawValue:
        error = NSError(domain: NSPOSIXErrorDomain, code: Int(streamError.error))
      case CFStreamErrorDomain.macOSStatus.rawValue:
        error = NSError(domain: NSOSStatusErrorDomain, code: Int(streamError.error))
      case Int(kCFStreamErrorDomainNetServices):
        error = NSError(domain: kCFErrorDomainCFNetwork as String, code: Int(streamError.error))
      case Int(kCFStreamErrorDomainNetDB):
        error = NSError(domain: kCFErrorDomainCFNetwork as String, code: Int(CFNetworkErrors.cfHostErrorUnknown.rawValue), userInfo: [
          kCFGetAddrInfoFailureKey as String: streamError.error as NSNumber
          ])
      default:
        // If it's something we don't understand, we just assume it comes from
        // CFNetwork.
        error = NSError(domain: kCFErrorDomainCFNetwork as String, code: Int(streamError.error))
      }
    } else {
      error = nil
    }
    self.stop(error: error, notify: notify)
  }
  
  /// Stops the query with the supplied error, notifying the delegate if `notify` is true.
  
  private func stop(error: Error?, notify: Bool) {
    CFHostSetClient(self.host, nil, nil)
    CFHostUnscheduleFromRunLoop(self.host, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    CFHostCancelInfoResolution(self.host, .names)
    Unmanaged.passUnretained(self).release()
    
    if notify {
      if let error = error {
        callback?(Result.failure(error))
      } else {
        let addresses = CFHostGetAddressing(self.host, nil)!.takeUnretainedValue() as NSArray as? [String] ?? []
        callback?(.success(addresses))
      }
    }
  }
  
  /// Cancels a running query.
  ///
  /// If you successfully cancel a query, no delegate callback for that query will be
  /// called.
  ///
  /// If the query is running, you must call this from the thread that called `start()`.
  ///
  /// - Note: It is acceptable to call this on a query that's not running; it does nothing
  //    in that case.
  
  func cancel() {
    if self.targetRunLoop != nil {
      self.stop(error: NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil), notify: false)
    }
  }
}
