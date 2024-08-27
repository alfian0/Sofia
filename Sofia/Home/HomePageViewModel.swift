//
//  HomePageViewModel.swift
//  Sofia
//
//  Created by alfian on 13/08/24.
//

import Alamofire
import Combine
import Foundation
import KeychainSwift

struct StatusBarModelView: Equatable {
  let totalSeconds: Double
  let start: String
  let end: String
}

@MainActor
class HomePageViewModel: ObservableObject {
  @Published var state: ViewState<StatusBarModelView> = .idle
  private var cancellables: Set<AnyCancellable> = []

  var insight: String {
    guard case let .success(statusBar) = state
    else {
      return ""
    }

    let codingTime = statusBar.totalSeconds.secondsToHours
    let startOfWorkday = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    let endOfWorkday = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!

    return getTimeBasedInsight(codingTime: codingTime, startOfWorkday: startOfWorkday, endOfWorkday: endOfWorkday)
  }

  var footer: String {
    let now = Date()
    let startOfWorkday = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: now)!
    let endOfWorkday = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: now)!

    return (now >= startOfWorkday && now <= endOfWorkday) ? "" : "You're outside of your typical working hours."
  }

  func onAppear() {
    onRefresh()
  }

  func onRefresh() {
    state = .processing

    WakatimeAuthenticatedService.shared.getStatusBar()?
      .sink(result: { [weak self] result in
        guard let self = self else { return }
        switch result {
        case let .success(data):
          if let data = data.data {
            let data = StatusBarModelView(
              totalSeconds: data.grandTotal?.totalSeconds ?? 0,
              start: data.range?.start ?? "",
              end: data.range?.end ?? ""
            )
            self.state = .success(data)
          } else {
            self.state = .idle
          }
        case let .failure(error):
          self.state = .failure(error)
        }
      })
      .store(in: &cancellables)
  }

  func getTimeBasedInsight(codingTime: Double, startOfWorkday: Date, endOfWorkday: Date) -> String {
    let now = Date()
    let totalWorkdayDuration = endOfWorkday.timeIntervalSince(startOfWorkday)
    let elapsedWorkdayDuration = now.timeIntervalSince(startOfWorkday)
    let workdayProgress = elapsedWorkdayDuration / totalWorkdayDuration

    switch workdayProgress {
    case 0 ..< 0.25:
      return codingTime < 1 ?
        "🌱 You're just getting started. Take this time to plan your tasks and set clear goals for the day ahead." :
        "🎯 Great start! You're hitting the ground running. Keep up the momentum!"
    case 0.25 ..< 0.75:
      return codingTime < 3 ?
        "🐌 You're in the middle of your workday but haven’t made much progress. Review your tasks and see if you need to adjust your focus." :
        "🏃 You're on a roll today! Your focus and productivity are impressive. Keep it going!"
    case 0.75...:
      return codingTime < 3 ?
        "🧐 The day is almost over, and progress has been slow. Reflect on what might be holding you back, and consider how you can improve tomorrow." :
        "🚀 You've maintained high productivity throughout the day. Be proud of your achievements!"
    default:
      return "😌 No specific insight for this time period."
    }
  }
}
