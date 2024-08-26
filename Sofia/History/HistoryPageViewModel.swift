//
//  HistoryPageViewModel.swift
//  Sofia
//
//  Created by alfian on 15/08/24.
//

import Alamofire
import Combine
import Foundation
import KeychainSwift

@MainActor
class HistoryPageViewModel: ObservableObject {
  @Published var state: ViewState<AllTimeModel> = .idle
  private var cancellables: Set<AnyCancellable> = []

  func onAppear() {
    onRefresh()
  }

  func onRefresh() {
    state = .processing
    WakatimeAuthenticatedService.shared.getAllTime()?
      .sink(result: { [weak self] result in
        guard let self = self else { return }

        switch result {
        case let .success(data):
          self.state = .success(data)
        case let .failure(error):
          self.state = .failure(error)
        }
      })
      .store(in: &cancellables)
  }
}
