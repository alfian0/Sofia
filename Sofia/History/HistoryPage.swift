//
//  HistoryPage.swift
//  Sofia
//
//  Created by alfian on 10/08/24.
//

import Alamofire
import KeychainSwift
import SwiftUI

struct HistoryPage: View {
  @ObservedObject private var viewModel = HistoryPageViewModel()
  @State private var selectedProject: ProjectModelView?

  var body: some View {
    NavigationView {
      Group {
        switch viewModel.state {
        case .idle:
          Text("Idle").font(.title)
        case .processing:
          ProgressView()
        case let .success(data):
          List {
            Section {
              VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading) {
                  Text(data.text)
                    .font(.title)
                    .fontWeight(.bold)
                  Text("Total Time")
                }
                VStack(alignment: .leading) {
                  Text("\((data.dailyAverage).secondsToHours) hrs")
                    .font(.title)
                    .fontWeight(.bold)
                  Text("Average")
                }
                HStack {
                  VStack(alignment: .leading) {
                    Text("from")
                      .fontWeight(.bold)
                    Text(data.startText)
                  }

                  Spacer()

                  VStack(alignment: .trailing) {
                    Text("to")
                      .fontWeight(.bold)
                    Text(data.endText)
                  }
                }
              }
            }

            ProjectView(selectedProject: $selectedProject)
          }
          .listStyle(.plain)
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
      .navigationBarTitle("History")
      .fullScreenCover(item: $selectedProject, content: { project in
        NavigationView {
          let createdAt = project.createdAt.toDate()?.toString(with: "YYYY-MM-dd")
          SummariesPage(viewModel:
            SummariesPageViewModel(
              start: project.firstHeartbeatAt.toDate()?.toString(with: "YYYY-MM-dd") ?? createdAt ?? "",
              end: project.lastHeartbeatAt.toDate()?.toString(with: "YYYY-MM-dd") ?? Date()
                .toString(with: "YYYY-MM-dd"),
              project: project.projectName
            ))
            .navigationBarItems(leading: Button(action: {
              selectedProject = nil
            }, label: {
              Image(systemName: "chevron.left")
            }))
        }
      })
      .onAppear {
        viewModel.onAppear()
      }
    }
  }
}

struct HistoryPage_Previews: PreviewProvider {
  static var previews: some View {
    HistoryPage()
  }
}
