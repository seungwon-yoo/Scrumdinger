//
//  DetailEditView.swift
//  Scrumdinger
//
//  Created by 유승원 on 2022/01/15.
//

import SwiftUI

struct DetailEditView: View {
    @Binding var data: DailyScrum.Data
    @State private var newAttendeeName = ""
    
    var body: some View {
        Form{
            Section(header: Text("Meeting Info")){
                TextField("Title", text: $data.title)
                HStack{
                    Slider(value: $data.lengthInMinutes, in: 5...30, step: 1){
                        Text("Length") // Slider의 목적을 확인하는 용도
                    }
                    .accessibilityValue("\(Int(data.lengthInMinutes)) minutes")
                    Spacer()
                    Text("\(Int(data.lengthInMinutes)) minutes")
                        .accessibilityHidden(true) // VoiceOver로부터 이 텍스트 뷰를 숨김
                }
                ThemePicker(selection: $data.theme)
            }
            Section(header: Text("Attendees")){
                ForEach(data.attendees) { attendee in
                    Text(attendee.name)
                }
                .onDelete{ indices in
                    data.attendees.remove(atOffsets: indices)
                }
                HStack{
                    TextField("New Attendee", text: $newAttendeeName)
                    Button(action: {
                        withAnimation{
                            let attendee = DailyScrum.Attendee(name: newAttendeeName)
                            data.attendees.append(attendee)
                            newAttendeeName = ""
                        }
                    }){
                        Image(systemName: "plus.circle.fill")
                            .accessibilityLabel("Add attendee")
                    }
                    .disabled(newAttendeeName.isEmpty) // User가 실수로 이름없이 저장하는 것을 막음
                }
            }
        }
    }
}

struct DetailEditView_Previews: PreviewProvider {
    static var previews: some View {
        DetailEditView(data: .constant(DailyScrum.sampleData[0].data))
    }
}
