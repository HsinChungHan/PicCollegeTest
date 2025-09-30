//
//  GetTimelineUseCase.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//

protocol GetTimelineUseCase {
    func execute() -> Timeline
}


final class DefaultGetTimelineUseCase: GetTimelineUseCase {
    private let repo: TimelineRepository
    
    init(repo: TimelineRepository) {
        self.repo = repo
    }
    
    func execute() -> Timeline {
        repo.fetchTimeline()
    }
}
