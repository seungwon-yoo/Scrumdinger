//
//  MeetingHeaderView.swift
//  Scrumdinger
//
//  Created by 유승원 on 2022/01/16.
//

import SwiftUI

struct MeetingHeaderView: View {
    let secondsElapsed: Int
    let secondsRemaing: Int
    let theme: Theme
    
    private var totalSeconds: Int{
        secondsElapsed + secondsRemaing
    }
    private var progress: Double{
        guard totalSeconds > 0 else { return 1}
        return Double(secondsElapsed) / Double(totalSeconds)
    }
    private var minuteRemaining: Int{
        secondsRemaing / 60
    }
    var body: some View {
        VStack {
            ProgressView(value: progress)
                .progressViewStyle(ScrumProgressViewStyle(theme: theme))
            HStack{
                VStack(alignment: .leading){
                    Text("Seconds Elapsed")
                        .font(.caption)
                    Label("\(secondsElapsed)", systemImage: "hourglass.bottomhalf.fill")
                }
                Spacer()
                VStack(alignment: .trailing){
                    Text("Seconds Remaining")
                        .font(.caption)
                    Label("\(secondsRemaing)", systemImage: "hourglass.tophalf.fill")
                        .labelStyle(.trailingIcon)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Time remaining")
        .accessibilityValue("\(minuteRemaining) minutes")
        .padding([.top, .horizontal])
    }
}

struct MeetingHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        MeetingHeaderView(secondsElapsed: 60, secondsRemaing: 180, theme: .bubblegum)
            .previewLayout(.sizeThatFits)
    }
}
