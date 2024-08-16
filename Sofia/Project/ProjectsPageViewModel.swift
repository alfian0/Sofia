//
//  ProjectsPageViewModel.swift
//  Sofia
//
//  Created by alfian on 16/08/24.
//

import Alamofire
import Foundation
import KeychainSwift

@MainActor
class ProjectsPageViewModel: ObservableObject {
  @Published var state: ProjectsPageState = .idle
  @Published var count: Int = 0
  let viewModel: CommitsViewModel

  private let projectName: String
  private let start: String
  private let end: String

  enum ProjectsPageState {
    case processing
    case success([DurationModel.Datum])
    case failure(Error)
    case idle
  }

  private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  init(projectName: String, start: String, end: String) {
    self.projectName = projectName
    self.start = start
    self.end = end
    viewModel = CommitsViewModel(projectName: projectName, start: start, end: end)
    viewModel.completionHandler = { [weak self] count in
      guard let self = self else { return }
      self.count = count
    }
  }

  func onAppear() {
    onRefresh()
  }

  func onRefresh() {
    if let token = KeychainSwift().get("githubToken"),
       !token.isEmpty {
      state = .processing

      if let token = KeychainSwift().get("stringToken"),
         let date = start.toDate()?.toString(with: "YYYY-MM-dd"),
         let url = URL(string: "https://wakatime.com/api/v1/users/current/durations"),
         let projectName = projectName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
         !token.isEmpty {
        AF.request(
          url,
          parameters: [
            "date": date,
            "project": projectName,
            "timeout": 15
          ],
          headers: .init([.authorization(bearerToken: token)])
        ).responseDecodable(
          of: DurationModel.self,
          decoder: decoder
        ) { [weak self] response in
          guard let self = self else { return }
          switch response.result {
          case let .success(data):
            self.state = .success(data.data ?? [])
          case let .failure(error):
            self.state = .failure(error)
          }
        }
      }
    } else {
      state = .failure(NSError(domain: "Sofia", code: 403))
    }
  }

  // Enum to represent ranges
  enum Range {
    case low
    case average
    case high
  }

  // Function to determine the range for coding time or commits
  func determineRange(for value: Double, lowThreshold: Double, highThreshold: Double) -> Range {
    if value < lowThreshold {
      return .low
    } else if value > highThreshold {
      return .high
    } else {
      return .average
    }
  }

  func generateDailyComparisonInsight(
    codingTime: Double,
    commits: Int
  ) -> String {
    let lowThresholdCoding = 2.0
    let highThresholdCoding = 6.0
    let lowThresholdCommits = 5
    let highThresholdCommits = 12

    let now = start.toDate() ?? Date()
    let startOfWorkday = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: now)!
    let endOfWorkday = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: now)!

    let workdayProgress = calculateWorkdayProgress(
      startOfWorkday: startOfWorkday,
      endOfWorkday: endOfWorkday
    )

    let codingTimeRange = determineRange(
      for: codingTime,
      lowThreshold: lowThresholdCoding * workdayProgress,
      highThreshold: highThresholdCoding * workdayProgress
    )

    let commitsRange = determineRange(
      for: Double(commits),
      lowThreshold: Double(lowThresholdCommits) * workdayProgress,
      highThreshold: Double(highThresholdCommits) * workdayProgress
    )

    let timeSpecificMessage = generateTimeSpecificMessage(workdayProgress: workdayProgress)
    let insight = generateInsight(codingTimeRange: codingTimeRange, commitsRange: commitsRange)

    return timeSpecificMessage + insight
  }

  private func calculateWorkdayProgress(
    startOfWorkday: Date,
    endOfWorkday: Date
  ) -> Double {
    let now = Calendar.current.isDateInToday(startOfWorkday) ? Date() : Calendar.current.startOfDay(for: startOfWorkday)
    let totalWorkdayDuration = endOfWorkday.timeIntervalSince(startOfWorkday)
    let elapsedWorkdayDuration = abs(now.timeIntervalSince(startOfWorkday))
    return elapsedWorkdayDuration / totalWorkdayDuration
  }

  private func generateTimeSpecificMessage(workdayProgress: Double) -> String {
    switch workdayProgress {
    case 0 ..< 0.25:
      return "It's early in the day. "
    case 0.25 ..< 0.75:
      return "You're in the middle of your workday. "
    case 0.75 ... 1:
      return "It's the final stretch of the workday. "
    default:
      return ""
    }
  }

  private func generateInsight(
    codingTimeRange: Range,
    commitsRange: Range
  ) -> String {
    switch (codingTimeRange, commitsRange) {
    case (.low, .low):
      return "Low coding time and low commits. Consider revisiting your tasks or focus to increase productivity."
    case (.low, .average):
      return "Low coding time but average commits. You’re efficient, but consider investing more time for sustained progress."
    case (.low, .high):
      return "Low coding time but high commits. You’re very efficient! Make sure the quality is also top-notch."
    case (.average, .low):
      return "Average coding time but low commits. Review your work to see if something is slowing you down."
    case (.average, .average):
      return "Average coding time and average commits. You’re steady today, keep maintaining this pace."
    case (.average, .high):
      return "Average coding time and high commits. Great job! You're making significant progress."
    case (.high, .low):
      return "High coding time but low commits. It could indicate you're tackling complex problems or need to improve efficiency."
    case (.high, .average):
      return "High coding time and average commits. You’re working hard; make sure to maintain this momentum."
    case (.high, .high):
      return "High coding time and high commits. You’re on fire today! Keep up the excellent work, but don’t forget to take breaks."
    }
  }
}
