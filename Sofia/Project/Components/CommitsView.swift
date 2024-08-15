//
//  CommitsView.swift
//  Sofia
//
//  Created by alfian on 15/08/24.
//

import SDWebImageSwiftUI
import SwiftUI

struct CommitsView: View {
  @ObservedObject private var viewModel: CommitsViewModel

  init(viewModel: CommitsViewModel) {
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
        let commits = data
        if commits.isEmpty {
          NoDataView()
        } else {
          Section(header: Text("Commits (\(commits.count))")) {
            let heartbeats = commits.reversed()
              .map { HeartBeatModel(
                epoch: $0.commit?.committer?.date?.toDate()?.timeIntervalSince1970 ?? 0,
                duration: 1
              ) }
            HeartBeatView(
              startOfEpoch: viewModel.getStartOfDay(),
              heartbeats: heartbeats,
              tintColor: .blue
            )

            ForEach(commits) { commit in
              NavigationLink {
                CommitPage(
                  owner: commit.author?.login ?? "",
                  repo: viewModel.getProjectName(),
                  ref: commit.sha ?? ""
                )
              } label: {
                HStack {
                  VStack(alignment: .leading) {
                    Text("Message")
                      .font(.caption)
                    Text(commit.commit?.message ?? "")
                    Text(commit.commit?.committer?.date?.toDate()?.toString() ?? "")
                      .font(.caption)
                      .foregroundColor(Color(UIColor.systemGray))
                  }

                  Spacer()

                  WebImage(url: URL(string: commit.committer?.avatarUrl ?? "")) { image in
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
