//
//  ProjectPageUseCase.swift
//  Sofia
//
//  Created by Alfian on 26/08/24.
//

import Combine
import Foundation

final class ProjectPageUseCase {
  func getData(project: String, start: String, end: String) -> AnyPublisher<(DurationModel, [CommitsModel]), Error> {
    guard let githubUser = GithubAuthenticatedService.shared.getUser() else {
      return Fail(error: NSError(domain: "Sofia", code: 401))
        .eraseToAnyPublisher()
    }

    let commits = githubUser
      .flatMap { user in
        guard let commits = GithubAuthenticatedService.shared.getCommits(
          user: user.login ?? "",
          project: project,
          start: start,
          end: end
        ) else {
          return Fail<[CommitsModel], Error>(error: NSError(domain: "Sofia", code: 404))
            .eraseToAnyPublisher()
        }

        return commits
      }

    guard let date = start.toDate()?.toString(with: "YYYY-MM-dd") else {
      return Fail(error: NSError(domain: "Sofia", code: 404))
        .eraseToAnyPublisher()
    }

    guard let duration = WakatimeAuthenticatedService.shared.getDuration(date: date, project: project) else {
      return Fail(error: NSError(domain: "Sofia", code: 401))
        .eraseToAnyPublisher()
    }

    return Publishers.CombineLatest(duration, commits).eraseToAnyPublisher()
  }
}
