//
//  ProjectsPageViewModel.swift
//  Sofia
//
//  Created by alfian on 16/08/24.
//

import Alamofire
import Combine
import Foundation
import KeychainSwift

struct DurationM {
  let timestamp: Double
  let duration: Double
}

struct CommitM {
  let sessionStarted: Double
  let timestamp: Double
  let duration: Double
  let totalDuration: Double
  let message: String
  let avatarURL: String
}

@MainActor
class ProjectsPageViewModel: ObservableObject {
  @Published var state: ViewState<([DurationM], [CommitM])> = .idle
  private var cancellables: Set<AnyCancellable> = []

  private let projectName: String
  private let start: String
  private let end: String

  init(projectName: String, start: String, end: String) {
    self.projectName = projectName
    self.start = start
    self.end = end
  }

  func onAppear() {
    onRefresh()
  }

  func onRefresh() {
    guard let githubToken = KeychainSwift().get("githubToken"),
          !githubToken.isEmpty else {
      return
    }

    guard let githubUser = getGithubUser(token: githubToken) else {
      return
    }

    let commits = githubUser
      .flatMap { user in
        guard let commits = self.getGithubCommits(
          token: githubToken,
          user: user.login ?? "",
          project: self.projectName,
          start: self.start,
          end: self.end
        ) else {
          return Fail<[CommitsModel], Error>(error: NSError(domain: "Sofia", code: 404))
            .eraseToAnyPublisher()
        }

        return commits
      }

    guard let wakatiemToken = KeychainSwift().get("stringToken"),
          !wakatiemToken.isEmpty else {
      return
    }

    guard let date = start.toDate()?.toString(with: "YYYY-MM-dd") else {
      return
    }

    guard let duration = WakatimeAuthenticatedService.shared.getDuration(date: date, name: projectName) else {
      return
    }

    Publishers.CombineLatest(duration, commits)
      .sink(result: { [weak self] result in
        guard let self = self else { return }
        switch result {
        case let .success(value):
          let durations = value.0.data?.map { DurationM(timestamp: $0.time ?? 0, duration: $0.duration ?? 0) } ?? []

          let commits = value.1.reversed().enumerated().map { model in
            let timestamp = model.element.commit?.committer?.date?.toDate()?.timeIntervalSince1970 ?? 0
            var start = Date().timeIntervalSince1970
            let end = timestamp

            if model.offset == 0 {
              start = durations.first?.timestamp ?? 0
            } else {
              start = value.1.reversed()[model.offset - 1].commit?.committer?.date?.toDate()?
                .timeIntervalSince1970 ?? 0
            }

            let codingTime = durations.filter { model in
              model.timestamp > start && model.timestamp < end
            }.reduce(0) { result, data in
              result + data.duration
            }

            let totalTime = end - start

            return CommitM(
              sessionStarted: start,
              timestamp: timestamp,
              duration: codingTime > totalTime ? totalTime : codingTime,
              totalDuration: totalTime,
              message: model.element.commit?.message ?? "",
              avatarURL: model.element.committer?.avatarUrl ?? ""
            )
          }

          self.state = .success((durations, commits.reversed()))
        case let .failure(error):
          self.state = .failure(error)
        }
      })
      .store(in: &cancellables)
  }

  func getGithubUser(token _: String) -> AnyPublisher<GithubUserModel, Error>? {
    struct UserRequest: Request {
      var path: String = "/user"

      var method: Alamofire.HTTPMethod = .get

      var body: [String: Any]?

      var queryParams: [String: Any]?

      var headers: [String: String]?
    }

    return GithubAuthenticatedClient()?.publisher(GithubUserModel.self, request: UserRequest())
  }

  func getGithubCommits(token _: String, user: String, project: String, start: String,
                        end: String) -> AnyPublisher<[CommitsModel], Error>? {
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

//  // Enum to represent ranges
//  enum Range {
//    case low
//    case average
//    case high
//  }
//
//  // Function to determine the range for coding time or commits
//  func determineRange(for value: Double, lowThreshold: Double, highThreshold: Double) -> Range {
//    if value < lowThreshold {
//      return .low
//    } else if value > highThreshold {
//      return .high
//    } else {
//      return .average
//    }
//  }
//
//  func generateDailyComparisonInsight(
//    codingTime: Double,
//    commits: Int
//  ) -> String {
//    let lowThresholdCoding = 2.0
//    let highThresholdCoding = 6.0
//    let lowThresholdCommits = 5
//    let highThresholdCommits = 12
//
//    let now = start.toDate() ?? Date()
//    let startOfWorkday = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: now)!
//    let endOfWorkday = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: now)!
//
//    let workdayProgress = calculateWorkdayProgress(
//      startOfWorkday: startOfWorkday,
//      endOfWorkday: endOfWorkday
//    )
//
//    let codingTimeRange = determineRange(
//      for: codingTime,
//      lowThreshold: lowThresholdCoding * workdayProgress,
//      highThreshold: highThresholdCoding * workdayProgress
//    )
//
//    let commitsRange = determineRange(
//      for: Double(commits),
//      lowThreshold: Double(lowThresholdCommits) * workdayProgress,
//      highThreshold: Double(highThresholdCommits) * workdayProgress
//    )
//
//    let timeSpecificMessage = generateTimeSpecificMessage(workdayProgress: workdayProgress)
//    let insight = generateInsight(codingTimeRange: codingTimeRange, commitsRange: commitsRange)
//
//    return timeSpecificMessage + insight
//  }
//
//  private func calculateWorkdayProgress(
//    startOfWorkday: Date,
//    endOfWorkday: Date
//  ) -> Double {
//    let now = Calendar.current.isDateInToday(startOfWorkday) ? Date() : Calendar.current.startOfDay(for:
//    startOfWorkday)
//    let totalWorkdayDuration = endOfWorkday.timeIntervalSince(startOfWorkday)
//    let elapsedWorkdayDuration = abs(now.timeIntervalSince(startOfWorkday))
//    return elapsedWorkdayDuration / totalWorkdayDuration
//  }
//
//  private func generateTimeSpecificMessage(workdayProgress: Double) -> String {
//    switch workdayProgress {
//    case 0 ..< 0.25:
//      return "It's early in the day. "
//    case 0.25 ..< 0.75:
//      return "You're in the middle of your workday. "
//    case 0.75 ... 1:
//      return "It's the final stretch of the workday. "
//    default:
//      return ""
//    }
//  }
//
//  private func generateInsight(
//    codingTimeRange: Range,
//    commitsRange: Range
//  ) -> String {
//    switch (codingTimeRange, commitsRange) {
//    case (.low, .low):
//      return "Low coding time and low commits. Consider revisiting your tasks or focus to increase productivity."
//    case (.low, .average):
//      return "Low coding time but average commits. You’re efficient, but consider investing more time for sustained
//      progress."
//    case (.low, .high):
//      return "Low coding time but high commits. You’re very efficient! Make sure the quality is also top-notch."
//    case (.average, .low):
//      return "Average coding time but low commits. Review your work to see if something is slowing you down."
//    case (.average, .average):
//      return "Average coding time and average commits. You’re steady today, keep maintaining this pace."
//    case (.average, .high):
//      return "Average coding time and high commits. Great job! You're making significant progress."
//    case (.high, .low):
//      return "High coding time but low commits. It could indicate you're tackling complex problems or need to improve
//      efficiency."
//    case (.high, .average):
//      return "High coding time and average commits. You’re working hard; make sure to maintain this momentum."
//    case (.high, .high):
//      return "High coding time and high commits. You’re on fire today! Keep up the excellent work, but don’t forget to
//      take breaks."
//    }
//  }
}
