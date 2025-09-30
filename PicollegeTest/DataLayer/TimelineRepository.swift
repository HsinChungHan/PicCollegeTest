//
//  TimelineRepository.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//

import Foundation

struct Timeline {
    let length: Double // seconds or normalized 0...1 domain length base
    let keyTimes: [Double] // normalized 0...1 positions
    init(length: Double = 1.0, keyTimes: [Double]) {
        self.length = length
        self.keyTimes = keyTimes.map { min(1, max(0, $0)) }.sorted()
    }
}

protocol TimelineRepository {
    func fetchTimeline() -> Timeline
}

final class InMemoryTimelineRepository: TimelineRepository {
    private let timeline: Timeline
    init(timeline: Timeline = .init(keyTimes: [0.1, 0.3, 0.45, 0.65, 0.85])) {
        self.timeline = timeline
    }
    func fetchTimeline() -> Timeline { timeline }
}
