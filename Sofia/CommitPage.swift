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
  @State var commit: CommitModel?
  @State var isProcessing: Bool = false

  let owner: String
  let repo: String
  let ref: String

  private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  var body: some View {
    let files = commit?.files ?? []
    List {
      Section(header: Text("Files")) {
        ForEach(Array(zip(files.indices, files)), id: \.0) { file in
          HStack {
            Text(file.1.filename ?? "")
              .font(.caption)
            Spacer()
            HStack(spacing: 4) {
              Text("\(file.1.additions ?? 0)")
                .foregroundColor(.green)
                .font(.caption)
                .fontWeight(.bold)
              Text("|")
                .font(.caption)
              Text("\(file.1.deletions ?? 0)")
                .foregroundColor(.red)
                .font(.caption)
                .fontWeight(.bold)
            }
          }
        }
      }
    }
    .listStyle(.plain)
    .navigationBarTitle(repo)
    .onAppear {
      if let token = KeychainSwift().get("githubToken"),
         !token.isEmpty
      {
        isProcessing = true

        AF.request(
          URL(string: "https://api.github.com/repos/\(owner)/\(repo)/commits/\(ref)")!,
          headers: .init([.authorization(bearerToken: token)])
        ).responseDecodable(
          of: CommitModel.self,
          decoder: decoder
        ) { response in
          isProcessing = false
          switch response.result {
          case let .success(data):
            self.commit = data
          case let .failure(error):
            print(error.localizedDescription)
          }
        }
      }
    }
  }
}

struct CommitPage_Previews: PreviewProvider {
  static var previews: some View {
    CommitPage(owner: "alfian0", repo: "Sofia", ref: "88688c3faf3da127823a4bd5fb006704bb7b8984")
  }
}
