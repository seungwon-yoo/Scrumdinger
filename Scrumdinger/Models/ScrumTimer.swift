//
//  ScrumTimer.swift
//  Scrumdinger
//
//  Created by 유승원 on 2022/01/16.
//

import Foundation

/// daily scrum meeting을 위해 시간을 기록함, 현재 발화하는 사람의 이름, 각각 발화한 시간, 전체 미팅 시간을 추적함.
class ScrumTimer: ObservableObject {
    /// 미팅동안 미팅 참석자들을 추적하는 구조체
    struct Speaker: Identifiable{
        let name: String
        /// 참석자가 자기 차례에 발화를 했는지 여부
        var isCompleted: Bool
        let id = UUID()
    }
    
    /// 발화하는 미팅 참석자의 이름
    @Published var activeSpeaker = ""
    /// 미팅 시작 이후의 진행된 시간(초)
    @Published var secondsElapsed = 0
    /// 모든 참석자들이 말할 차례에 부여되는 시간
    @Published var secondsRemaining = 0
    /// 모든 미팅 참석자
    private(set) var speakers: [Speaker] = []
    
    /// scrum 미팅 길이
    private(set) var lengthInMinutes: Int
    /// 새로운 참석자가 발화를 시작할 때 실행되는 클로저
    var speakerChangedAction: (() -> Void)?
    
    private var timer: Timer?
    private var timerStopped = false
    private var frequency: TimeInterval { 1.0 / 60.0 }
    private var lengthInSeconds: Int { lengthInMinutes * 60 }
    private var secondsPerSpeaker: Int{
        (lengthInMinutes * 60) / speakers.count
    }
    private var secondsElapsedForSpeaker: Int = 0
    private var speakerIndex: Int = 0
    private var speakerText: String {
        return "Speaker \(speakerIndex + 1): " + speakers[speakerIndex].name
    }
    private var startDate: Date?
    
    /**
            새로운 타이머를 초기화 합니다. 별 다른 argument없이 시간을 초기화 하는 것은 참석자가 없고 길이가 0인 ScrumTimer를 생성한다.
            타이머를 시작하려면 startScrum()을 사용하시오.
     
            - 변수 :
                - lengthInMinutes : 미팅 길이
                - attendees : 미팅 참석자의 수
     */
    init(lengthInMinutes: Int = 0, attendees: [DailyScrum.Attendee] = []){
        self.lengthInMinutes = lengthInMinutes
        self.speakers = attendees.speakers
        secondsRemaining = lengthInSeconds
        activeSpeaker = speakerText
    }
    
    func startScrum(){
        changeToSpeaker(at: 0)
    }
    
    func stopScrum(){
        timer?.invalidate()
        timer = nil
        timerStopped = true
    }
    
    /// 타이머를 다음 사람에게 넘긴다
    func skipSpeaker(){
        changeToSpeaker(at: speakerIndex + 1)
    }
    
    private func changeToSpeaker(at index: Int){
        if index > 0{
            let previousSpeakerIndex = index - 1
            speakers[previousSpeakerIndex].isCompleted = true
        }
        secondsElapsedForSpeaker = 0
        guard index < speakers.count else { return }
        speakerIndex = index
        activeSpeaker = speakerText
        
        secondsElapsed = index * secondsPerSpeaker
        secondsRemaining = lengthInSeconds - secondsElapsed
        startDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true){ [weak self] timer in
            if let self = self, let startDate = self.startDate{
                let secondsElapsed = Date().timeIntervalSince1970 - startDate.timeIntervalSince1970
                self.update(secondsElapsed: Int(secondsElapsed))
            }
        }
    }
    
    private func update(secondsElapsed: Int){
        secondsElapsedForSpeaker = secondsElapsed
        self.secondsElapsed = secondsPerSpeaker * speakerIndex + secondsElapsedForSpeaker
        guard secondsElapsed <= secondsPerSpeaker else{
            return
        }
        secondsRemaining = max(lengthInSeconds - self.secondsElapsed, 0)
        
        guard !timerStopped else { return }
        
        if secondsElapsedForSpeaker >= secondsPerSpeaker{
            changeToSpeaker(at: speakerIndex + 1)
            speakerChangedAction?()
        }
    }
    
    /**
     새로운 미팅과 새로운 참석자로 타이머를 초기화한다.
     
     - 변수 :
        - lengthInMinutes : 미팅 길이
        - attendees : 각 참석자의 이름
     */
    func reset(lengthInMinutes: Int, attendees: [DailyScrum.Attendee]){
        self.lengthInMinutes = lengthInMinutes
        self.speakers = attendees.speakers
        secondsRemaining = lengthInSeconds
        activeSpeaker = speakerText
    }
}

extension DailyScrum{
    var timer: ScrumTimer{
        ScrumTimer(lengthInMinutes: lengthInMinutes, attendees: attendees)
    }
}

extension Array where Element == DailyScrum.Attendee {
    var speakers: [ScrumTimer.Speaker]{
        if isEmpty {
            return [ScrumTimer.Speaker(name: "Speaker 1", isCompleted: false)]
        } else {
            return map{ScrumTimer.Speaker(name: $0.name, isCompleted: false)}
        }
    }
}
