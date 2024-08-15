//
//  ProjectView.swift
//  Sofia
//
//  Created by alfian on 15/08/24.
//

import SwiftUI

struct ProjectView: View {
  @StateObject private var viewModel = ProjectViewModel()
  @Binding var selectedProject: ProjectModel.Datum?

  var body: some View {
    Group {
      switch viewModel.state {
      case .idle:
        Text("Idle").font(.title)
      case .processing:
        ProgressView()
      case let .success(data):
        if let projects = data.data {
          Section(header: Text("Projects")) {
            ForEach(projects) { project in
              Button {
                selectedProject = project
              } label: {
                Text(project.name ?? "")
              }
            }
          }
        } else {
          EmptyView()
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
