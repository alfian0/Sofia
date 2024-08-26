//
//  GithubService.swift
//  Sofia
//
//  Created by Alfian on 26/08/24.
//

import Alamofire
import Combine
import Foundation

final class GithubAuthenticatedService {
  private let client: GithubAuthenticatedClient?

  static var shared: GithubAuthenticatedService {
    return GithubAuthenticatedService(client: GithubAuthenticatedClient())
  }

  private init(client: GithubAuthenticatedClient?) {
    self.client = client
  }

  func getUser() -> AnyPublisher<GithubUserModel, Error>? {
    return client?.publisher(GithubUserModel.self, request: RequestImpl(path: "/user", method: .get))
  }

  func getCommit(owner: String, repo: String, ref: String) -> AnyPublisher<CommitModel, Error>? {
    return client?.publisher(
      CommitModel.self,
      request: RequestImpl(path: "/repos/\(owner)/\(repo)/commits/\(ref)", method: .get)
    )
  }

  func getCommits(user: String, project: String, start: String, end: String) -> AnyPublisher<[CommitsModel], Error>? {
    let project = project.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!

    return client?.publisher(
      [CommitsModel].self,
      request: RequestImpl(path: "/repos/\(user)/\(project)/commits", method: .get, queryParams: [
        "since": start,
        "until": end
      ])
    )
  }
}
