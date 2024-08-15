//
//  UserPageViewModel.swift
//  Sofia
//
//  Created by alfian on 13/08/24.
//

import Alamofire
import KeychainSwift
import OAuthSwift
import SwiftUI

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
    guard let token = keychain.get("stringToken"), !token.isEmpty
    else {
      viewState = .failure(NSError(domain: "Token not found", code: -1, userInfo: nil))
      return
    }

    viewState = .processing
    AF.request(
      URL(string: "https://wakatime.com/api/v1/users/current")!,
      headers: .init([.authorization(bearerToken: token)])
    ).responseDecodable(
      of: UserModel.self,
      decoder: decoder
    ) { response in
      switch response.result {
      case let .success(data):
        self.viewState = .success(data.data)
      case let .failure(error):
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
      case let .success(token):
        self.keychain.set(token.credential.oauthToken, forKey: "githubToken")
        self.isGithubConnected = true
      case let .failure(error):
        print(error.localizedDescription)
      }
    }
  }

  @Published var isGithubConnected: Bool = false
  @Published var isProcessing: Bool = false
}
