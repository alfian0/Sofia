//
//  LogPageViewModel.swift
//  Sofia
//
//  Created by alfian on 13/08/24.
//

import SwiftUI
import Alamofire
import KeychainSwift

enum LogPageViewState {
    case processing
    case success([LogModel.Datum])
    case failure(Error)
    case idle
}

class LogPageViewModel: ObservableObject {
    @Published var viewState: LogPageViewState = .idle
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func loadLogs() {
        guard let token = KeychainSwift().get("stringToken"), !token.isEmpty else {
            self.viewState = .failure(NSError(domain: "Token not found", code: -1, userInfo: nil))
            return
        }
        
        self.viewState = .processing
        AF.request(
            URL(string: "https://wakatime.com/api/v1/users/current/user_agents")!,
            headers: .init([.authorization(bearerToken: token)])
        ).responseDecodable(
            of: LogModel.self,
            decoder: decoder
        ) { response in
            switch response.result {
            case .success(let data):
                self.viewState = .success(data.data ?? [])
            case .failure(let error):
                self.viewState = .failure(error)
            }
        }
    }
}
