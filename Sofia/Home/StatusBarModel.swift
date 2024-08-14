//
//  StatusBarModel.swift
//  Sofia
//
//  Created by alfian on 09/08/24.
//

import Foundation

// MARK: - StatusBarModel

struct StatusBarModel: Codable {
  let cachedAt: String?
  let data: DataClass?
  let hasTeamFeatures: Bool?

  // MARK: - DataClass

  struct DataClass: Codable {
    let grandTotal: GrandTotal?
    let range: Range?
    let projects, languages, dependencies, machines: [Category]?
    let editors, operatingSystems, categories: [Category]?
  }

  // MARK: - Category

  struct Category: Codable, Identifiable {
    var id: String {
      return UUID().uuidString
    }

    let name: String?
    let totalSeconds: Double?
    let digital, decimal, text: String?
    let hours, minutes, seconds: Int?
    let percent: Double?
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
