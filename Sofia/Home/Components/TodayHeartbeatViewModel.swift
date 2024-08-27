//
//  TodayHeartbeatViewModel.swift
//  Sofia
//
//  Created by Alfian on 27/08/24.
//

import Combine
import Foundation

@MainActor
final class TodayHeartbeatViewModel: ObservableObject {
  @Published var state: ViewState<[HeartBeatModel]> = .idle
  private var cancellables: Set<AnyCancellable> = []

  func onAppear() {
    onRefresh()
  }

  func onRefresh() {
    state = .processing
    let date = Date().toString(with: "yyyy-MM-dd")
    WakatimeAuthenticatedService.shared.getDuration(date: date)?
      .sink(result: { [weak self] result in
        guard let self = self else { return }
        switch result {
        case let .success(data):
          let heartbeat = data.data?.map { HeartBeatModel(epoch: $0.time ?? 0, duration: $0.duration ?? 0) } ?? []
          self.state = .success(heartbeat)
        case let .failure(error):
          self.state = .failure(error)
        }
      })
      .store(in: &cancellables)
  }

  func startOfDay() -> Double {
    return Date().startOfDay.timeIntervalSince1970
  }
}
