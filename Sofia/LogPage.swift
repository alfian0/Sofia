//
//  LogPage.swift
//  Sofia
//
//  Created by alfian on 09/08/24.
//

import SwiftUI
import Alamofire
import KeychainSwift

struct LogPage: View {
  @State var logs: [LogModel.Datum] = []
  let decoder: JSONDecoder = {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return decoder
  }()
  var body: some View {
    NavigationView {
      List {
        ForEach(Array(zip(logs.indices, logs)), id:\.0) { log in
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              HStack {
                Text(log.1.editor ?? "")
                  .fontWeight(.bold)
                Text("-")
                Text(log.1.os ?? "")
              }
              
              Spacer()
              
              Text(log.1.createdAt ?? "")
                .font(.caption)
            }
            Text(log.1.value ?? "")
              .font(.subheadline)
          }
        }
      }
      .listStyle(.plain)
      .navigationBarTitle("User Agent")
    }
    .onAppear {
      if let token = KeychainSwift().get("stringToken"),
         !token.isEmpty {
        AF.request(
          URL(string: "https://wakatime.com/api/v1/users/current/user_agents")!,
          headers: .init([.authorization(bearerToken: token)])
        ).responseDecodable(
          of: LogModel.self,
          decoder: decoder
        ) { response in
          switch response.result {
          case .success(let data):
            logs = data.data ?? []
          case .failure(let error):
            print(error)
          }
        }
      }
    }
  }
}

struct LogPage_Previews: PreviewProvider {
    static var previews: some View {
        LogPage()
    }
}
