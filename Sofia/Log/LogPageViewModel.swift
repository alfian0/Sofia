//
//  LogPageViewModel.swift
//  Sofia
//
//  Created by alfian on 13/08/24.
//

import Alamofire
import Combine
import KeychainSwift
import SwiftUI

class LogPageViewModel: ObservableObject {
  @Published var state: ViewState<[LogModelView]> = .idle
  private var cancellables: Set<AnyCancellable> = []

  func onAppear() {
    onRefresh()
  }

  func onRefresh() {
    state = .processing

    WakatimeAuthenticatedService.shared.getLog()?
      .sink(result: { [weak self] result in
        guard let self = self else { return }
        switch result {
        case let .success(data):
          let data = data.data?.map { LogModelView(
            editor: $0.editor ?? "",
            os: $0.os ?? "",
            createdAt: $0.createdAt ?? "",
            value: $0.value ?? ""
          ) } ?? []
          self.state = .success(data)
        case let .failure(error):
          self.state = .failure(error)
        }
      })
      .store(in: &cancellables)
  }
}
