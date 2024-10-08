//
//  ContentView.swift
//  Sofia
//
//  Created by alfian on 09/08/24.
//

import KeychainSwift
import SwiftUI

struct ContentView: View {
  @State private var isAuthorized = false
  @State private var isProcessing = false

  var body: some View {
    VStack {
      if isAuthorized, !isProcessing {
        TabView {
          HomePage()
            .tabItem {
              Label("Home", systemImage: "house")
            }
          HistoryPage()
            .tabItem {
              Label("History", systemImage: "newspaper")
            }
          LogPage()
            .tabItem {
              Label("Log", systemImage: "book.closed")
            }
          UserPage()
            .tabItem {
              Label("Account", systemImage: "person")
            }
        }
      } else {
        OnboardingPage(isAuthorized: $isAuthorized, isProcessing: $isProcessing)
      }
    }
    .onAppear {
      if let token = KeychainSwift().get("stringToken"),
         !token.isEmpty {
        isAuthorized = true
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
