//
//  LogPageViewModel.swift
//  Sofia
//
//  Created by alfian on 13/08/24.
//

import Alamofire
import Combine
import KeychainSwift
import SwiftUI

class LogPageViewModel: ObservableObject {
  @Published var state: ViewState<[LogModel.Datum]> = .idle
  private var cancellables: Set<AnyCancellable> = []

  func onAppear() {
    onRefresh()
  }

  func onRefresh() {
    struct LogRequest: Request {
      var path: String = "/api/v1/users/current/user_agents"

      var method: Alamofire.HTTPMethod = .get

      var body: [String: Any]?

      var queryParams: [String: Any]?

      var headers: [String: String]?
    }

    state = .processing

    WakaAuthenticatedClient()?.publisher(LogModel.self, request: LogRequest())
      .sink(result: { [weak self] result in
        guard let self = self else { return }
        switch result {
        case let .success(data):
          self.state = .success(data.data ?? [])
        case let .failure(error):
          self.state = .failure(error)
        }
      })
      .store(in: &cancellables)
  }
}
