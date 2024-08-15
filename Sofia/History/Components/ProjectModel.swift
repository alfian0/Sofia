//
//  ProjectModel.swift
//  Sofia
//
//  Created by alfian on 10/08/24.
//

import Foundation

// MARK: - ProjectModel

struct ProjectModel: Codable {
  let data: [Datum]?
  let total, totalPages, page: Int?
  let prevPage, nextPage: String?

  // MARK: - Datum

  struct Datum: Codable, Identifiable {
    let id, name: String?
    let color: String?
    let firstHeartbeatAt, lastHeartbeatAt, createdAt: String?
//    let badge: String?
//      let clients: [Any?]?
    let humanReadableLastHeartbeatAt: String?
    let repository: String?
    let hasPublicURL: Bool?
    let humanReadableFirstHeartbeatAt, url, urlencodedName: String?
  }
}
