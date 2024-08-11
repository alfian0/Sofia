//
//  HomePage.swift
//  Sofia
//
//  Created by alfian on 09/08/24.
//

import SwiftUI
import KeychainSwift
import Alamofire

struct HomePage: View {
  @State var statusBar: StatusBarModel.DataClass?
  @State var isProcessing: Bool = false
  let decoder: JSONDecoder = {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return decoder
  }()
  
  private let divider: Double = 3_600
  
  var body: some View {
    let now = Date()
    let startOfWorkday = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: now)!
    let endOfWorkday = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: now)!
    let codingTime = (statusBar?.grandTotal?.totalSeconds ?? 0)/divider
    let insight = getTimeBasedInsight(codingTime: codingTime, startOfWorkday: startOfWorkday, endOfWorkday: endOfWorkday)
    let footer = (now >= startOfWorkday && now <= endOfWorkday) ? "" : "You're outside of your typical working hours."
    
    NavigationView {
      Group {
        if isProcessing {
          ProgressView()
        } else {
          List {
            VStack(alignment: .leading) {
              Text(insight).font(.title)
              if !footer.isEmpty {
                Text(footer).font(.caption).foregroundColor(Color(UIColor.systemGray))
              }
            }
            if let statusBar = statusBar,
               let totalSeconds = statusBar.grandTotal?.totalSeconds,
               totalSeconds > 0 {
              StatusBarView(statusBar: statusBar)
            } else {
              NoDataView()
            }
          }
          .listStyle(.plain)
        }
      }
      .navigationTitle("Today")
      .navigationBarItems(
        trailing:
          Button {
            guard !isProcessing else { return }
            onRefresh()
          } label: {
            if isProcessing {
              ProgressView()
            } else {
              Image(systemName: "arrow.clockwise")
            }
          }
        )
    }
    .onAppear {
      onRefresh()
    }
  }
  
  func onRefresh() {
    if let token = KeychainSwift().get("stringToken"),
       !token.isEmpty {
      isProcessing = true
      AF.request(
        URL(string: "https://wakatime.com/api/v1/users/current/status_bar/today")!,
        headers: .init([.authorization(bearerToken: token)])
      ).responseDecodable(
        of: StatusBarModel.self,
        decoder: decoder
      ) { response in
        isProcessing = false
        switch response.result {
        case .success(let data):
          statusBar = data.data
        case .failure(let error):
          print(error)
        }
      }
    }
  }

  func getTimeBasedInsight(codingTime: Double, startOfWorkday: Date, endOfWorkday: Date) -> String {
      let now = Date()
      
      // Calculate total and elapsed workday duration
      let totalWorkdayDuration = endOfWorkday.timeIntervalSince(startOfWorkday)
      let elapsedWorkdayDuration = now.timeIntervalSince(startOfWorkday)
      
      // Determine the progress of the workday
      let workdayProgress = elapsedWorkdayDuration / totalWorkdayDuration
      
      // Insight based on the progress of the day
      switch workdayProgress {
      case 0..<0.25:
          // First quarter of the workday
          if codingTime < 1 {
              return "🌱 You're just getting started. Take this time to plan your tasks and set clear goals for the day ahead."
          } else if codingTime >= 1 {
              return "🎯 Great start! You're hitting the ground running. Keep up the momentum!"
          }
          
      case 0.25..<0.75:
          // Middle half of the workday
          if codingTime < 3 {
              return "🐌 You're in the middle of your workday but haven’t made much progress. Review your tasks and see if you need to adjust your focus."
          } else if codingTime >= 3 {
              return "🏃 You're on a roll today! Your focus and productivity are impressive. Keep it going!"
          }
          
      case 0.75...:
          // Final quarter of the workday
          if codingTime < 3 {
              return "🧐 The day is almost over, and progress has been slow. Reflect on what might be holding you back, and consider how you can improve tomorrow."
          } else if codingTime >= 3 {
              return "🚀 You've maintained high productivity throughout the day. Be proud of your achievements!"
          }
          
      default:
          return "😌 No specific insight for this time period."
      }
      
      return "👍 You're doing fine. Keep up the steady work!"
  }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
