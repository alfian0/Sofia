//
//  LogModel.swift
//  Sofia
//
//  Created by alfian on 09/08/24.
//

import Foundation

// MARK: - LogModel
struct LogModel: Codable {
  let data: [Datum]?
  let total, totalPages, page: Int?
//  let prevPage, nextPage: NSNull?
  
  // MARK: - Datum
  struct Datum: Codable {
      let id, value: String?
      let createdAt: String?
      let isDesktopApp, isBrowserExtension: Bool?
      let version, cliVersion, os: String?
      let lastSeenAt: String?
      let goVersion, editor: String?
  }
}
