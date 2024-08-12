//
//  SummariesPage.swift
//  Sofia
//
//  Created by alfian on 12/08/24.
//

import SwiftUI
import Alamofire
import KeychainSwift

struct SummariesPage: View {
  @State private var summaries: SummariesModel?
  @State private var isProcessing: Bool = false
  let start: String
  let end: String
  let project: String
  
  init(start: String, end: String, project: String) {
    self.start = start
    self.end = end
    self.project = project
  }
  
  private let decoder: JSONDecoder = {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return decoder
  }()
  
  var body: some View {
    List {
      Section {
        VStack(alignment: .leading, spacing: 16) {
          VStack(alignment: .leading) {
            Text(summaries?.cumulativeTotal?.text ?? "")
              .font(.title)
              .fontWeight(.bold)
            Text("Total Time")
          }
          VStack(alignment: .leading) {
            Text(summaries?.dailyAverage?.text ?? "")
              .font(.title)
              .fontWeight(.bold)
            Text("Average")
          }
          HStack {
            VStack(alignment: .leading) {
              Text("from")
                .fontWeight(.bold)
              Text(summaries?.start?.toDate()?.toString(with: "EE MMM dd YYYY") ?? "")
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
              Text("to")
                .fontWeight(.bold)
              Text(summaries?.end?.toDate()?.toString(with: "EE MMM dd YYYY") ?? "")
            }
          }
        }
      }
      
      Section(header: Text("Log Histories")) {
        let data = (summaries?.data ?? []).reversed()
        ForEach(Array(zip(data.indices, data)), id:\.0) { summarie in
          VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
              Text(summarie.1.range?.start?.toDate()?.toString(with: "EE dd MM yyyy") ?? "")
                .font(.caption)
              Spacer()
              Text(summarie.1.grandTotal?.text ?? "")
                .font(.caption)
                .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
              HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                  Text("Brances")
                    .font(.caption)
                    .fontWeight(.bold)
                  Text(summarie.1.branches?.map({ $0.name ?? "" }).joined(separator: ", ") ?? "")
                    .font(.caption)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                  Text("Laguages")
                    .font(.caption)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.trailing)
                  Text(summarie.1.languages?.map({ $0.name ?? "" }).joined(separator: ", ") ?? "")
                    .font(.caption)
                    .multilineTextAlignment(.trailing)
                }
              }
              HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                  Text("Editor")
                    .font(.caption)
                    .fontWeight(.bold)
                  Text(summarie.1.editors?.map({ $0.name ?? "" }).joined(separator: ", ") ?? "")
                    .font(.caption)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                  Text("Dependencies")
                    .font(.caption)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.trailing)
                  Text(summarie.1.dependencies?.map({ $0.name ?? "" }).joined(separator: ", ") ?? "")
                    .font(.caption)
                    .multilineTextAlignment(.trailing)
                }
              }
              HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                  Text("Machine")
                    .font(.caption)
                    .fontWeight(.bold)
                  Text(summarie.1.machines?.map({ $0.name ?? "" }).joined(separator: ", ") ?? "")
                    .font(.caption)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                  Text("Operating Systems")
                    .font(.caption)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.trailing)
                  Text(summarie.1.operatingSystems?.map({ $0.name ?? "" }).joined(separator: ", ") ?? "")
                    .font(.caption)
                    .multilineTextAlignment(.trailing)
                }
              }
              VStack(alignment: .leading, spacing: 4) {
                Text("Entities")
                  .font(.caption)
                  .fontWeight(.bold)
                Text(summarie.1.entities?.map({ $0.name?.components(separatedBy: "/").last ?? "" }).joined(separator: ", ") ?? "")
                  .font(.caption)
              }
              VStack(alignment: .leading, spacing: 4) {
                Text("Categories")
                  .font(.caption)
                  .fontWeight(.bold)
                Text(summarie.1.categories?.map({ $0.name ?? "" }).joined(separator: ", ") ?? "")
                  .font(.caption)
              }
            }
            NavigationLink {
              ProjectPage(
                project: project,
                seconds: (summarie.1.grandTotal?.totalSeconds ?? 0),
                start: summarie.1.range?.start ?? "",
                end: summarie.1.range?.end ?? ""
              )
            } label: {
              Text("See Details")
                .font(.caption)
                .foregroundColor(.blue)
            }
          }
        }
      }
    }
    .listStyle(.plain)
    .navigationTitle(project)
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      if let token = KeychainSwift().get("stringToken"),
         !token.isEmpty {
        isProcessing = true
        AF.request(
          URL(string: "https://wakatime.com/api/v1/users/current/summaries")!,
          parameters: [
            "start": start,
            "end": end,
            "project": project
          ],
          headers: .init([.authorization(bearerToken: token)])
        ).responseDecodable(
          of: SummariesModel.self,
          decoder: decoder
        ) { response in
          isProcessing = false
          switch response.result {
          case .success(let data):
            summaries = data
          case .failure(let error):
            print(error)
          }
        }
      }
    }
  }
}

struct SummariesPage_Previews: PreviewProvider {
    static var previews: some View {
      SummariesPage(start: "2024-08-03", end: "2024-08-09", project: "Sofia")
    }
}
