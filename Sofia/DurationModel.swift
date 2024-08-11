//
//  DurationModel.swift
//  Sofia
//
//  Created by alfian on 11/08/24.
//

import Foundation

// MARK: - DurationModel
struct DurationModel: Codable {
  let data: [Datum]?
  let start, end: String?
  let timezone: String?
  let color: String?
  let branches, availableBranches: [String]?

  // MARK: - Datum
  struct Datum: Codable, Identifiable {
    var id: String {
      return UUID().uuidString
    }
    let entity: String?
    let type: String?
    let time: Double?
    let project: String?
    let projectRootCount: Int?
    let branch: String?
    let language: String?
    let dependencies: [String]?
    let duration: Double?
  }
}
