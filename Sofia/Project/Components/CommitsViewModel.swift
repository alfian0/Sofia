//
//  CommitsViewModel.swift
//  Sofia
//
//  Created by alfian on 15/08/24.
//

import Alamofire
import KeychainSwift
import SwiftUI

@MainActor
class CommitsViewModel: ObservableObject {
  @Published var state: CommitsViewState = .idle {
    didSet {
      switch state {
      case let .success(data):
        commitsCount = data.count
      default: return
      }
    }
  }

  @Binding var commitsCount: Int

  private let projectName: String
  private let start: String
  private let end: String

  enum CommitsViewState: Hashable {
    case processing
    case success([CommitsModel])
    case failure(Error)
    case idle

    func hash(into hasher: inout Hasher) {
      switch self {
      case .processing:
        hasher.combine(0)
      case let .success(data):
        hasher.combine(1)
        hasher.combine(data)
      case .failure:
        hasher.combine(2) // You can't hash the Error, but you can add a marker
      case .idle:
        hasher.combine(3)
      }
    }

    static func == (lhs: CommitsViewState, rhs: CommitsViewState) -> Bool {
      switch (lhs, rhs) {
      case (.processing, .processing):
        return true
      case let (.success(lhsData), .success(rhsData)):
        return lhsData == rhsData
      case let (.failure(lhsError), .failure(rhsError)):
        // You might compare error types or codes, but full equality is tricky
        return lhsError.localizedDescription == rhsError.localizedDescription
      case (.idle, .idle):
        return true
      default:
        return false
      }
    }
  }

  private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  init(projectName: String, start: String, end: String, commitsCount: Binding<Int>) {
    self.projectName = projectName
    self.start = start
    self.end = end
    _commitsCount = commitsCount
  }

  func onAppear() {
    onRefresh()
  }

  func onRefresh() {
    if let token = KeychainSwift().get("githubToken"),
       !token.isEmpty {
      state = .processing
      AF.request(
        URL(string: "https://api.github.com/user")!,
        headers: .init([.authorization(bearerToken: token)])
      ).responseDecodable(
        of: GithubUserModel.self,
        decoder: decoder
      ) { [weak self] response in
        guard let self = self else {
          fatalError("Not in the correct context")
        }
        switch response.result {
        case let .success(data):
          guard let user = data.login,
                let cleanPath = self.projectName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
                let url = URL(string: "https://api.github.com/repos/\(user)/\(cleanPath)/commits")
          else {
            self.state = .failure(NSError(domain: "Sofia", code: 404))
            return
          }
          AF.request(
            url,
            parameters: [
              "since": self.start,
              "until": self.end
            ],
            headers: .init([.authorization(bearerToken: token)])
          ).responseDecodable(
            of: [CommitsModel].self,
            decoder: self.decoder
          ) { response in
            switch response.result {
            case let .success(data):
              self.state = .success(data)
            case let .failure(error):
              self.state = .failure(error)
            }
          }
        case let .failure(error):
          self.state = .failure(error)
        }
      }
    }
  }

  func getProjectName() -> String {
    return projectName
  }

  func getStartOfDay() -> Double {
    return Calendar.current.startOfDay(for: start.toDate() ?? Date()).timeIntervalSince1970
  }
}
