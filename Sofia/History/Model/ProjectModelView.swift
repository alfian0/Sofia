//
//  ProjectModelView.swift
//  Sofia
//
//  Created by Alfian on 27/08/24.
//

import Foundation

struct ProjectModelView: Equatable, Identifiable {
  var id: String {
    return UUID().uuidString
  }

  let projectName: String
  let createdAt: String
  let firstHeartbeatAt: String
  let lastHeartbeatAt: String
}
