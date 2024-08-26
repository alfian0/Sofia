//
//  CommitPageViewModel.swift
//  Sofia
//
//  Created by Alfian on 24/08/24.
//

import Alamofire
import Combine
import Foundation
import KeychainSwift

@MainActor
class CommitPageViewModel: ObservableObject {
  @Published var state: ViewState<CommitModel> = .idle
  private var cancellables: Set<AnyCancellable> = []

  let owner: String
  let repo: String
  let ref: String

  init(owner: String, repo: String, ref: String) {
    self.owner = owner
    self.repo = repo
    self.ref = ref
  }

  func onAppear() {
    onRefresh()
  }

  func onRefresh() {
    struct CommitRequest: Request {
      var path: String

      var method: Alamofire.HTTPMethod = .get

      var body: [String: Any]?

      var queryParams: [String: Any]?

      var headers: [String: String]?
    }

    state = .processing

    GithubAuthenticatedClient()?.publisher(
      CommitModel.self,
      request: CommitRequest(path: "/repos/\(owner)/\(repo)/commits/\(ref)")
    )
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

  func getTitle() -> String {
    return repo
  }
}
