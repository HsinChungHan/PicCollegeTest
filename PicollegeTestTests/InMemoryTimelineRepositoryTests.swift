//
//  InMemoryTimelineRepositoryTests.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//

import XCTest
@testable import PicollegeTest

final class InMemoryTimelineRepositoryTests: XCTestCase {

    func test_fetchTimeline_DefaultInit_ProvidesExpectedKeyTimes() {
        let repo = InMemoryTimelineRepository() // 預設 keyTimes: [0.1,0.3,0.45,0.65,0.85]
        let timeline = repo.fetchTimeline()

        XCTAssertEqual(timeline.keyTimes, [0.1, 0.3, 0.45, 0.65, 0.85])
        XCTAssertEqual(timeline.length, 1.0, "Default length should be 1.0 unless overridden")
    }

    func test_fetchTimeline_CustomTimeline_IsReturnedAsProvided() {
        let custom = Timeline(length: 5.0, keyTimes: [0.7, -0.2, 1.3])
        // Timeline init 會 clamp/sort → [0.0, 0.7, 1.0]
        let repo = InMemoryTimelineRepository(timeline: custom)

        let timeline = repo.fetchTimeline()
        XCTAssertEqual(timeline.length, 5.0)
        XCTAssertEqual(timeline.keyTimes, [0.0, 0.7, 1.0])
    }
}
