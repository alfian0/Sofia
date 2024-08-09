//
//  ContentView.swift
//  Sofia
//
//  Created by alfian on 09/08/24.
//

import SwiftUI
import OAuthSwift

struct ContentView: View {
  @State private var isAuthorized = false
  @State private var isProcessing = false
  
  let oauthswift = OAuth2Swift(
    consumerKey: API.clientID,
    consumerSecret: API.clientSecret,
    authorizeUrl: "https://wakatime.com/oauth/authorize",
    accessTokenUrl: "https://wakatime.com/oauth/token",
    responseType: "code"
  )

  var body: some View {
    VStack {
      if isAuthorized {
        Text("You are authorized!")
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
                  print(token)
                  isAuthorized.toggle()
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
    .onOpenURL { url in
      isProcessing.toggle()
      
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
