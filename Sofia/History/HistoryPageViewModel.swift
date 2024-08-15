//
//  HistoryPageViewModel.swift
//  Sofia
//
//  Created by alfian on 15/08/24.
//

import Alamofire
import Foundation
import KeychainSwift

@MainActor
class HistoryPageViewModel: ObservableObject {
  @Published var state: HistoryPageState = .idle

  enum HistoryPageState {
    case processing
    case success(AllTimeModel)
    case failure(Error)
    case idle
  }

  private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  func onAppear() {
    onRefresh()
  }

  func onRefresh() {
    if let token = KeychainSwift().get("stringToken"),
       !token.isEmpty {
      state = .processing
      AF.request(
        URL(string: "https://wakatime.com/api/v1/users/current/all_time_since_today")!,
        headers: .init([.authorization(bearerToken: token)])
      ).responseDecodable(
        of: AllTimeModel.self,
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
