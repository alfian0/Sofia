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

extension Date {
  var startOfDay: Date {
    return Calendar.current.startOfDay(for: self)
  }

  var endOfDay: Date {
    var components = DateComponents()
    components.day = 1
    components.second = -1
    return Calendar.current.date(byAdding: components, to: startOfDay)!
  }

  var startOfWeek: Date {
    Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
  }

  var endOfWeek: Date {
    var components = DateComponents()
    components.weekOfYear = 1
    components.second = -1
    return Calendar.current.date(byAdding: components, to: startOfWeek)!
  }

  var startOfMonth: Date {
    let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
    return Calendar.current.date(from: components)!
  }

  var endOfMonth: Date {
    var components = DateComponents()
    components.month = 1
    components.second = -1
    return Calendar.current.date(byAdding: components, to: startOfMonth)!
  }
}
