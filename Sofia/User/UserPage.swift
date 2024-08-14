//
//  UserPage.swift
//  Sofia
//
//  Created by alfian on 09/08/24.
//

import OAuthSwift
import SDWebImageSwiftUI
import SwiftUI

struct UserPage: View {
  @StateObject private var viewModel = UserPageViewModel()

  var body: some View {
    NavigationView {
      VStack {
        switch viewModel.viewState {
        case .idle:
          Text("Idle State")
        case .processing:
          ProgressView()
            .onAppear {
              viewModel.loadUser()
            }
        case let .success(user):
          List {
            Section {
              HStack {
                VStack(alignment: .leading) {
                  Text(user?.displayName ?? "")
                    .font(.title2)
                  Text(user?.email ?? "")
                }

                Spacer()

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
                HStack {
                  Text("Github")
                  Spacer()
                  if viewModel.isGithubConnected {
                    Text("Connected")
                      .fontWeight(.bold)
                      .foregroundColor(.green)
                  } else {
                    Button {
                      viewModel.connectGithub()
                    } label: {
                      Text("Connect")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(height: 44)
                        .padding(.horizontal, 16)
                    }
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.black))
                  }
                }
              } icon: {
                Image(systemName: "arrow.rectanglepath")
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
        case let .failure(error):
          Text("Error: \(error.localizedDescription)")
        }
      }
      .navigationTitle("Profile")
    }
    .onOpenURL { url in
      viewModel.isProcessing = true
      let notification = Notification(
        name: OAuthSwift.didHandleCallbackURL,
        object: nil,
        userInfo: ["OAuthSwiftCallbackNotificationOptionsURLKey": url]
      )
      NotificationCenter.default.post(notification)
    }
    .onAppear {
      if let token = viewModel.keychain.get("githubToken"), !token.isEmpty {
        viewModel.isGithubConnected = true
      }

      viewModel.loadUser()
    }
  }
}

struct UserPage_Previews: PreviewProvider {
  static var previews: some View {
    UserPage()
  }
}
