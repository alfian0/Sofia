//
//  OnboardingPage.swift
//  Sofia
//
//  Created by alfian on 09/08/24.
//

import SwiftUI
import OAuthSwift
import KeychainSwift

struct OnboardingPage: View {
  @Binding var isAuthorized: Bool
  @Binding var isProcessing: Bool
  private let keychain = KeychainSwift()
  private let oauthswift = OAuth2Swift(
    consumerKey: API.clientID,
    consumerSecret: API.clientSecret,
    authorizeUrl: "https://wakatime.com/oauth/authorize",
    accessTokenUrl: "https://wakatime.com/oauth/token",
    responseType: "code"
  )
  
  var body: some View {
    VStack(alignment: .leading, spacing: 32) {
      Text("Sofia")
        .font(Font.system(size: 50))
        .fontWeight(.bold)
      Text("Stop tracking work manually - Automate it and reclaim your time.")
        .font(.largeTitle)
      
      GeometryReader { proxy in
        Image("Delivery")
          .resizable()
          .scaledToFit()
          .frame(maxWidth: proxy.size.width/1.2)
          .position(x: proxy.frame(in: .local).midX, y: proxy.frame(in: .local).midY)
      }
      
      Button {
        guard !isProcessing else {
          return
        }
        
        isProcessing = true
        
        oauthswift.authorizeURLHandler = SafariURLHandler(
          viewController: UIApplication.shared.windows.first!.rootViewController!,
          oauthSwift: oauthswift
        )
        
        let _ = oauthswift.authorize(
          withCallbackURL: URL(string: "sofia://oauth-callback/wakatime")!,
          scope: "email read_stats.languages read_summaries.projects read_summaries read_heartbeats",
          state: "state"
        ) { result in
          isProcessing = false
          
          switch result {
          case .success(let token):
            keychain.set(token.credential.oauthToken, forKey: "stringToken")
            isAuthorized = true
          case .failure(let error):
            isAuthorized = false
            print(error.localizedDescription)
          }
        }
      } label: {
        if isProcessing {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
            .frame(height: 44)
            .frame(maxWidth: .infinity)
        } else {
          Text("Continue with Wakatime")
            .font(.body)
            .fontWeight(.bold)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
        }
      }
      .foregroundColor(Color.white)
      .background(RoundedRectangle(cornerRadius: 8).fill(.black))
      .buttonStyle(.plain)
    }
    .padding(.horizontal, 32)
    .onAppear {
      isProcessing = false
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

struct OnboardingPage_Previews: PreviewProvider {
    static var previews: some View {
      OnboardingPage(isAuthorized: .constant(false), isProcessing: .constant(false))
    }
}
