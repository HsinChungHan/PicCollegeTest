//
//  Untitled.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//
import Combine

public final class TimelineViewModel: ObservableObject {
    @Published public private(set) var timeline: Timeline
    @Published public var startPercent: Double // 0...1, selection window start
    
    
    private let getTimeline: GetTimelineUseCase
    private let setStart: SetStartPercentUseCase
    private let jumpUseCase: JumpToKeyTimeUseCase
    
    
    public init(
        getTimeline: GetTimelineUseCase,
        setStart: SetStartPercentUseCase,
        jumpUseCase: JumpToKeyTimeUseCase
    ) {
        self.getTimeline = getTimeline
        self.setStart = setStart
        self.jumpUseCase = jumpUseCase
        self.timeline = getTimeline.execute()
        self.startPercent = 0.0
    }
    
    
    public func refresh() {
        timeline = getTimeline.execute()
    }
    
    
    public func onUserDraggedTrimmer(to newPercent: Double) {
        startPercent = setStart.execute(newPercent)
    }
    
    
    public func onUserTappedKeyTime(_ keyPercent: Double) {
        startPercent = jumpUseCase.execute(currentStart: startPercent, targetKeyPercent: keyPercent)
    }
}
