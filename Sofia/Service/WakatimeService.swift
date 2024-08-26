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
    struct SummariesRequest: Request {
      var path: String = "/api/v1/users/current/summaries"

      var method: Alamofire.HTTPMethod = .get

      var body: [String: Any]?

      var queryParams: [String: Any]?

      var headers: [String: String]?
    }

    return client?.publisher(SummariesModel.self, request: SummariesRequest(queryParams: [
      "start": start,
      "end": end,
      "project": project
    ]))
  }

  func getAllTime() -> AnyPublisher<AllTimeModel, Error>? {
    struct AllTimeRequest: Request {
      var path: String = "/api/v1/users/current/all_time_since_today"

      var method: Alamofire.HTTPMethod = .get

      var body: [String: Any]?

      var queryParams: [String: Any]?

      var headers: [String: String]?
    }

    return client?.publisher(AllTimeModel.self, request: AllTimeRequest())
  }

  func getStatusBar() -> AnyPublisher<StatusBarModel, Error>? {
    struct StatusBarRequest: Request {
      var path: String = "/api/v1/users/current/status_bar/today"

      var method: Alamofire.HTTPMethod = .get

      var body: [String: Any]?

      var queryParams: [String: Any]?

      var headers: [String: String]?
    }

    return client?.publisher(StatusBarModel.self, request: StatusBarRequest())
  }

  func getLog() -> AnyPublisher<LogModel, Error>? {
    struct LogRequest: Request {
      var path: String = "/api/v1/users/current/user_agents"

      var method: Alamofire.HTTPMethod = .get

      var body: [String: Any]?

      var queryParams: [String: Any]?

      var headers: [String: String]?
    }

    return client?.publisher(LogModel.self, request: LogRequest())
  }

  func getDuration(date: String, name: String) -> AnyPublisher<DurationModel, Error>? {
    struct DurationRequest: Request {
      var path: String = "/api/v1/users/current/durations"

      var method: Alamofire.HTTPMethod = .get

      var body: [String: Any]?

      var queryParams: [String: Any]?

      var headers: [String: String]?
    }

    return client?.publisher(DurationModel.self, request: DurationRequest(queryParams: [
      "date": date,
      "project": name,
      "timeout": 15
    ]))
  }

  func getUser() -> AnyPublisher<UserModel, Error>? {
    struct UserRequest: Request {
      var path: String = "/api/v1/users/current"

      var method: Alamofire.HTTPMethod = .get

      var body: [String: Any]?

      var queryParams: [String: Any]?

      var headers: [String: String]?
    }

    return client?.publisher(UserModel.self, request: UserRequest())
  }
}
