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
        OnboardingPage(isAuthorized: $isAuthorized, isProcessing: $isProcessing)
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
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
