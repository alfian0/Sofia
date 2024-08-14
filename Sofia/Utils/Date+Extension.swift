//
//  Date+Extension.swift
//  Sofia
//
//  Created by alfian on 13/08/24.
//

import Foundation

extension String {
  func toDate() -> Date? {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter.date(from: self)
  }
}

extension Date {
  func toString(
    with format: String = "yyyy-MM-dd HH:mm:ss",
    identifier: String = "Asia/Jakarta"
  ) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: identifier)
    dateFormatter.dateFormat = format

    return dateFormatter.string(from: self)
  }
}
