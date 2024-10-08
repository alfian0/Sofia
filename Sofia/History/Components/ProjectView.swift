//
//  ProjectView.swift
//  Sofia
//
//  Created by alfian on 15/08/24.
//

import SwiftUI

struct ProjectView: View {
  @StateObject private var viewModel = ProjectViewModel()
  @Binding var selectedProject: ProjectModelView?

  var body: some View {
    Group {
      switch viewModel.state {
      case .idle:
        Text("Idle").font(.title)
      case .processing:
        ProgressView()
      case let .success(data):
        Section(header: Text("Projects")) {
          ForEach(data, id: \.projectName) { project in
            Button {
              selectedProject = project
            } label: {
              Text(project.projectName)
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
