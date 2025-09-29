//
//  PlaybackUseCase.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//
import Foundation
import Combine

/// 把「每秒填充 1 個 bar」這件事抽成 UseCase（時鐘）。
public protocol PlaybackClockUseCase {
    /// 從 currentIndex（-1 代表尚未開始）逐秒前進到 endIndex（不含）
    func start(from currentIndex: Int, to endIndex: Int)
    /// 暫停
    func pause()
    /// 重設（index 回到 -1）
    func reset()
    /// 目前 index（-1 起跳），UI 可用它推算已填充的 bar 數 = index+1
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

    public func start(from currentIndex: Int, to endIndex: Int) {
        guard !isPlaying else { return }
        self.current = currentIndex
        self.end = max(currentIndex, endIndex)
        isPlaying = true

        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                let next = self.current + 1
                if next >= self.end {
                    self.subject.send(self.end - 1) // 最後一格
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
