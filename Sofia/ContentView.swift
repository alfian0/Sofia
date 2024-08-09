//
//  ContentView.swift
//  Sofia
//
//  Created by alfian on 09/08/24.
//

import SwiftUI
import OAuthSwift
import KeychainSwift
import Alamofire

struct ContentView: View {
  @State private var isAuthorized = false
  @State private var isProcessing = false
  @State private var grandTotal: String?
  
  let oauthswift = OAuth2Swift(
    consumerKey: API.clientID,
    consumerSecret: API.clientSecret,
    authorizeUrl: "https://wakatime.com/oauth/authorize",
    accessTokenUrl: "https://wakatime.com/oauth/token",
    responseType: "code"
  )
  
  private let keychain = KeychainSwift()
  
  let decoder: JSONDecoder = {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return decoder
  }()

  var body: some View {
    VStack {
      if isAuthorized {
        Text(grandTotal ?? "You are authorized!")
      } else {
        Group {
          if isProcessing {
            ProgressView()
          } else {
            Button {
              oauthswift.authorizeURLHandler = SafariURLHandler(
                viewController: UIApplication.shared.windows.first!.rootViewController!,
                oauthSwift: oauthswift
              )
              
              let _ = oauthswift.authorize(
                withCallbackURL: URL(string: "sofia://oauth-callback/wakatime")!,
                scope: "email read_stats.languages read_summaries.projects read_summaries read_heartbeats",
                state: "state"
              ) { result in
                switch result {
                case .success(let token):
                  keychain.set(token.credential.oauthToken, forKey: "stringToken")
                  isAuthorized = true
                case .failure(let error):
                  print(error)
                }
              }
            } label: {
              Text("Authenticate")
            }
          }
        }
      }
    }
    .onAppear {
      if let token = keychain.get("stringToken"),
         !token.isEmpty {
        isAuthorized = true
        AF.request(
          URL(string: "https://wakatime.com/api/v1/users/current/status_bar/today")!,
          headers: .init([.authorization(bearerToken: token)])
        ).responseDecodable(
          of: StatusBarModel.self,
          decoder: decoder
        ) { response in
          switch response.result {
          case .success(let data):
            grandTotal = data.data?.grandTotal?.text
          case .failure(let error):
            print(error)
          }
        }
      } else {
        isAuthorized = false
      }
    }
    .onOpenURL { url in
      isProcessing = true
      
      let notification = Notification(
        name: OAuthSwift.didHandleCallbackURL,
        object: nil,
        userInfo: ["OAuthSwiftCallbackNotificationOptionsURLKey": url]
      )
      
      NotificationCenter.default.post(notification)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
