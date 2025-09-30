//
//  PlaybackViewModel.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//

import Foundation
import Combine

/// 控制 Play / Pause / Reset 與「選取匡內的綠色填充」計數
final class PlaybackViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var barsInSelection: Int = 0            // 選取匡內 bar 總數
    @Published var filledCountInSelection: Int = 0     // 已填充 bar 數（0-based 計數）

    private let clock: PlaybackClockUseCase
    private var bag = Set<AnyCancellable>()

    init(clock: PlaybackClockUseCase = DefaultPlaybackClockUseCase()) {
        self.clock = clock
        clock.indexPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] idx in
                guard let self else { return }
                self.filledCountInSelection = max(0, idx + 1)
                if self.filledCountInSelection >= self.barsInSelection, self.barsInSelection > 0 {
                    self.isPlaying = false
                }
            }
            .store(in: &bag)
    }

    func play() {
        guard barsInSelection > 0 else { return }
        isPlaying = true
        let currentIndex = max(-1, filledCountInSelection - 1) // -1 代表尚未填第一格
        clock.start(from: currentIndex, to: barsInSelection)
    }

    func pause() {
        isPlaying = false
        clock.pause()
    }

    func reset() {
        isPlaying = false
        clock.reset()
        filledCountInSelection = 0
    }
}
