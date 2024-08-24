//
//  CommitPageViewModel.swift
//  Sofia
//
//  Created by Alfian on 24/08/24.
//

import Alamofire
import Foundation
import KeychainSwift

enum CommitPageState {
  case processing
  case success(CommitModel)
  case failure(Error)
  case idle
}

@MainActor
class CommitPageViewModel: ObservableObject {
  @Published var state: CommitPageState = .idle

  private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

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
    if let token = KeychainSwift().get("githubToken"),
       !token.isEmpty {
      state = .processing
      AF.request(
        URL(string: "https://api.github.com/repos/\(owner)/\(repo)/commits/\(ref)")!,
        headers: .init([.authorization(bearerToken: token)])
      ).responseDecodable(
        of: CommitModel.self,
        decoder: decoder
      ) { [weak self] response in
        guard let self = self else { return }

        switch response.result {
        case let .success(data):
          self.state = .success(data)
        case let .failure(error):
          self.state = .failure(error)
        }
      }
    }
  }

  func getTitle() -> String {
    return repo
  }
}
