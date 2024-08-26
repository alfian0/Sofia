//
//  UserPageViewModel.swift
//  Sofia
//
//  Created by alfian on 13/08/24.
//

import Alamofire
import Combine
import KeychainSwift
import OAuthSwift
import SwiftUI

class UserPageViewModel: ObservableObject {
  @Published var state: ViewState<UserModel.DataClass?> = .idle
  private var cancellables: Set<AnyCancellable> = []

  let keychain = KeychainSwift()
  private let oauthswift = OAuth2Swift(
    consumerKey: API.githubClientID,
    consumerSecret: API.githubClientSecret,
    authorizeUrl: "https://github.com/login/oauth/authorize",
    accessTokenUrl: "https://github.com/login/oauth/access_token",
    responseType: "code"
  )

  func loadUser() {
    state = .processing

    WakatimeAuthenticatedService.shared.getUser()?
      .sink(result: { [weak self] result in
        guard let self = self else { return }

        switch result {
        case let .success(data):
          self.state = .success(data.data)
        case let .failure(error):
          self.state = .failure(error)
        }
      })
      .store(in: &cancellables)
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
