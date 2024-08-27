//
//  SummariesPageViewModel.swift
//  Sofia
//
//  Created by Alfian on 24/08/24.
//

import Combine
import Foundation

@MainActor
class SummariesPageViewModel: ObservableObject {
  @Published var state: ViewState<SummariesModelView> = .idle
  private var cancellables: Set<AnyCancellable> = []

  let start: String
  let end: String
  let project: String

  init(start: String, end: String, project: String) {
    self.start = start
    self.end = end
    self.project = project
  }

  func onAppear() {
    onRefresh()
  }

  func onRefresh() {
    state = .processing
    WakatimeAuthenticatedService
      .shared
      .getSummaries(start: start, end: end, project: project)?
      .sink(result: { [weak self] result in
        guard let self = self else { return }

        switch result {
        case let .success(data):
          self.state = .success(SummariesModelView())
        case let .failure(error):
          self.state = .failure(error)
        }
      })
      .store(in: &cancellables)
  }
}
