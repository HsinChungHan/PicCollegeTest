//
//  PlaybackUseCase.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//
import Foundation
import Combine

/*
 Responsiblity: 提供「每秒填充綠色進度條」的計時機制，並以 Publisher（indexPublisher）對外發布進度事件，讓上層訂閱。負責開始 / 暫停 / 重設播放。
 Rule/Side effects:
    1. 每秒遞增一次，到選取框的終點自動停止並送出最後一個 index(對外只以 Publisher 溝通，不直接觸碰 UI)
    2. Has side effects, 建立/取消 Timer，管理內部狀態（current、end、isPlaying）
 Interaction:
    1. TimelineFeatureViewModel 訂閱 indexPublisher，把 index 轉為「已播放秒數」→ 推導百分比、當前時間、綠色填充等
    2. 由 VM 決定呼叫 play()/pause()/reset() 的時機
*/

protocol PlaybackClockUseCase {
    /// 從 currentSec（已經累積的秒數）開始，逐秒前進直到 endSec（總秒數）。
    /// 例如：currentSec=0, endSec=10 → 會依序送出 0...9（代表第 1~10 秒）。
    func start(from currentSec: Int, to endSec: Int)
    func pause()
    func reset()
    /// 已經走到的「索引」（0 起跳），你可以把 idx+1 視為「已累積秒數」。
    var indexPublisher: AnyPublisher<Int, Never> { get }
}

final class DefaultPlaybackClockUseCase: PlaybackClockUseCase {
    private let subject = CurrentValueSubject<Int, Never>(-1)
    var indexPublisher: AnyPublisher<Int, Never> { subject.eraseToAnyPublisher() }

    private var timer: AnyCancellable?
    private var current: Int = -1
    private var end: Int = -1
    private var isPlaying = false

    func start(from currentSec: Int, to endSec: Int) {
        guard !isPlaying else { return }
        current = max(-1, currentSec - 1) // 讓第一次 tick 從 currentSec 開始
        end = max(0, endSec)
        isPlaying = true

        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                let next = self.current + 1
                if next >= self.end {
                    self.subject.send(self.end - 1)
                    self.stop()
                } else {
                    self.current = next
                    self.subject.send(self.current)
                }
            }
    }

    func pause() { stop() }

    func reset() {
        stop()
        current = -1
        end = -1
        subject.send(-1)
    }

    private func stop() {
        isPlaying = false
        timer?.cancel()
        timer = nil
    }
}
