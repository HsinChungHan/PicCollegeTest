//
//  GetTimelineUseCase.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//

public protocol GetTimelineUseCase {
    func execute() -> Timeline
}


public final class DefaultGetTimelineUseCase: GetTimelineUseCase {
    private let repo: TimelineRepository
    
    public init(repo: TimelineRepository) {
        self.repo = repo
    }
    
    public func execute() -> Timeline {
        repo.fetchTimeline()
    }
}
