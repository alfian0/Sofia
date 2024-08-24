//
//  SummariesModel.swift
//  Sofia
//
//  Created by alfian on 12/08/24.
//

import Foundation

// MARK: - SummariesModel

struct SummariesModel: Codable {
  let data: [Datum]?
  let start, end: String?
  let branches: [String?]?
  let availableBranches: [String]?
  let color: String?
  let cumulativeTotal: CumulativeTotal?
  let dailyAverage: DailyAverage?

  // MARK: - CumulativeTotal

  struct CumulativeTotal: Codable {
    let seconds: Double?
    let text, digital, decimal: String?
  }

  // MARK: - DailyAverage

  struct DailyAverage: Codable {
    let holidays, daysMinusHolidays, daysIncludingHolidays, seconds: Int?
    let secondsIncludingOtherLanguage: Int?
    let text, textIncludingOtherLanguage: String?
  }

  // MARK: - Datum

  struct Datum: Codable {
    let grandTotal: GrandTotal?
    let range: Range?
    let entities, branches, languages, dependencies: [Branch]?
    let editors, operatingSystems, categories, machines: [Branch]?
  }

  // MARK: - Branch

  struct Branch: Codable {
    let name: String?
    let totalSeconds: Double?
    let digital, decimal, text: String?
    let hours, minutes, seconds: Int?
    let percent: Double?
    let type: String?
    let projectRootCount: Int?
    let machineNameID: String?
  }

  // MARK: - GrandTotal

  struct GrandTotal: Codable {
    let hours, minutes: Int?
    let totalSeconds: Double?
    let digital, decimal, text: String?
  }

  // MARK: - Range

  struct Range: Codable {
    let start, end: String?
    let date, text, timezone: String?
  }
}
