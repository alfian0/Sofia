//
//  CommitPage.swift
//  Sofia
//
//  Created by alfian on 12/08/24.
//

import Alamofire
import KeychainSwift
import SwiftUI

struct CommitPage: View {
  @ObservedObject private var viewModel: CommitPageViewModel

  init(viewModel: CommitPageViewModel) {
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
        List {
          Section(header: Text("Files")) {
            ForEach(Array(zip(data.indices, data)), id: \.0) { file in
              HStack {
                Text(file.1.filename)
                  .font(.caption)
                Spacer()
                HStack(spacing: 4) {
                  Text("\(file.1.additions)")
                    .foregroundColor(.green)
                    .font(.caption)
                    .fontWeight(.bold)
                  Text("|")
                    .font(.caption)
                  Text("\(file.1.deletions)")
                    .foregroundColor(.red)
                    .font(.caption)
                    .fontWeight(.bold)
                }
              }
            }
          }
        }
        .listStyle(.plain)
        .navigationBarTitle(viewModel.getTitle())

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
      viewModel.onRefresh()
    }
  }
}

struct CommitPage_Previews: PreviewProvider {
  static var previews: some View {
    let viewModel = CommitPageViewModel(
      owner: "alfian0",
      repo: "Sofia",
      ref: "88688c3faf3da127823a4bd5fb006704bb7b8984"
    )
    CommitPage(viewModel: viewModel)
  }
}
