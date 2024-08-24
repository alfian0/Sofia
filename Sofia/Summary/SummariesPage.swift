//
//  SummariesPage.swift
//  Sofia
//
//  Created by alfian on 12/08/24.
//

import Alamofire
import KeychainSwift
import SwiftUI

struct SummariesPage: View {
  @ObservedObject private var viewModel: SummariesPageViewModel

  init(viewModel: SummariesPageViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    Group {
      switch viewModel.state {
      case .idle:
        Text("Idle").font(.title)
      case .processing:
        ProgressView()
      case let .success(summariesModel):
        EmptyView()
      case let .failure(error):
        VStack {
          Text("An error occurred: \(error.localizedDescription)")
            .foregroundColor(.red)
          Button("Retry") {
            viewModel.onRefresh()
          }
        }
      }
    }
    .onAppear {
      viewModel.onRefresh()
    }
//    List {
//      Section {
//        VStack(alignment: .leading, spacing: 16) {
//          VStack(alignment: .leading) {
//            Text(summaries?.cumulativeTotal?.text ?? "")
//              .font(.title)
//              .fontWeight(.bold)
//            Text("Total Time")
//          }
//          VStack(alignment: .leading) {
//            Text(summaries?.dailyAverage?.text ?? "")
//              .font(.title)
//              .fontWeight(.bold)
//            Text("Average")
//          }
//          HStack {
//            VStack(alignment: .leading) {
//              Text("from")
//                .fontWeight(.bold)
//              Text(summaries?.start?.toDate()?.toString(with: "EE MMM dd YYYY") ?? "")
//            }
//
//            Spacer()
//
//            VStack(alignment: .trailing) {
//              Text("to")
//                .fontWeight(.bold)
//              Text(summaries?.end?.toDate()?.toString(with: "EE MMM dd YYYY") ?? "")
//            }
//          }
//        }
//      }
//
//      Section(header: Text("Log Histories")) {
//        let data = (summaries?.data ?? []).reversed()
//        ScrollView(.horizontal) {
//          GeometryReader { proxy in
//            HStack(alignment: .bottom) {
//              ForEach(Array(zip(data.indices, data)), id: \.0) { summarie in
//                let hour = (summarie.1.grandTotal?.totalSeconds ?? 0).secondsToHours
//                ZStack {
//                  Color(UIColor.systemGray6)
//                    .frame(width: 4, height: proxy.size.height)
//                  VStack {
//                    Spacer()
//                    Color.blue
//                      .frame(width: 4, height: (proxy.size.height / 24) * hour)
//                  }
//                }
//              }
//            }
//            .frame(height: 60)
//          }
//        }
//        .frame(height: 60)
//        ForEach(Array(zip(data.indices, data)), id: \.0) { summarie in
//          VStack(alignment: .leading, spacing: 8) {
//            HStack(alignment: .top) {
//              Text(summarie.1.range?.start?.toDate()?.toString(with: "EE dd MM yyyy") ?? "")
//                .font(.caption)
//              Spacer()
//              Text(summarie.1.grandTotal?.text ?? "")
//                .font(.caption)
//                .fontWeight(.bold)
//                .foregroundColor(.green)
//            }
//
//            VStack(alignment: .leading, spacing: 8) {
//              HStack(alignment: .top) {
//                VStack(alignment: .leading, spacing: 4) {
//                  Text("Brances")
//                    .font(.caption)
//                    .fontWeight(.bold)
//                  Text(summarie.1.branches?.map { $0.name ?? "" }.joined(separator: ", ") ?? "")
//                    .font(.caption)
//                }
//                Spacer()
//                VStack(alignment: .trailing, spacing: 4) {
//                  Text("Laguages")
//                    .font(.caption)
//                    .fontWeight(.bold)
//                    .multilineTextAlignment(.trailing)
//                  Text(summarie.1.languages?.map { $0.name ?? "" }.joined(separator: ", ") ?? "")
//                    .font(.caption)
//                    .multilineTextAlignment(.trailing)
//                }
//              }
//              HStack(alignment: .top) {
//                VStack(alignment: .leading, spacing: 4) {
//                  Text("Editor")
//                    .font(.caption)
//                    .fontWeight(.bold)
//                  Text(summarie.1.editors?.map { $0.name ?? "" }.joined(separator: ", ") ?? "")
//                    .font(.caption)
//                }
//                Spacer()
//                VStack(alignment: .trailing, spacing: 4) {
//                  Text("Dependencies")
//                    .font(.caption)
//                    .fontWeight(.bold)
//                    .multilineTextAlignment(.trailing)
//                  Text(summarie.1.dependencies?.map { $0.name ?? "" }.joined(separator: ", ") ?? "")
//                    .font(.caption)
//                    .multilineTextAlignment(.trailing)
//                }
//              }
//              HStack(alignment: .top) {
//                VStack(alignment: .leading, spacing: 4) {
//                  Text("Machine")
//                    .font(.caption)
//                    .fontWeight(.bold)
//                  Text(summarie.1.machines?.map { $0.name ?? "" }.joined(separator: ", ") ?? "")
//                    .font(.caption)
//                }
//                Spacer()
//                VStack(alignment: .trailing, spacing: 4) {
//                  Text("Operating Systems")
//                    .font(.caption)
//                    .fontWeight(.bold)
//                    .multilineTextAlignment(.trailing)
//                  Text(summarie.1.operatingSystems?.map { $0.name ?? "" }.joined(separator: ", ") ?? "")
//                    .font(.caption)
//                    .multilineTextAlignment(.trailing)
//                }
//              }
//              VStack(alignment: .leading, spacing: 4) {
//                Text("Entities")
//                  .font(.caption)
//                  .fontWeight(.bold)
//                Text(summarie.1.entities?.map { $0.name?.components(separatedBy: "/").last ?? "" }
//                  .joined(separator: ", ") ?? "")
//                  .font(.caption)
//              }
//              VStack(alignment: .leading, spacing: 4) {
//                Text("Categories")
//                  .font(.caption)
//                  .fontWeight(.bold)
//                Text(summarie.1.categories?.map { $0.name ?? "" }.joined(separator: ", ") ?? "")
//                  .font(.caption)
//              }
//            }
//            NavigationLink {
//              ProjectPage(
//                project: project,
//                seconds: (summarie.1.grandTotal?.totalSeconds ?? 0),
//                start: summarie.1.range?.start ?? "",
//                end: summarie.1.range?.end ?? ""
//              )
//            } label: {
//              Text("See Details")
//                .font(.caption)
//                .foregroundColor(.blue)
//            }
//          }
//        }
//      }
//    }
//    .listStyle(.plain)
//    .navigationTitle(project)
//    .navigationBarTitleDisplayMode(.inline)
//    .onAppear {
//
//    }
  }
}

struct SummariesPage_Previews: PreviewProvider {
  static var previews: some View {
    let viewModel = SummariesPageViewModel(start: "2024-08-03", end: "2024-08-09", project: "Sofia")
    SummariesPage(viewModel: viewModel)
  }
}
