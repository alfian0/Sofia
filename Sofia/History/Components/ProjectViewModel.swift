//
//  ProjectViewModel.swift
//  Sofia
//
//  Created by alfian on 15/08/24.
//

import Combine
import Foundation

@MainActor
class ProjectViewModel: ObservableObject {
  @Published var state: ViewState<[ProjectModelView]> = .idle
  private var cancellables: Set<AnyCancellable> = []

  func onAppear() {
    onRefresh()
  }

  func onRefresh() {
    WakatimeAuthenticatedService.shared.getProjects()?
      .sink(result: { [weak self] result in
        guard let self = self else { return }
        switch result {
        case let .success(data):
          let data = data.data?.map { ProjectModelView(
            projectName: $0.name ?? "",
            createdAt: $0.createdAt ?? "",
            firstHeartbeatAt: $0.firstHeartbeatAt ?? "",
            lastHeartbeatAt: $0.lastHeartbeatAt ?? ""
          ) } ?? []
          self.state = .success(data)
        case let .failure(error):
          self.state = .failure(error)
        }
      })
      .store(in: &cancellables)
  }
}
