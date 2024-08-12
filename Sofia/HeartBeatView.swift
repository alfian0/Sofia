//
//  HeartBeatView.swift
//  Sofia
//
//  Created by alfian on 12/08/24.
//

import SwiftUI

struct HeartBeatModel: Hashable {
  let epoch: Double
  let duration: Double
}

struct HeartBeatView: View {
  private let divider: Double = 86_400
  private let times = ["", "3am", "6am", "9am", "12pm", "3pm", "6pm", "9pm"]
  let startOfEpoch: Double
  let heartbeats: [HeartBeatModel]
  
  var body: some View {
    VStack {
      GeometryReader { proxy in
        let widthPerSecond = (proxy.size.width)/divider
        ForEach(heartbeats, id:\.self) { heartbeat in
          let time = heartbeat.epoch
          let duration = heartbeat.duration
          let timeFromStartOfDay = time - startOfEpoch
          
          Color.red
            .frame(width: max(0.5,widthPerSecond*duration))
            .position(x: widthPerSecond*timeFromStartOfDay, y: 22)
        }
      }
      .frame(height: 44)
      HStack {
        ForEach(times, id:\.self) { time in
          Text(time)
            .font(.caption)
            .foregroundColor(Color(UIColor.systemGray))
          Spacer()
        }
      }
    }
  }
}

struct HeartBeatView_Previews: PreviewProvider {
    static var previews: some View {
      HeartBeatView(
        startOfEpoch: 1723420800,
        heartbeats: [
          HeartBeatModel(epoch: 1723424400, duration: 120)
        ]
      )
    }
}
