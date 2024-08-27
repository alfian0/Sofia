//
//  TodayHeartbeatView.swift
//  Sofia
//
//  Created by Alfian on 27/08/24.
//

import SwiftUI

struct TodayHeartbeatView: View {
  @ObservedObject private var viewModel: TodayHeartbeatViewModel

  init(viewModel: TodayHeartbeatViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    Group {
      switch viewModel.state {
      case .idle:
        Text("Idle").font(.title)
      case .processing:
        ProgressView()
      case let .success(data):
        HeartBeatView(
          startOfEpoch: viewModel.startOfDay(),
          heartbeats: data,
          tintColor: .red
        )
      case let .failure(error):
        VStack {
          Text("An error occurred: \(error.localizedDescription)")
            .foregroundColor(.red)
          Button("Retry") {
            viewModel.onRefresh()
          }
        }
      }
    }
    .onAppear {
      viewModel.onAppear()
    }
  }
}

#Preview {
  TodayHeartbeatView(viewModel: TodayHeartbeatViewModel())
}
