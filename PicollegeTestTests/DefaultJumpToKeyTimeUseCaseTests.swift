//
//  DefaultJumpToKeyTimeUseCaseTests.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//

import XCTest
@testable import PicollegeTest

final class DefaultJumpToKeyTimeUseCaseTests: XCTestCase {

    func test_execute_JumpWithinBounds_ReturnsTarget() {
        // song=100s, selection=10s → selectionRatio=0.1 → maxStart=0.9
        let bounds = StartBounds(songSeconds: 100, selectionSeconds: 10)
        let sut = DefaultJumpToKeyTimeUseCase()

        let newStart = sut.execute(currentStart: 0.0, targetKeyPercent: 0.45, bounds: bounds)

        XCTAssertEqual(newStart, 0.45, accuracy: 1e-9)
    }

    func test_execute_JumpBeyondRightEdge_ClampsToMaxStart() {
        let bounds = StartBounds(songSeconds: 100, selectionSeconds: 10) // maxStart = 0.9
        let sut = DefaultJumpToKeyTimeUseCase()

        let newStart = sut.execute(currentStart: 0.0, targetKeyPercent: 0.95, bounds: bounds)

        XCTAssertEqual(newStart, bounds.maxStart, accuracy: 1e-9)
        XCTAssertEqual(bounds.maxStart, 0.9, accuracy: 1e-9)
    }

    func test_execute_JumpBelowZero_ClampsToZero() {
        let bounds = StartBounds(songSeconds: 100, selectionSeconds: 10)
        let sut = DefaultJumpToKeyTimeUseCase()

        let newStart = sut.execute(currentStart: 0.2, targetKeyPercent: -0.2, bounds: bounds)

        XCTAssertEqual(newStart, 0.0, accuracy: 1e-9)
    }

    func test_execute_SelectionLongerOrEqualToSong_ForcesStartZero() {
        // selection>=song → selectionRatio=1 → maxStart=0
        let bounds = StartBounds(songSeconds: 90, selectionSeconds: 120)
        let sut = DefaultJumpToKeyTimeUseCase()

        let newStart = sut.execute(currentStart: 0.7, targetKeyPercent: 0.6, bounds: bounds)

        XCTAssertEqual(newStart, 0.0, accuracy: 1e-9)
    }
}
