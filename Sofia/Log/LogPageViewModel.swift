//
//  LogPageViewModel.swift
//  Sofia
//
//  Created by alfian on 13/08/24.
//

import Alamofire
import KeychainSwift
import SwiftUI

enum LogPageViewState {
  case processing
  case success([LogModel.Datum])
  case failure(Error)
  case idle
}

class LogPageViewModel: ObservableObject {
  @Published var viewState: LogPageViewState = .idle
  private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  func loadLogs() {
    guard let token = KeychainSwift().get("stringToken"), !token.isEmpty else {
      viewState = .failure(NSError(domain: "Token not found", code: -1, userInfo: nil))
      return
    }

    viewState = .processing
    AF.request(
      URL(string: "https://wakatime.com/api/v1/users/current/user_agents")!,
      headers: .init([.authorization(bearerToken: token)])
    ).responseDecodable(
      of: LogModel.self,
      decoder: decoder
    ) { response in
      switch response.result {
      case let .success(data):
        self.viewState = .success(data.data ?? [])
      case let .failure(error):
        self.viewState = .failure(error)
      }
    }
  }
}
