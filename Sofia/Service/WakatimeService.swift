//
//  WakatimeService.swift
//  Sofia
//
//  Created by Alfian on 26/08/24.
//

import Alamofire
import Combine
import Foundation

final class WakatimeAuthenticatedService {
  private let client: WakaAuthenticatedClient?

  static var shared: WakatimeAuthenticatedService {
    return WakatimeAuthenticatedService(client: WakaAuthenticatedClient())
  }

  private init(client: WakaAuthenticatedClient?) {
    self.client = client
  }

  func getSummaries(start: String, end: String, project: String) -> AnyPublisher<SummariesModel, Error>? {
    return client?.publisher(
      SummariesModel.self,
      request: RequestImpl(path: "/api/v1/users/current/summaries", method: .get, queryParams: [
        "start": start,
        "end": end,
        "project": project
      ])
    )
  }

  func getAllTime() -> AnyPublisher<AllTimeModel, Error>? {
    return client?.publisher(
      AllTimeModel.self,
      request: RequestImpl(path: "/api/v1/users/current/all_time_since_today", method: .get)
    )
  }

  func getStatusBar() -> AnyPublisher<StatusBarModel, Error>? {
    return client?.publisher(
      StatusBarModel.self,
      request: RequestImpl(path: "/api/v1/users/current/status_bar/today", method: .get)
    )
  }

  func getLog() -> AnyPublisher<LogModel, Error>? {
    return client?.publisher(
      LogModel.self,
      request: RequestImpl(path: "/api/v1/users/current/user_agents", method: .get)
    )
  }

  func getDuration(date: String, name: String) -> AnyPublisher<DurationModel, Error>? {
    return client?.publisher(
      DurationModel.self,
      request: RequestImpl(path: "/api/v1/users/current/durations", method: .get, queryParams: [
        "date": date,
        "project": name,
        "timeout": 15
      ])
    )
  }

  func getUser() -> AnyPublisher<UserModel, Error>? {
    return client?.publisher(UserModel.self, request: RequestImpl(path: "/api/v1/users/current", method: .get))
  }
}
