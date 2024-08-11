//
//  HistoryPage.swift
//  Sofia
//
//  Created by alfian on 10/08/24.
//

import SwiftUI
import KeychainSwift
import Alamofire

struct HistoryPage: View {
  @State private var model: AllTimeModel?
  @State private var projects: [ProjectModel.Datum] = []
  @State private var isProcessing: Bool = false
  private let decoder: JSONDecoder = {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return decoder
  }()
  
  private let divider: Double = 86_400
  
  var body: some View {
    NavigationView {
      Group {
        if isProcessing {
          ProgressView()
        } else {
          List {
            Section {
              VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading) {
                  Text(model?.data?.text ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                  Text("Total Time")
                }
                VStack(alignment: .leading) {
                  Text("\((model?.data?.dailyAverage ?? 0) / (divider/24)) hrs")
                    .font(.title)
                    .fontWeight(.bold)
                  Text("Average")
                }
                HStack {
                  VStack(alignment: .leading) {
                    Text("from")
                      .fontWeight(.bold)
                    Text(model?.data?.range?.startText ?? "")
                  }
                  
                  Spacer()
                  
                  VStack(alignment: .trailing) {
                    Text("to")
                      .fontWeight(.bold)
                    Text(model?.data?.range?.endText ?? "")
                  }
                }
              }
            }
            
            Section(header: Text("Projects")) {
              ForEach(projects) { project in
                NavigationLink {
                  Text(project.name ?? "")
                } label: {
                  Text(project.name ?? "")
                }
              }
            }
          }
          .listStyle(.plain)
        }
      }
      .navigationBarTitle("History")
      .onAppear {
        if let token = KeychainSwift().get("stringToken"),
           !token.isEmpty {
          isProcessing = true
          AF.request(
            URL(string: "https://wakatime.com/api/v1/users/current/all_time_since_today")!,
            headers: .init([.authorization(bearerToken: token)])
          ).responseDecodable(
            of: AllTimeModel.self,
            decoder: decoder
          ) { response in
            isProcessing = false
            switch response.result {
            case .success(let data):
              model = data
            case .failure(let error):
              print(error)
            }
          }
          
          AF.request(
            URL(string: "https://wakatime.com/api/v1/users/current/projects")!,
            headers: .init([.authorization(bearerToken: token)])
          ).responseDecodable(
            of: ProjectModel.self,
            decoder: decoder
          ) { response in
            isProcessing = false
            switch response.result {
            case .success(let data):
              projects = data.data ?? []
            case .failure(let error):
              print(error)
            }
          }
        }
      }
    }
  }
}

struct HistoryPage_Previews: PreviewProvider {
    static var previews: some View {
        HistoryPage()
    }
}
