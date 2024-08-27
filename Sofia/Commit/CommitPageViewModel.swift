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
  @Published var state: ViewState<[CommitModelView]> = .idle
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
    state = .processing
    GithubAuthenticatedService.shared.getCommit(owner: owner, repo: repo, ref: ref)?
      .sink(result: { [weak self] result in
        guard let self = self else { return }

        switch result {
        case let .success(data):
          self.state = .success(data.files?.map { CommitModelView(
            filename: $0.filename ?? "",
            additions: Double($0.additions ?? 0),
            deletions: Double($0.deletions ?? 0)
          ) } ?? [])
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
