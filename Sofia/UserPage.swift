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

struct UserPage: View {
  @State var user: UserModel.DataClass? = nil
  let decoder: JSONDecoder = {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return decoder
  }()
  
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
            Text(user?.modifiedAt ?? "")
          }
          
          Section(header: Text("Social Media")) {
            Label {
              Text("Website")
            } icon: {
              Image(systemName: "globe")
            }
            Label {
              Text("Github")
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
      guard let token = KeychainSwift().get("stringToken"), !token.isEmpty else {
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
  }
}

struct UserPage_Previews: PreviewProvider {
    static var previews: some View {
      UserPage()
    }
}
