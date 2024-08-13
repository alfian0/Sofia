//
//  HomePageViewModel.swift
//  Sofia
//
//  Created by alfian on 13/08/24.
//

import Foundation
import KeychainSwift
import Alamofire

enum HomePageState {
    case processing
    case success(StatusBarModel.DataClass)
    case failure(Error)
    case idle
}

@MainActor
class HomePageViewModel: ObservableObject {
    @Published var state: HomePageState = .idle
    private let divider: Double = 3_600

    var insight: String {
        guard case .success(let statusBar) = state else {
            return ""
        }

        let codingTime = (statusBar.grandTotal?.totalSeconds ?? 0) / divider
        let startOfWorkday = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
        let endOfWorkday = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!
        
        return getTimeBasedInsight(codingTime: codingTime, startOfWorkday: startOfWorkday, endOfWorkday: endOfWorkday)
    }

    var footer: String {
        let now = Date()
        let startOfWorkday = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: now)!
        let endOfWorkday = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: now)!
        
        return (now >= startOfWorkday && now <= endOfWorkday) ? "" : "You're outside of your typical working hours."
    }
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    func onAppear() {
        onRefresh()
    }

    func onRefresh() {
        if let token = KeychainSwift().get("stringToken"), !token.isEmpty {
            state = .processing
            AF.request(
                URL(string: "https://wakatime.com/api/v1/users/current/status_bar/today")!,
                headers: .init([.authorization(bearerToken: token)])
            ).responseDecodable(
                of: StatusBarModel.self,
                decoder: decoder
            ) { [weak self] response in
                guard let self = self else { return }
                
                switch response.result {
                case .success(let data):
                  if let data = data.data {
                    self.state = .success(data)
                  } else {
                    self.state = .idle
                  }
                case .failure(let error):
                    self.state = .failure(error)
                }
            }
        }
    }

    func getTimeBasedInsight(codingTime: Double, startOfWorkday: Date, endOfWorkday: Date) -> String {
        let now = Date()
        let totalWorkdayDuration = endOfWorkday.timeIntervalSince(startOfWorkday)
        let elapsedWorkdayDuration = now.timeIntervalSince(startOfWorkday)
        let workdayProgress = elapsedWorkdayDuration / totalWorkdayDuration
        
        switch workdayProgress {
        case 0..<0.25:
            return codingTime < 1 ? "🌱 You're just getting started. Take this time to plan your tasks and set clear goals for the day ahead." :
                                     "🎯 Great start! You're hitting the ground running. Keep up the momentum!"
        case 0.25..<0.75:
            return codingTime < 3 ? "🐌 You're in the middle of your workday but haven’t made much progress. Review your tasks and see if you need to adjust your focus." :
                                     "🏃 You're on a roll today! Your focus and productivity are impressive. Keep it going!"
        case 0.75...:
            return codingTime < 3 ? "🧐 The day is almost over, and progress has been slow. Reflect on what might be holding you back, and consider how you can improve tomorrow." :
                                     "🚀 You've maintained high productivity throughout the day. Be proud of your achievements!"
        default:
            return "😌 No specific insight for this time period."
        }
    }
}
