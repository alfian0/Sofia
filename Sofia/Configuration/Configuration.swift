//
//  Configuration.swift
//  Sofia
//
//  Created by alfian on 09/08/24.
//

import Foundation
import os.log

enum Configuration {
  enum Error: Swift.Error {
    case missingKey, invalidValue
  }

  static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
    guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
      os_log("Missing key: %@", log: .default, type: .error, key)
      throw Error.missingKey
    }

    if let value = object as? T {
      return value
    } else if let string = object as? String, let value = T(string) {
      return value
    } else {
      os_log("Invalid value for key: %@", log: .default, type: .error, key)
      throw Error.invalidValue
    }
  }
}

enum API {
  static var clientID: String {
    return (try? Configuration.value(for: "CLIENT_ID")) ?? ""
  }

  static var clientSecret: String {
    return (try? Configuration.value(for: "CLIENT_SECRET")) ?? ""
  }

  static var githubClientID: String {
    return (try? Configuration.value(for: "GITHUB_CLIENT_ID")) ?? ""
  }

  static var githubClientSecret: String {
    return (try? Configuration.value(for: "GITHUB_CLIENT_SECRET")) ?? ""
  }
}
