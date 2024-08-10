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
  let seconds: Double
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
      } else if !commits.isEmpty {
        List {
          Section {
            let lowThresholdCoding = 2.0
            let highThresholdCoding = 6.0
            let lowThresholdCommits = 5
            let highThresholdCommits = 12
            
            let insight = generateDailyComparisonInsight(
                codingTime: seconds / (divider/24),
                commits: commits.count,
                lowThresholdCoding: lowThresholdCoding,
                highThresholdCoding: highThresholdCoding,
                lowThresholdCommits: lowThresholdCommits,
                highThresholdCommits: highThresholdCommits
            )
            
            Text(insight).font(.title)
          }
          
          Section(header: Text("Commits")) {
            ForEach(commits) { commit in
              HStack {
                VStack(alignment: .leading) {
                  Text("Message")
                    .font(.caption)
                  Text(commit.commit?.message ?? "")
                  Text(commit.commit?.committer?.date?.toDate()?.toString() ?? "")
                    .font(.caption)
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
        seconds: 0.5,
        start: "2024-08-09T14:21:22Z",
        end: "2024-08-010T14:21:22Z")
    }
  }
}

// Enum to represent ranges
enum Range {
    case low
    case average
    case high
}

// Function to determine the range for coding time or commits
func determineRange(for value: Double, lowThreshold: Double, highThreshold: Double) -> Range {
    if value < lowThreshold {
        return .low
    } else if value > highThreshold {
        return .high
    } else {
        return .average
    }
}

// Function to generate insights based on coding time and commits
func generateDailyComparisonInsight(codingTime: Double, commits: Int, lowThresholdCoding: Double, highThresholdCoding: Double, lowThresholdCommits: Int, highThresholdCommits: Int) -> String {
    
    let codingTimeRange = determineRange(for: codingTime, lowThreshold: lowThresholdCoding, highThreshold: highThresholdCoding)
    let commitsRange = determineRange(for: Double(commits), lowThreshold: Double(lowThresholdCommits), highThreshold: Double(highThresholdCommits))
    
    switch (codingTimeRange, commitsRange) {
    case (.low, .low):
        return "Low coding time and low commits. Consider revisiting your tasks or focus to increase productivity."
        
    case (.low, .average):
        return "Low coding time but average commits. You’re efficient, but consider investing more time for sustained progress."
        
    case (.low, .high):
        return "Low coding time but high commits. You’re very efficient! Make sure the quality is also top-notch."
        
    case (.average, .low):
        return "Average coding time but low commits. Review your work to see if something is slowing you down."
        
    case (.average, .average):
        return "Average coding time and average commits. You’re steady today, keep maintaining this pace."
        
    case (.average, .high):
        return "Average coding time and high commits. Great job! You're making significant progress."
        
    case (.high, .low):
        return "High coding time but low commits. It could indicate you're tackling complex problems or need to improve efficiency."
        
    case (.high, .average):
        return "High coding time and average commits. You’re working hard; make sure to maintain this momentum."
        
    case (.high, .high):
        return "High coding time and high commits. You’re on fire today! Keep up the excellent work, but don’t forget to take breaks."
    }
}
