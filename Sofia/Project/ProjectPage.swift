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
    startOfDay = start.toDate()?
      .timeIntervalSince1970 ?? 0
    viewModel = ProjectsPageViewModel(projectName: project, start: start, end: end)
  }

  var body: some View {
    Group {
      switch viewModel.state {
      case .idle:
        Text("Idle").font(.title)

      case .processing:
        ProgressView()

      case let .success(data):
        let durations = data.durations
        let commits = data.commits
        let heartbeats = durations.map { HeartBeatModel(epoch: $0.timestamp, duration: $0.duration) }
        let heartbeats2 = commits.map { HeartBeatModel(epoch: $0.timestamp, duration: 1) }

        List {
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
            HeartBeatView(
              startOfEpoch: startOfDay,
              heartbeats: heartbeats,
              tintColor: .red
            )
          }

          Section(header: Text("Commits (\(commits.count))")) {
            HeartBeatView(
              startOfEpoch: startOfDay,
              heartbeats: heartbeats2,
              tintColor: .blue
            )

            ForEach(commits, id: \.timestamp) { commit in
              NavigationLink {
                let viewModel = CommitPageViewModel(
                  owner: "",
                  repo: project,
                  ref: ""
                )
                CommitPage(viewModel: viewModel)
              } label: {
                HStack {
                  VStack(alignment: .leading, spacing: 8) {
                    HStack {
                      Text("Message")
                        .font(.caption)
                      Text(Date(timeIntervalSince1970: commit.timestamp).toString(with: "dd-mm-yyyy"))
                        .font(.caption)
                        .foregroundColor(Color(UIColor.systemGray))
                    }
                    Text(commit.message)
                    HStack {
                      ProgressView(value: commit.duration.secondsToMinutes / commit.totalDuration.secondsToMinutes)
                      Text(
                        "\(String(format: "%.2f", commit.duration.secondsToHours))/\(String(format: "%.2f", commit.totalDuration.secondsToHours))"
                      )
                      .font(.caption)
                    }
                    HStack {
                      Text(Date(timeIntervalSince1970: commit.sessionStarted).toString(with: "HH:mm:ss"))
                        .font(.caption)
                      Text("-")
                        .font(.caption)
                      Text(Date(timeIntervalSince1970: commit.timestamp).toString(with: "HH:mm:ss"))
                        .font(.caption)
                    }
                  }

                  Spacer()

                  WebImage(url: URL(string: commit.avatarURL)) { image in
                    image.resizable()
                  } placeholder: {
                    Rectangle().foregroundColor(Color(UIColor.systemGray6))
                  }
                  .indicator(.activity)
                  .transition(.fade(duration: 0.5))
                  .scaledToFit()
                  .clipShape(Circle())
                  .frame(width: 40, height: 40, alignment: .center)
                }
              }
            }
          }
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
