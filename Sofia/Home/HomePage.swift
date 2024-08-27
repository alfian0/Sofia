//
//  HomePage.swift
//  Sofia
//
//  Created by alfian on 09/08/24.
//

import SwiftUI

struct HomePage: View {
  @ObservedObject private var viewModel = HomePageViewModel()
  @State private var selectedProject: StatusBarModel.Category?

  var body: some View {
    NavigationView {
      content
        .navigationTitle("Today")
        .navigationBarItems(
          trailing: Button {
            viewModel.onRefresh()
          } label: {
            if case .processing = viewModel.state {
              ProgressView()
            } else {
              Image(systemName: "arrow.clockwise")
            }
          }
        )
    }
    .onAppear {
      viewModel.onAppear()
    }
  }

  @ViewBuilder
  private var content: some View {
    switch viewModel.state {
    case .idle:
      Text("Idle").font(.title)

    case .processing:
      ProgressView()

    case let .success(statusBar):
      List {
        VStack(alignment: .leading) {
          Text(viewModel.insight).font(.title)
          if !viewModel.footer.isEmpty {
            Text(viewModel.footer)
              .font(.caption)
              .foregroundColor(Color(UIColor.systemGray))
          }
        }

        TodayHeartbeatView(state: viewModel.state2)
      }
      .listStyle(.plain)
      .fullScreenCover(item: $selectedProject, content: { project in
        NavigationView {
          ProjectPage(
            project: project.name ?? "",
            seconds: project.totalSeconds ?? 0,
            start: statusBar.start,
            end: statusBar.end
          )
          .navigationBarItems(leading: Button(action: {
            selectedProject = nil
          }, label: {
            Image(systemName: "chevron.left")
          }))
        }
      })

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
}

struct HomePage_Previews: PreviewProvider {
  static var previews: some View {
    HomePage()
  }
}
