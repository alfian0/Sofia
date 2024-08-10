//
//  AllTimeModel.swift
//  Sofia
//
//  Created by alfian on 10/08/24.
//

import Foundation

// MARK: - AllTimeModel
struct AllTimeModel: Codable {
  let data: DataClass?
  
  // MARK: - DataClass
  struct DataClass: Codable {
      let totalSeconds: Double?
      let text, decimal, digital: String?
      let dailyAverage: Double?
      let isUpToDate: Bool?
      let percentCalculated: Int?
      let range: Range?
      let timeout: Int?
  }

  // MARK: - Range
  struct Range: Codable {
      let start: String?
      let startDate, startText: String?
      let end: String?
      let endDate, endText, timezone: String?
  }
}
