//
//  SummariesPageViewModel.swift
//  Sofia
//
//  Created by Alfian on 24/08/24.
//

import Alamofire
import Combine
import Foundation
import KeychainSwift

@MainActor
class SummariesPageViewModel: ObservableObject {
  @Published var state: ViewState<SummariesModel> = .idle
  private var cancellables: Set<AnyCancellable> = []

  let start: String
  let end: String
  let project: String

  init(start: String, end: String, project: String) {
    self.start = start
    self.end = end
    self.project = project
  }

  func onAppear() {
    onRefresh()
  }

  func onRefresh() {
    struct SummariesRequest: Request {
      var path: String = "/api/v1/users/current/summaries"

      var method: Alamofire.HTTPMethod = .get

      var body: [String: Any]?

      var queryParams: [String: Any]?

      var headers: [String: String]?
    }

    state = .processing

    WakaAuthenticatedClient()?.publisher(SummariesModel.self, request: SummariesRequest(queryParams: [
      "start": start,
      "end": end,
      "project": project
    ]))
    .sink(result: { [weak self] result in
      guard let self = self else { return }

      switch result {
      case let .success(data):
        self.state = .success(data)
      case let .failure(error):
        self.state = .failure(error)
      }
    })
    .store(in: &cancellables)
  }
}
