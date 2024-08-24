//
//  SummariesPageViewModel.swift
//  Sofia
//
//  Created by Alfian on 24/08/24.
//

import Alamofire
import Foundation
import KeychainSwift

enum SummariesPageState {
  case processing
  case success(SummariesModel)
  case failure(Error)
  case idle
}

@MainActor
class SummariesPageViewModel: ObservableObject {
  @Published var state: SummariesPageState = .idle

  private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

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
    if let token = KeychainSwift().get("stringToken"),
       !token.isEmpty {
      state = .processing
      AF.request(
        URL(string: "https://wakatime.com/api/v1/users/current/summaries")!,
        parameters: [
          "start": start,
          "end": end,
          "project": project
        ],
        headers: .init([.authorization(bearerToken: token)])
      ).responseDecodable(
        of: SummariesModel.self,
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
}
