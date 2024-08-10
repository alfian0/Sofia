//
//  UserPage.swift
//  Sofia
//
//  Created by alfian on 09/08/24.
//

import SwiftUI
import Alamofire
import KeychainSwift
import SDWebImageSwiftUI
import OAuthSwift

struct UserPage: View {
  @State var user: UserModel.DataClass? = nil
  @State var isGithubConnected: Bool = false
  @State var isProcessing: Bool = false
  let decoder: JSONDecoder = {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return decoder
  }()
  private let keychain = KeychainSwift()
  private let oauthswift = OAuth2Swift(
    consumerKey: API.githubClientID,
    consumerSecret: API.githubClientSecret,
    authorizeUrl: "https://github.com/login/oauth/authorize",
    accessTokenUrl: "https://github.com/login/oauth/access_token",
    responseType: "code"
  )
  
  var body: some View {
    NavigationView(content: {
      VStack {
        List {
          Section {
            Label {
              VStack(alignment: .leading) {
                Text(user?.displayName ?? "")
                  .font(.title2)
                Text(user?.email ?? "")
              }
            } icon: {
              WebImage(url: URL(string: user?.photo ?? "")) { image in
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
          
          Section(header: Text("Last Modified")) {
            Text((user?.modifiedAt ?? "").toDate()?.toString(identifier: user?.timezone ?? "") ?? "")
          }
          
          Section(header: Text("Social Media")) {
            Label {
              Text("Website")
            } icon: {
              Image(systemName: "globe")
            }
            Label {
              HStack {
                Text("Github")
                Spacer()
                if isGithubConnected {
                  Text("Connected")
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                } else {
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
                      withCallbackURL: URL(string: "sofia://oauth-callback/github")!,
                      scope: "user repo",
                      state: "state"
                    ) { result in
                      isProcessing = false
                      switch result {
                      case .success(let token):
                        keychain.set(token.credential.oauthToken, forKey: "githubToken")
                        isGithubConnected = true
                      case .failure(let error):
                        print(error.localizedDescription)
                      }
                    }
                  } label: {
                    Text("Connect")
                      .fontWeight(.bold)
                      .foregroundColor(.white)
                      .frame(height: 44)
                      .padding(.horizontal, 16)
                  }
                  .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
                }
              }
            } icon: {
              Image(systemName: "arrow.rectanglepath")
            }
            Label {
              Text("Twitter")
            } icon: {
              Image(systemName: "bird")
            }
          }
          
          Section(header: Text("Last Project")) {
            Label {
              Text(user?.lastProject ?? "")
            } icon: {
              Image(systemName: "exclamationmark.bubble")
            }
          }
          
          Section(header: Text("Last Plugin")) {
            Label {
              Text(user?.lastPlugin ?? "")
            } icon: {
              Image(systemName: "plus.rectangle.on.rectangle")
            }
          }
        }
        .listStyle(.plain)
      }
      .navigationTitle("Profile")
    })
    .onAppear {
      if let token = keychain.get("githubToken"), !token.isEmpty {
        isGithubConnected = true
      }
      
      guard let token = keychain.get("stringToken"), !token.isEmpty else {
        return
      }
      AF.request(
        URL(string: "https://wakatime.com/api/v1/users/current")!,
        headers: .init([.authorization(bearerToken: token)])
      ).responseDecodable(
        of: UserModel.self,
        decoder: decoder
      ) { response in
        switch response.result {
        case .success(let data):
          user = data.data
        case .failure(let error):
          print(error)
        }
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

struct UserPage_Previews: PreviewProvider {
    static var previews: some View {
      UserPage()
    }
}

extension String {
  func toDate() -> Date? {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter.date(from: self)
  }
}

extension Date {
  func toString(
    with format: String = "yyyy-MM-dd HH:mm:ss",
    identifier: String = "Asia/Jakarta"
  ) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: identifier)
    dateFormatter.dateFormat = format
    
    return dateFormatter.string(from: self)
  }
}
