//
//  ProjectPage.swift
//  Sofia
//
//  Created by alfian on 10/08/24.
//

import SwiftUI
import KeychainSwift
import Alamofire
import SDWebImageSwiftUI

struct ProjectPage: View {
  @State var commits: [CommitModel] = []
  @State var error: Error?
  let project: String
  let percent: Double
  let start: String
  let end: String
  
  private let divider: Double = 86_400
  
  private let decoder: JSONDecoder = {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return decoder
  }()
  
  var body: some View {
    VStack {
      if let error = error {
        VStack {
          GeometryReader { proxy in
            Image("Delivery")
              .resizable()
              .scaledToFit()
              .frame(maxWidth: proxy.size.width/2)
              .position(x: proxy.frame(in: .local).midX, y: proxy.frame(in: .local).midY)
          }
          
          VStack {
            Text("Not Found")
              .font(.title)
            Text(error.localizedDescription)
              .multilineTextAlignment(.center)
          }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 32)
      } else {
//        Text(project)
//        Text("\(percent/(divider/24)) hours")
//        Text("\(commits.count)")
        List {
          Section(header: Text("Commits")) {
            ForEach(commits) { commit in
              HStack {
                VStack(alignment: .leading) {
                  Text("Message")
                    .font(.caption)
                  Text(commit.commit?.message ?? "")
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
        .listStyle(.plain)
      }
    }
    .navigationTitle(project)
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      if let token = KeychainSwift().get("githubToken"),
         !token.isEmpty {
        AF.request(
          URL(string: "https://api.github.com/user")!,
          headers: .init([.authorization(bearerToken: token)])
        ).responseDecodable(
          of: GithubUserModel.self,
          decoder: decoder
        ) { response in
          switch response.result {
          case .success(let data):
            guard let user = data.login,
                  let url = URL(string: "https://api.github.com/repos/\(user)/\(project)/commits?since=\(start)&until=\(end)") else {
              error = NSError(domain: "Sofia", code: 404)
              return
            }
            AF.request(
              url,
              headers: .init([.authorization(bearerToken: token)])
            ).responseDecodable(
              of: [CommitModel].self,
              decoder: decoder
            ) { response in
              switch response.result {
              case .success(let data):
                self.commits = data
              case .failure(let error):
                self.error = error
              }
            }
          case .failure(let error):
            self.error = error
          }
        }
      } else {
        error = NSError(domain: "Sofia", code: 403)
      }
    }
  }
}

struct ProjectPage_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ProjectPage(
        project: "Sofia",
        percent: 0.5,
        start: "2024-08-09T14:21:22Z",
        end: "2024-08-010T14:21:22Z")
    }
  }
}
