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
    struct UserRequest: Request {
      var path: String = "/user"

      var method: Alamofire.HTTPMethod = .get

      var body: [String: Any]?

      var queryParams: [String: Any]?

      var headers: [String: String]?
    }

    return client?.publisher(GithubUserModel.self, request: UserRequest())
  }

  func getCommit(owner: String, repo: String, ref: String) -> AnyPublisher<CommitModel, Error>? {
    struct CommitRequest: Request {
      var path: String

      var method: Alamofire.HTTPMethod = .get

      var body: [String: Any]?

      var queryParams: [String: Any]?

      var headers: [String: String]?
    }

    return client?.publisher(
      CommitModel.self,
      request: CommitRequest(path: "/repos/\(owner)/\(repo)/commits/\(ref)")
    )
  }

  func getCommits(user: String, project: String, start: String, end: String) -> AnyPublisher<[CommitsModel], Error>? {
    struct DurationRequest: Request {
      var path: String

      var method: Alamofire.HTTPMethod = .get

      var body: [String: Any]?

      var queryParams: [String: Any]?

      var headers: [String: String]?
    }

    let project = project.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!

    return GithubAuthenticatedClient()?.publisher(
      [CommitsModel].self,
      request: DurationRequest(path: "/repos/\(user)/\(project)/commits", queryParams: [
        "since": start,
        "until": end
      ])
    )
  }
}
