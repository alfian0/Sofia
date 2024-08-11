//
//  NoDataView.swift
//  Sofia
//
//  Created by alfian on 11/08/24.
//

import SwiftUI

struct NoDataView: View {
  let icon: [String] = ["☕️", "📭", "🪫", "🫗", "🫙"]
    var body: some View {
      VStack(spacing: 16) {
        Spacer()
        HStack {
          Spacer()
          Text(icon.randomElement() ?? "☕️")
            .font(.system(size: 100))
          Spacer()
        }
        HStack(alignment: .center) {
          Spacer()
          Text("No activity recorded for this hour")
            .font(.title)
            .multilineTextAlignment(.center)
          Spacer()
        }
        HStack(alignment: .center) {
          Spacer()
          Text("Start a new task or take a well-deserved break.")
            .font(.body)
            .multilineTextAlignment(.center)
          Spacer()
        }
        Spacer()
      }
    }
}

struct NoDataView_Previews: PreviewProvider {
    static var previews: some View {
        NoDataView()
    }
}
