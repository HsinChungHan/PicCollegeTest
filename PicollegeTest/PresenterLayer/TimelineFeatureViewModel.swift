//
//  Untitled.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//
import Foundation
import Combine

final class TimelineFeatureViewModel: ObservableObject {
    // MARK: - Published State（供 View 綁定）
    @Published private(set) var timeline: Timeline
    @Published var startPercent: Double = 0.0            // 0...1，選取窗起點
    @Published var isPlaying: Bool = false
    @Published private(set) var elapsedSecondsInSelection: Int = 0 // 已填充秒數（0...selectionSeconds）

    // MARK: - Config
    let songDurationSeconds: Double                      // 整首歌總秒
    let selectionSeconds: Int                            // 固定選取窗秒數（例：10）

    // MARK: - Use Cases / Clock
    private let getTimeline: GetTimelineUseCase
    private let jumpUseCase: JumpToKeyTimeUseCase
    private let clock: PlaybackClockUseCase

    private var bag = Set<AnyCancellable>()

    // MARK: - Value Object（依目前設定即時推導）
    var bounds: StartBounds {
        StartBounds(songSeconds: songDurationSeconds,
                    selectionSeconds: Double(selectionSeconds))
    }

    // MARK: - Init
    init(getTimeline: GetTimelineUseCase,
                jumpUseCase: JumpToKeyTimeUseCase,
                clock: PlaybackClockUseCase = DefaultPlaybackClockUseCase(),
                songDurationMinutes: Double,
                selectionSeconds: Int = 10) {
        self.getTimeline = getTimeline
        self.jumpUseCase = jumpUseCase
        self.clock = clock
        self.timeline = getTimeline.execute()
        self.songDurationSeconds = max(1, songDurationMinutes * 60.0)
        self.selectionSeconds = max(1, selectionSeconds)

        // 每秒 tick：把索引轉成已播放秒數，跑滿選取窗秒數後自動停
        clock.indexPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] idx in
                guard let self else { return }
                let elapsed = max(0, idx + 1) // 0 起算 → +1 代表經過的秒數
                self.elapsedSecondsInSelection = min(self.selectionSeconds, elapsed)
                if self.elapsedSecondsInSelection >= self.selectionSeconds {
                    self.isPlaying = false
                }
            }
            .store(in: &bag)
    }

    // MARK: - Domain Interaction
    func refreshTimeline() {
        timeline = getTimeline.execute()
    }

    /// 使用者拖曳波形：回報欲望起點百分比，VM 用 Value Object 收斂
    func onUserDraggedTrimmer(to newPercent: Double) {
        startPercent = bounds.clamp(newPercent)
    }

    /// 使用者點擊 key time：透過用例（含策略），再用 Value Object 收斂
    func onUserTappedKeyTime(_ keyPercent: Double) {
        startPercent = jumpUseCase.execute(
            currentStart: startPercent,
            targetKeyPercent: keyPercent,
            bounds: bounds
        )
    }

    // MARK: - Playback Control（每秒前進 1 秒）
    func togglePlay() { isPlaying ? pause() : play() }

    func play() {
        guard selectionSeconds > 0 else { return }
        isPlaying = true
        clock.start(from: elapsedSecondsInSelection, to: selectionSeconds)
    }

    func pause() {
        isPlaying = false
        clock.pause()
    }

    func reset() {
        isPlaying = false
        clock.reset()
        elapsedSecondsInSelection = 0
    }

    // MARK: - Derived (Percent / Time)
    /// 選取窗起點/終點（百分比）
    var selectionStartPercent: Double { startPercent }
    var selectionEndPercent: Double   { min(1, startPercent + bounds.selectionRatio) }

    /// 選取窗內的播放進度（0...1）
    var progressRatioInSelection: Double {
        guard selectionSeconds > 0 else { return 0 }
        return min(1, Double(elapsedSecondsInSelection) / Double(selectionSeconds))
    }

    /// 沒綠色填充→顯示起點；有綠色填充→起點 + 進度×窗長
    var currentPercent: Double {
        let p = (elapsedSecondsInSelection > 0)
        ? (selectionStartPercent + progressRatioInSelection * bounds.selectionRatio)
        : selectionStartPercent
        return min(1, max(0, p))
    }

    // 以秒表示的對應時間
    var selectionStartTimeSec: Double { selectionStartPercent * songDurationSeconds }
    var selectionEndTimeSec: Double   { selectionEndPercent   * songDurationSeconds }
    var currentTimeSec: Double        { currentPercent        * songDurationSeconds }

    // MARK: - Preformatted Text（供 UI 直接使用）
    var selectionPercentText: String {
        "\(fmtPercent(selectionStartPercent)) - \(fmtPercent(selectionEndPercent))"
    }
    var currentPercentText: String { fmtPercent(currentPercent) }
    var selectionTimeText: String {
        "\(fmtTime(selectionStartTimeSec)) -> \(fmtTime(selectionEndTimeSec))"
    }
    var currentTimeText: String { fmtTime(currentTimeSec) }
    var totalDurationText: String { "Total Duration: " + fmtTime(songDurationSeconds) }

    // MARK: - Helpers
    private func fmtPercent(_ p: Double) -> String {
        String(format: "%.1f%%", p * 100.0)
    }
    private func fmtTime(_ seconds: Double) -> String {
        let s = max(0, Int(seconds.rounded()))
        return String(format: "%d:%02d", s/60, s%60)
    }
}
