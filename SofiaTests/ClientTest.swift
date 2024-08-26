//
//  ClientTest.swift
//  SofiaTests
//
//  Created by Alfian on 26/08/24.
//

import Alamofire
import Combine
@testable import Sofia
import XCTest

final class ClientTest: XCTestCase {
  var client: HttpClient?
  var cancellables: Set<AnyCancellable> = []

  override func setUp() {
    super.setUp()

    client = WakaAuthenticatedClient()
  }

  override func tearDown() {
    client = nil
  }

  func test() {
    struct StatusBarRequest: Sofia.Request {
      var path: String = "/api/v1/users/current/status_bar/today"

      var method: Alamofire.HTTPMethod = .get

      var body: [String: Any]?

      var queryParams: [String: Any]?

      var headers: [String: String]?
    }

    client?.publisher(StatusBarModel.self, request: StatusBarRequest(), decoder: decoder)
      .sink(result: { result in
        print(result)
      })
      .store(in: &cancellables)
  }
}
