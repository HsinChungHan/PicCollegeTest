//
//  DefaultPlaybackClockUseCaseTests.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//

// DefaultPlaybackClockUseCaseTests.swift
import XCTest
import Combine
@testable import PicollegeTest

final class DefaultPlaybackClockUseCaseTests: XCTestCase {

    private var bag = Set<AnyCancellable>()

    func test_start_EmitsIndicesAndStopsAtEnd() {
        let sut = DefaultPlaybackClockUseCase()

        // 我們預期收到 0,1（start=0, end=2）
        let expectDone = expectation(description: "emits 0,1 then stops")
        expectDone.expectedFulfillmentCount = 1

        var received: [Int] = []
        sut.indexPublisher
            .sink { idx in
                // 初始值為 -1；只收 >=0 的 tick
                guard idx >= 0 else { return }
                received.append(idx)
                if idx == 1 { // end-1
                    expectDone.fulfill()
                }
            }
            .store(in: &bag)

        sut.start(from: 0, to: 2)

        wait(for: [expectDone], timeout: 3.0)

        XCTAssertEqual(received, [0, 1], "Should emit 0,1 and stop")
    }

    func test_pause_StopsFurtherEmissions() {
        let sut = DefaultPlaybackClockUseCase()

        let firstTick = expectation(description: "first tick received")
        var received: [Int] = []

        sut.indexPublisher
            .sink { idx in
                guard idx >= 0 else { return }
                received.append(idx)
                if received.count == 1 {
                    firstTick.fulfill()
                }
            }
            .store(in: &bag)

        sut.start(from: 0, to: 10)

        wait(for: [firstTick], timeout: 2.0)
        sut.pause()

        // 等 1.2s 確認沒有再前進
        let noMore = expectation(description: "no more ticks after pause")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            noMore.fulfill()
        }
        wait(for: [noMore], timeout: 2.0)

        XCTAssertEqual(received.count, 1, "After pause(), there should be no more ticks")
    }
}
