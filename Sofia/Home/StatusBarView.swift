//
//  StatusBarView.swift
//  Sofia
//
//  Created by alfian on 11/08/24.
//

import SwiftUI

struct StatusBarView: View {
  @State private var selectedProject: StatusBarModel.Category?
  var statusBar: StatusBarModel.DataClass
  let divider: Double = 86400
  let procectChars: [String] = ["🧑🏻‍💻", "👨🏼‍💻", "👩🏻‍💻"]

  var body: some View {
    let totalSeconds = (statusBar.grandTotal?.totalSeconds ?? 0)

    Section(header: Text("Today's Work Hours")) {
      VStack {
        VStack {
          HStack {
            Text(statusBar.grandTotal?.text ?? "")
              .fontWeight(.bold)

            Spacer()
          }
          ProgressView(value: totalSeconds / divider)
        }
        HStack {
          Text("💻")
          Text(statusBar.machines?.last?.name ?? "")
          Spacer()
          Text(statusBar.operatingSystems?.last?.name ?? "")
        }
      }
    }

    if let projects = statusBar.projects {
      Section(header: Text("Today's Project")) {
        ForEach(Array(zip(projects.indices, projects)), id: \.0) { project in
          Button {
            selectedProject = project.1
          } label: {
            HStack {
              Text(procectChars.randomElement() ?? "🧑🏻‍💻")
              Text(project.1.name ?? "")
              Spacer()
              ProgressView(value: (project.1.totalSeconds ?? 0) / totalSeconds)
                .frame(width: 200)
            }
          }
        }
      }
      .fullScreenCover(item: $selectedProject, content: { project in
        NavigationView {
          ProjectPage(
            project: project.name ?? "",
            seconds: project.totalSeconds ?? 0,
            start: statusBar.range?.start ?? "",
            end: statusBar.range?.end ?? ""
          )
          .navigationBarItems(leading: Button(action: {
            selectedProject = nil
          }, label: {
            Image(systemName: "chevron.left")
          }))
        }
      })
    }

    if let languages = statusBar.languages {
      Section(header: Text("Today's Languages")) {
        ForEach(Array(zip(languages.indices, languages)), id: \.0) { language in
          HStack {
            Text("#️⃣")
            Text(language.1.name ?? "")
            Spacer()
            ProgressView(value: (language.1.totalSeconds ?? 0) / totalSeconds)
              .frame(width: 200)
          }
        }
      }
    }

    if let categories = statusBar.categories {
      Section(header: Text("Today's Categories")) {
        ForEach(Array(zip(categories.indices, categories)), id: \.0) { categorie in
          HStack {
            Text("⏳")
            Text(categorie.1.name ?? "")
            Spacer()
            ProgressView(value: (categorie.1.totalSeconds ?? 0) / totalSeconds)
              .frame(width: 200)
          }
        }
      }
    }
  }
}
