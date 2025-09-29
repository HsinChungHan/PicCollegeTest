//
//  PlaybackUseCase.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//
import Foundation
import Combine

/// 每秒 tick 一次，用來驅動「每秒填充 1 秒」的綠色背景。
public protocol PlaybackClockUseCase {
    /// 從 currentSec（已經累積的秒數）開始，逐秒前進直到 endSec（總秒數）。
    /// 例如：currentSec=0, endSec=10 → 會依序送出 0...9（代表第 1~10 秒）。
    func start(from currentSec: Int, to endSec: Int)
    func pause()
    func reset()
    /// 已經走到的「索引」（0 起跳），你可以把 idx+1 視為「已累積秒數」。
    var indexPublisher: AnyPublisher<Int, Never> { get }
}

public final class DefaultPlaybackClockUseCase: PlaybackClockUseCase {
    private let subject = CurrentValueSubject<Int, Never>(-1)
    public var indexPublisher: AnyPublisher<Int, Never> { subject.eraseToAnyPublisher() }

    private var timer: AnyCancellable?
    private var current: Int = -1
    private var end: Int = -1
    private var isPlaying = false

    public init() {}

    public func start(from currentSec: Int, to endSec: Int) {
        guard !isPlaying else { return }
        self.current = max(-1, currentSec - 1) // 讓第一次 tick 從 currentSec 開始
        self.end = max(0, endSec)
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

    public func pause() { stop() }

    public func reset() {
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
