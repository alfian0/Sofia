//
//  HomePage.swift
//  Sofia
//
//  Created by alfian on 09/08/24.
//

import SwiftUI
import KeychainSwift
import Alamofire

struct HomePage: View {
  @State var statusBar: StatusBarModel.DataClass?
  let decoder: JSONDecoder = {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return decoder
  }()
  
  var body: some View {
    NavigationView {
      List {
        Section(header: Text("Today's Work Hours")) {
          HStack {
            Text(statusBar?.grandTotal?.text ?? "")
              .fontWeight(.bold)
            
            Spacer()
            
            HStack {
//              Text(statusBar?.range?.start ?? "")
//              Text(statusBar?.range?.end ?? "")
              Text("08:30")
              Text("-")
              Text("19:30")
            }
          }
          HStack {
            Text(statusBar?.machines?.first?.name ?? "")
            Spacer()
            Text(statusBar?.operatingSystems?.first?.name ?? "")
          }
        }
        
        if let projects = statusBar?.projects {
          Section(header: Text("Today's Project")) {
            ForEach(Array(zip(projects.indices, projects)), id:\.0) { project in
              HStack {
                Text(project.1.name ?? "")
                Spacer()
                ProgressView(value: (project.1.totalSeconds ?? 0)/86400)
                  .frame(width: 200)
                  .progressViewStyle(LinearProgressViewStyle(tint: .black))
              }
            }
          }
        }
        
        if let languages = statusBar?.languages {
          Section(header: Text("Today's Langages")) {
            ForEach(Array(zip(languages.indices, languages)), id:\.0) { language in
              HStack {
                Text(language.1.name ?? "")
                Spacer()
                ProgressView(value: (language.1.totalSeconds ?? 0)/86400)
                  .frame(width: 200)
                  .progressViewStyle(LinearProgressViewStyle(tint: .black))
              }
            }
          }
        }
        
        if let categories = statusBar?.categories {
          Section(header: Text("Today's Categories")) {
            ForEach(Array(zip(categories.indices, categories)), id:\.0) { categorie in
              HStack {
                Text(categorie.1.name ?? "")
                Spacer()
                ProgressView(value: (categorie.1.totalSeconds ?? 0)/86400)
                  .frame(width: 200)
                  .progressViewStyle(LinearProgressViewStyle(tint: .black))
              }
            }
          }
        }
      }
      .listStyle(.plain)
      .navigationTitle("Hei")
    }
    .onAppear {
      if let token = KeychainSwift().get("stringToken"),
         !token.isEmpty {
        AF.request(
          URL(string: "https://wakatime.com/api/v1/users/current/status_bar/today")!,
          headers: .init([.authorization(bearerToken: token)])
        ).responseDecodable(
          of: StatusBarModel.self,
          decoder: decoder
        ) { response in
          switch response.result {
          case .success(let data):
            statusBar = data.data
          case .failure(let error):
            print(error)
          }
        }
      }
    }
  }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
