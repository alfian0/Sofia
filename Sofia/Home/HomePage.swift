//
//  HomePage.swift
//  Sofia
//
//  Created by alfian on 09/08/24.
//

import SwiftUI

struct HomePage: View {
    @StateObject private var viewModel = HomePageViewModel()
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle("Today")
                .navigationBarItems(
                    trailing: Button {
                        viewModel.onRefresh()
                    } label: {
                        if case .processing = viewModel.state {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                )
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Text("Idle").font(.title)
            
        case .processing:
            ProgressView()
            
        case .success(let statusBar):
            List {
                VStack(alignment: .leading) {
                    Text(viewModel.insight).font(.title)
                    if !viewModel.footer.isEmpty {
                        Text(viewModel.footer)
                            .font(.caption)
                            .foregroundColor(Color(UIColor.systemGray))
                    }
                }
                
                if let totalSeconds = statusBar.grandTotal?.totalSeconds, totalSeconds > 0 {
                    StatusBarView(statusBar: statusBar)
                } else {
                    NoDataView()
                }
            }
            .listStyle(.plain)
            
        case .failure(let error):
            VStack {
                Text("An error occurred: \(error.localizedDescription)")
                    .foregroundColor(.red)
                Button("Retry") {
                    viewModel.onRefresh()
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
