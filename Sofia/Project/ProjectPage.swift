//
//  ProjectPage.swift
//  Sofia
//
//  Created by alfian on 10/08/24.
//

import Alamofire
import KeychainSwift
import SDWebImageSwiftUI
import SwiftUI

struct ProjectPage: View {
  @ObservedObject private var viewModel: ProjectsPageViewModel
  @State var commitsCount: Int = 0
  private let project: String
  private let seconds: Double
  private let start: String
  private let end: String
  private var startOfDay: Double

  init(project: String, seconds: Double, start: String, end: String) {
    self.project = project
    self.seconds = seconds
    self.start = start
    self.end = end
    startOfDay = Calendar.current.startOfDay(for: start.toDate() ?? Date()).timeIntervalSince1970
    viewModel = ProjectsPageViewModel(projectName: project, start: start)
  }

  var body: some View {
    Group {
      switch viewModel.state {
      case .idle:
        Text("Idle").font(.title)
      case .processing:
        ProgressView()
      case let .success(data):
        let durations = data
        List {
          Section {
            let insight = viewModel.generateDailyComparisonInsight(
              codingTime: seconds.secondsToHours,
              commits: commitsCount
            )

            Text(insight).font(.title)
          }

          Section(
            header: HStack {
              Text("❤️")
              Text("Heart Beat")
              Text("(\(durations.count))")
            },
            footer: Text("A single commit from a WakaTime project showing the time spent coding on the commit.")
              .font(.caption)
              .foregroundColor(Color(UIColor.systemGray))
          ) {
            let heartbeats = durations.map { HeartBeatModel(epoch: $0.time ?? 0, duration: $0.duration ?? 0) }
            HeartBeatView(
              startOfEpoch: startOfDay,
              heartbeats: heartbeats,
              tintColor: .red
            )
          }

          CommitsView(viewModel: CommitsViewModel(
            projectName: project,
            start: start,
            end: end,
            commitsCount: $commitsCount
          ))
        }
        .listStyle(.plain)
        .navigationTitle(project)
        .navigationBarTitleDisplayMode(.inline)
      case let .failure(error):
        VStack {
          Text("👻")
            .font(.system(size: 100))
          VStack {
            Text("Not Found")
              .font(.title)
            Text(error.localizedDescription)
              .multilineTextAlignment(.center)
          }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 32)
      }
    }
    .onAppear {
      viewModel.onAppear()
    }
  }
}

struct ProjectPage_Previews: PreviewProvider {
  static var previews: some View {
    ProjectPage(
      project: "Sofia",
      seconds: 0.5,
      start: "2024-08-09T14:21:22Z",
      end: "2024-08-010T14:21:22Z"
    )
  }
}
