//
//  TimelineFeatureView.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//
import SwiftUI
import SwiftUI

public struct TimelineFeatureView: View {
    @StateObject private var vm: TimelineViewModel
    @StateObject private var playback = PlaybackViewModel()

    public init(repo: TimelineRepository = InMemoryTimelineRepository()) {
        let get = DefaultGetTimelineUseCase(repo: repo)
        let set = DefaultSetStartPercentUseCase()
        let jump = DefaultJumpToKeyTimeUseCase(setStart: set)
        _vm = StateObject(wrappedValue: TimelineViewModel(getTimeline: get, setStart: set, jumpUseCase: jump))
    }

    public var body: some View {
        VStack(spacing: 16) {
            // 1) KeyTimeSelectionView
            KeyTimeSelectionView(
                position: $vm.startPercent,
                keyTimes: vm.timeline.keyTimes,
                indicatorPercent: vm.startPercent
            )
            .frame(height: 44)

            // 2) ScrollingWaveformTrimmer（帶播放覆蓋層）
            ScrollingWaveformTrimmer(
                start: $vm.startPercent,
                barsInSelection: playback.barsInSelection,
                filledCountInSelection: playback.filledCountInSelection
            ) { count in
                // 子 view 告知「選取匡內 bar 總數」
                if playback.barsInSelection != count {
                    playback.barsInSelection = count
                    if playback.filledCountInSelection > count {
                        playback.filledCountInSelection = count
                    }
                }
            }
            .frame(height: 96)

            // Debug info
            Text(String(format: "start = %.3f (%.0f%%)", vm.startPercent, vm.startPercent*100))
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(.white.opacity(0.9))

            // 3) 控制列：Play/Pause + Reset
            HStack(spacing: 12) {
                Button(playback.isPlaying ? "Pause" : "Play") {
                    playback.isPlaying ? playback.pause() : playback.play()
                }
                .buttonStyle(.borderedProminent)

                Button("Reset") {
                    playback.reset()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.black)
        .onChange(of: vm.startPercent) { _, newValue in
            vm.onUserDraggedTrimmer(to: newValue)
            // 若希望拖動起點就清掉進度，可打開：
            // playback.pause()
            // playback.reset()
        }
    }
}

// Local Preview
#Preview {
    TimelineFeatureView()
        .padding()
        .background(Color.black)
}
