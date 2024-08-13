//
//  UserPageViewModel.swift
//  Sofia
//
//  Created by alfian on 13/08/24.
//

import SwiftUI
import Alamofire
import KeychainSwift
import OAuthSwift

enum UserPageViewState {
    case processing
    case success(UserModel.DataClass?)
    case failure(Error)
    case idle
}

class UserPageViewModel: ObservableObject {
    @Published var viewState: UserPageViewState = .idle
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    let keychain = KeychainSwift()
    private let oauthswift = OAuth2Swift(
        consumerKey: API.githubClientID,
        consumerSecret: API.githubClientSecret,
        authorizeUrl: "https://github.com/login/oauth/authorize",
        accessTokenUrl: "https://github.com/login/oauth/access_token",
        responseType: "code"
    )
    
    func loadUser() {
        guard let token = keychain.get("stringToken"), !token.isEmpty else {
            self.viewState = .failure(NSError(domain: "Token not found", code: -1, userInfo: nil))
            return
        }
        
        self.viewState = .processing
        AF.request(
            URL(string: "https://wakatime.com/api/v1/users/current")!,
            headers: .init([.authorization(bearerToken: token)])
        ).responseDecodable(
            of: UserModel.self,
            decoder: decoder
        ) { response in
            switch response.result {
            case .success(let data):
                self.viewState = .success(data.data)
            case .failure(let error):
                self.viewState = .failure(error)
            }
        }
    }
    
    func connectGithub() {
        guard !isProcessing else { return }
        isProcessing = true
        
        oauthswift.authorizeURLHandler = SafariURLHandler(
            viewController: UIApplication.shared.windows.first!.rootViewController!,
            oauthSwift: oauthswift
        )
        
        oauthswift.authorize(
            withCallbackURL: URL(string: "sofia://oauth-callback/github")!,
            scope: "user repo",
            state: "state"
        ) { result in
            self.isProcessing = false
            switch result {
            case .success(let token):
                self.keychain.set(token.credential.oauthToken, forKey: "githubToken")
                self.isGithubConnected = true
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @Published var isGithubConnected: Bool = false
    @Published var isProcessing: Bool = false
}
