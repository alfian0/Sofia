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
  @State var isProcessing: Bool = false
  @State var durations: [DurationModel.Datum] = []
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
      if isProcessing {
        ProgressView()
      } else {
        if let error = error {
          VStack {
            Text("👻")
              .font(.system(size: 100))
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
          List {
            Section {
              let lowThresholdCoding = 2.0
              let highThresholdCoding = 6.0
              let lowThresholdCommits = 5
              let highThresholdCommits = 12
              
              let now = Date()
              let startOfWorkday = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: now)!
              let endOfWorkday = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: now)!
              
              let insight = generateDailyComparisonInsight(
                  codingTime: seconds / (divider / 24),
                  commits: commits.count,
                  lowThresholdCoding: lowThresholdCoding,
                  highThresholdCoding: highThresholdCoding,
                  lowThresholdCommits: lowThresholdCommits,
                  highThresholdCommits: highThresholdCommits,
                  startOfWorkday: startOfWorkday,
                  endOfWorkday: endOfWorkday
              )
              
              Text(insight).font(.title)
            }
            
            Section(
              header: HStack {
                Text("❤️")
                Text("Heart Beat")
                Text("(\(durations.count))")
              },
              footer: Text("A single commit from a WakaTime project showing the time spent coding on the commit.")
                .font(.caption)
                .foregroundColor(Color(UIColor.systemGray))
            ) {
              GeometryReader { proxy in
                let widthPerSecond = (proxy.size.width)/divider
                ForEach(durations) { duration in
                  let time = duration.time ?? 0
                  let duration = duration.duration ?? 0
                  // Get the start of the day (12:00 AM) for the first epoch
                  let firstEpochDate = Date(timeIntervalSince1970: time)
                  let calendar = Calendar.current
                  let startOfDay = calendar.startOfDay(for: firstEpochDate)
                  let startOfDayEpoch = startOfDay.timeIntervalSince1970
                  
                  // Calculate the difference between 12:00 AM and the first epoch time
                  let timeFromStartOfDay = time - startOfDayEpoch
                  
                  Color.red
                    .frame(width: widthPerSecond*duration)
                    .position(x: widthPerSecond*timeFromStartOfDay, y: 22)
                }
              }
              .frame(height: 44)
              let times = ["", "3am", "6am", "9am", "12pm", "3pm", "6pm", "9pm"]
              HStack {
                ForEach(times, id:\.self) { time in
                  Text(time)
                    .font(.caption)
                    .foregroundColor(Color(UIColor.systemGray))
                  Spacer()
                }
              }
            }
            
            if commits.isEmpty {
              NoDataView()
            } else {
              Section(header: Text("Commits (\(commits.count))")) {
                GeometryReader { proxy in
                  let space = getTimeRanges(from: commits.reversed().map({ ($0.commit?.committer?.date?.toDate()?.timeIntervalSince1970 ?? 0) }))
                  let widthPerSecond = (proxy.size.width)/divider
                  HStack(spacing: 0) {
                    ForEach(space, id:\.self) { space in
                      Color.white
                        .frame(width: widthPerSecond*abs(space))
                      Color.blue
                        .frame(width: 1)
                    }
                  }
                }
                .frame(height: 44)
                let times = ["", "3am", "6am", "9am", "12pm", "3pm", "6pm", "9pm"]
                HStack {
                  ForEach(times, id:\.self) { time in
                    Text(time)
                      .font(.caption)
                      .foregroundColor(Color(UIColor.systemGray))
                    Spacer()
                  }
                }
                ForEach(commits) { commit in
                  HStack {
                    VStack(alignment: .leading) {
                      Text("Message")
                        .font(.caption)
                      Text(commit.commit?.message ?? "")
                      Text(commit.commit?.committer?.date?.toDate()?.toString() ?? "")
                        .font(.caption)
                        .foregroundColor(Color(UIColor.systemGray))
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
          }
          .listStyle(.plain)
        }
      }
    }
    .navigationTitle(project)
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      if let token = KeychainSwift().get("githubToken"),
         !token.isEmpty {
        isProcessing = true
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
                  let cleanPath = project.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
                  let url = URL(string: "https://api.github.com/repos/\(user)/\(cleanPath)/commits") else {
              isProcessing = false
              error = NSError(domain: "Sofia", code: 404)
              return
            }
            AF.request(
              url,
              parameters: [
                "since": start,
                "until": end
              ],
              headers: .init([.authorization(bearerToken: token)])
            ).responseDecodable(
              of: [CommitModel].self,
              decoder: decoder
            ) { response in
              isProcessing = false
              switch response.result {
              case .success(let data):
                self.commits = data
              case .failure:
                self.commits = []
              }
            }
          case .failure(let error):
            isProcessing = false
            self.error = error
          }
        }
        if let token = KeychainSwift().get("stringToken"),
           let date = start.toDate()?.toString(with: "YYYY-MM-dd"),
           let url = URL(string: "https://wakatime.com/api/v1/users/current/durations"),
           !token.isEmpty {
          AF.request(
            url,
            parameters: [
              "date": date,
              "project": project,
              "timeout": 15
            ],
            headers: .init([.authorization(bearerToken: token)])
          ).responseDecodable(
            of: DurationModel.self,
            decoder: decoder
          ) { response in
            switch response.result {
            case .success(let data):
              self.durations = data.data ?? []
            case .failure:
              isProcessing = false
              self.durations = []
            }
          }
        }
      } else {
        isProcessing = false
        error = NSError(domain: "Sofia", code: 403)
      }
    }
  }
}

struct ProjectPage_Previews: PreviewProvider {
  static var previews: some View {
    ProjectPage(
      project: "Sofia",
      seconds: 0.5,
      start: "2024-08-09T14:21:22Z",
      end: "2024-08-010T14:21:22Z"
    )
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
func generateDailyComparisonInsight(codingTime: Double, commits: Int, lowThresholdCoding: Double, highThresholdCoding: Double, lowThresholdCommits: Int, highThresholdCommits: Int, startOfWorkday: Date, endOfWorkday: Date) -> String {
    
    // Calculate the current time and workday progress
    let now = Date()
    let totalWorkdayDuration = endOfWorkday.timeIntervalSince(startOfWorkday)
    let elapsedWorkdayDuration = now.timeIntervalSince(startOfWorkday)
    let workdayProgress = elapsedWorkdayDuration / totalWorkdayDuration
    
    // Adjust thresholds based on workday progress
    let adjustedLowThresholdCoding = lowThresholdCoding * workdayProgress
    let adjustedHighThresholdCoding = highThresholdCoding * workdayProgress
    let adjustedLowThresholdCommits = Double(lowThresholdCommits) * workdayProgress
    let adjustedHighThresholdCommits = Double(highThresholdCommits) * workdayProgress
    
    // Determine coding time and commits range
    let codingTimeRange = determineRange(for: codingTime, lowThreshold: adjustedLowThresholdCoding, highThreshold: adjustedHighThresholdCoding)
    let commitsRange = determineRange(for: Double(commits), lowThreshold: adjustedLowThresholdCommits, highThreshold: adjustedHighThresholdCommits)
    
    // Define messages for each quarter of the day
    var timeSpecificMessage = ""
    
    switch workdayProgress {
    case 0..<0.25:
        timeSpecificMessage = "It's early in the day. "
        
    case 0.25..<0.75:
        timeSpecificMessage = "You're in the middle of your workday. "
        
    case 0.75...1:
        timeSpecificMessage = "It's the final stretch of the workday. "
        
    default:
        timeSpecificMessage = ""
    }
    
    // Generate the insight based on coding time and commits
    let insight: String
    
    switch (codingTimeRange, commitsRange) {
    case (.low, .low):
        insight = "Low coding time and low commits. Consider revisiting your tasks or focus to increase productivity."
        
    case (.low, .average):
        insight = "Low coding time but average commits. You’re efficient, but consider investing more time for sustained progress."
        
    case (.low, .high):
        insight = "Low coding time but high commits. You’re very efficient! Make sure the quality is also top-notch."
        
    case (.average, .low):
        insight = "Average coding time but low commits. Review your work to see if something is slowing you down."
        
    case (.average, .average):
        insight = "Average coding time and average commits. You’re steady today, keep maintaining this pace."
        
    case (.average, .high):
        insight = "Average coding time and high commits. Great job! You're making significant progress."
        
    case (.high, .low):
        insight = "High coding time but low commits. It could indicate you're tackling complex problems or need to improve efficiency."
        
    case (.high, .average):
        insight = "High coding time and average commits. You’re working hard; make sure to maintain this momentum."
        
    case (.high, .high):
        insight = "High coding time and high commits. You’re on fire today! Keep up the excellent work, but don’t forget to take breaks."
    }
    
    // Combine the time-specific message with the general insight
    return timeSpecificMessage + insight
}

func getTimeRanges(from epochs: [Double]) -> [Double] {
    guard epochs.count > 1 else {
        return []
    }
    
    var timeRanges: [Double] = []
    
    // Get the start of the day (12:00 AM) for the first epoch
    let firstEpochDate = Date(timeIntervalSince1970: epochs[0])
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: firstEpochDate)
    let startOfDayEpoch = startOfDay.timeIntervalSince1970
    
    // Calculate the difference between 12:00 AM and the first epoch time
    let timeFromStartOfDay = epochs[0] - startOfDayEpoch
    timeRanges.append(timeFromStartOfDay)
    
    // Calculate the differences between consecutive epoch times
    for i in 1..<epochs.count {
        let timeDifference = epochs[i] - epochs[i - 1]
        timeRanges.append(timeDifference)
    }
    
    return timeRanges
}
