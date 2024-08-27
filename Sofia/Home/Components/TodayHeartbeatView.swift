//
//  TodayHeartbeatView.swift
//  Sofia
//
//  Created by Alfian on 27/08/24.
//

import SwiftUI

struct TodayHeartbeatView: View {
  var state: ViewState<[HeartBeatModel]>

  var body: some View {
    Group {
      switch state {
      case .idle:
        Text("Idle").font(.title)
      case .processing:
        ProgressView()
      case let .success(data):
        HeartBeatView(
          startOfEpoch: Date().startOfDay.timeIntervalSince1970,
          heartbeats: data,
          tintColor: .red
        )
      case let .failure(error):
        VStack {
          Text("An error occurred: \(error.localizedDescription)")
            .foregroundColor(.red)
        }
      }
    }
  }
}

#Preview {
  TodayHeartbeatView(state: .idle)
}
