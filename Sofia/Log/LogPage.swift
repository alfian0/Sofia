//
//  LogPage.swift
//  Sofia
//
//  Created by alfian on 09/08/24.
//
import SwiftUI

struct LogPage: View {
  @StateObject private var viewModel = LogPageViewModel()

  var body: some View {
    NavigationView {
      VStack {
        switch viewModel.viewState {
        case .idle:
          Text("Idle State")
        case .processing:
          ProgressView()
        case let .success(logs):
          List {
            ForEach(Array(zip(logs.indices, logs)), id: \.0) { log in
              VStack(alignment: .leading, spacing: 8) {
                HStack {
                  HStack {
                    Text(log.1.editor ?? "")
                      .fontWeight(.bold)
                    Text("-")
                    Text(log.1.os ?? "")
                  }

                  Spacer()

                  Text((log.1.createdAt ?? "").toDate()?.toString() ?? "")
                    .font(.caption)
                }
                Text(log.1.value ?? "")
                  .font(.subheadline)
              }
            }
          }
          .listStyle(.plain)
        case let .failure(error):
          Text("Error: \(error.localizedDescription)")
        }
      }
      .navigationBarTitle("User Agent")
    }
    .onAppear {
      viewModel.loadLogs()
    }
  }
}

struct LogPage_Previews: PreviewProvider {
  static var previews: some View {
    LogPage()
  }
}
