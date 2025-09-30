//
//  DefaultGetTimelineUseCaseTests.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//

import XCTest
@testable import PicollegeTest

final class DefaultGetTimelineUseCaseTests: XCTestCase {

    func test_execute_ReturnsTimelineFromRepository() {
        // Arrange
        let given = Timeline(length: 2.0, keyTimes: [0.3, 0.1, 1.2, -0.1]) // Timeline 會 clamp/sort
        // 期望：keyTimes 被 clamp 至 [0.0, 0.1, 0.3, 1.0]
        let repo = FakeTimelineRepository(timeline: given)
        let sut = DefaultGetTimelineUseCase(repo: repo)

        // Act
        let result = sut.execute()

        // Assert
        XCTAssertEqual(result.length, 2.0)
        XCTAssertEqual(result.keyTimes, [0.0, 0.1, 0.3, 1.0])
    }

    // MARK: - Test Doubles
    private struct FakeTimelineRepository: TimelineRepository {
        let timeline: Timeline
        func fetchTimeline() -> Timeline { timeline }
    }
}
