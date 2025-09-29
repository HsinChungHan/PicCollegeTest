//
//  TimelineFeatureView.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//
import SwiftUI

public struct TimelineFeatureView: View {
    @StateObject private var vm: TimelineViewModel

    public init(repo: TimelineRepository = InMemoryTimelineRepository()) {
        let get = DefaultGetTimelineUseCase(repo: repo)
        let set = DefaultSetStartPercentUseCase()
        let jump = DefaultJumpToKeyTimeUseCase(setStart: set)
        _vm = StateObject(wrappedValue: TimelineViewModel(getTimeline: get, setStart: set, jumpUseCase: jump))
    }

    public var body: some View {
        VStack(spacing: 16) {
            // 1) 上方是 KeyTimeSelectionView
            KeyTimeSelectionView(
                position: $vm.startPercent, // 綁定到同一條時間軸的『起點』
                keyTimes: vm.timeline.keyTimes,
                indicatorPercent: vm.startPercent // 顯示黃色 bar，與選取匡起點同步
            )
            .frame(height: 44)

            // 2) 下方是 ScrollingWaveformTrimmer
            ScrollingWaveformTrimmer(start: $vm.startPercent)
                .frame(height: 96)

            // Debug info
            Text(String(format: "start = %.3f (%.0f%%)", vm.startPercent, vm.startPercent*100))
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(.white)
        }
        .padding()
        .background(Color.black)
        .onChange(of: vm.startPercent) { _, newValue in
            vm.onUserDraggedTrimmer(to: newValue)
        }
    }
}

// MARK: - Local Preview
#Preview {
    TimelineFeatureView()
        .padding()
        .background(Color.black)
}
