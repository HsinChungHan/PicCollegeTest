//
//  Untitled.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//
import Foundation
import Combine

 final class TimelineFeatureViewModel: ObservableObject {
    // 基本狀態
    @Published private(set) var timeline: Timeline
    @Published var startPercent: Double = 0.0        // 0...1，選取匡起點
    @Published var isPlaying: Bool = false
    @Published private(set) var elapsedSecondsInSelection: Int = 0  // 已填充的秒數（0...selectionSeconds）

    // 參數
     let songDurationSeconds: Double                  // 總秒數
     let selectionSeconds: Int                        // ✅ 固定 10 秒
     var selectionLengthNormalized: Double {          // 10 秒對整首歌的比例
        min(1, Double(selectionSeconds) / songDurationSeconds)
    }
    
    private var startUpperBound: Double {
        max(0, 1 - (Double(selectionSeconds) / songDurationSeconds))
    }

    private func clampStart(_ p: Double) -> Double {
        min(startUpperBound, max(0, p))
    }

    // UseCases
    private let getTimeline: GetTimelineUseCase
    private let setStart: SetStartPercentUseCase
    private let jumpUseCase: JumpToKeyTimeUseCase
    private let clock: PlaybackClockUseCase

    private var bag = Set<AnyCancellable>()

     init(
        getTimeline: GetTimelineUseCase,
        setStart: SetStartPercentUseCase,
        jumpUseCase: JumpToKeyTimeUseCase,
        clock: PlaybackClockUseCase = DefaultPlaybackClockUseCase(),
        songDurationMinutes: Double,
        selectionSeconds: Int = 10
    ) {
        self.getTimeline = getTimeline
        self.setStart = setStart
        self.jumpUseCase = jumpUseCase
        self.clock = clock
        self.timeline = getTimeline.execute()
        self.songDurationSeconds = max(1, songDurationMinutes * 60.0)
        self.selectionSeconds = max(1, selectionSeconds)

        // 時鐘：每秒遞增
        clock.indexPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] idx in
                guard let self else { return }
                let elapsed = max(0, idx + 1)
                self.elapsedSecondsInSelection = min(self.selectionSeconds, elapsed)
                if self.elapsedSecondsInSelection >= self.selectionSeconds {
                    self.isPlaying = false
                }
            }
            .store(in: &bag)
    }

    // Domain 互動
     func refreshTimeline() {
        timeline = getTimeline.execute()
    }

     func onUserDraggedTrimmer(to newPercent: Double) {
        startPercent = clampStart(setStart.execute(newPercent))
    }

     func onUserTappedKeyTime(_ keyPercent: Double) {
        startPercent = clampStart(
            jumpUseCase.execute(currentStart: startPercent, targetKeyPercent: keyPercent)
        )
    }

    // 播放控制（每秒填充 1 秒）
     func togglePlay() { isPlaying ? pause() : play() }

     func play() {
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

    // 衍生資料（百分比 / 時間）
     var selectionStartPercent: Double { clamp01(startPercent) }
     var selectionEndPercent: Double { clamp01(startPercent + selectionLengthNormalized) }

     var progressRatioInSelection: Double {
        min(1, selectionSeconds == 0 ? 0 : Double(elapsedSecondsInSelection) / Double(selectionSeconds))
    }
     var hasGreen: Bool { elapsedSecondsInSelection > 0 }

    /// 沒綠色 → 起點％；有綠色 → 起點＋進度（不超過終點）
     var currentPercent: Double {
        let p = hasGreen
            ? (selectionStartPercent + progressRatioInSelection * selectionLengthNormalized)
            : selectionStartPercent
        return clamp01(p)
    }

     var selectionStartTimeSec: Double { selectionStartPercent * songDurationSeconds }
     var selectionEndTimeSec: Double   { selectionEndPercent   * songDurationSeconds }
     var currentTimeSec: Double        { currentPercent        * songDurationSeconds }

    // 已格式化字串
     var selectionPercentText: String {
        "\(fmtPercent(selectionStartPercent)) - \(fmtPercent(selectionEndPercent))"
    }
     var currentPercentText: String {
        fmtPercent(currentPercent)
    }
     var selectionTimeText: String {
        "\(fmtTime(selectionStartTimeSec)) -> \(fmtTime(selectionEndTimeSec))"
    }
     var currentTimeText: String {
        fmtTime(currentTimeSec)
    }

    // Helpers
    private func clamp01(_ x: Double) -> Double { min(1, max(0, x)) }
    private func fmtPercent(_ p: Double) -> String { String(format: "%.1f%%", p * 100.0) }
    private func fmtTime(_ seconds: Double) -> String {
        let s = max(0, Int(seconds.rounded()))
        return String(format: "%d:%02d", s/60, s%60)
    }
}
