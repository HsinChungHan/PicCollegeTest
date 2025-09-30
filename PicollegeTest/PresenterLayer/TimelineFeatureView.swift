//
//  TimelineFeatureView.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//
import SwiftUI

/// TimelineFeatureView（採用 Value Object：StartBounds）
/// - 顯示四個標籤：Selection%、Current%、Selected mm:ss、Current mm:ss
/// - KeyTimeSelectionView：點擊關鍵點可更新起點
/// - ScrollingWaveformTrimmer：選取框固定 10 秒、寬度 = 螢幕一半；整首歌波形長度依比例展開
struct TimelineFeatureView: View {
    @StateObject private var vm: TimelineFeatureViewModel

    init(
        repo: TimelineRepository = InMemoryTimelineRepository(),
        durationMinutes: Double = 3.0,
        selectionSeconds: Int = 10
    ) {
        let get  = DefaultGetTimelineUseCase(repo: repo)
        let jump = DefaultJumpToKeyTimeUseCase() // ✅ 不再依賴 SetStart，用 Value Object 收斂
        _vm = StateObject(
            wrappedValue: TimelineFeatureViewModel(
                getTimeline: get,
                jumpUseCase: jump,
                songDurationMinutes: durationMinutes,
                selectionSeconds: selectionSeconds
            )
        )
    }

    var body: some View {
        VStack(spacing: 14) {

            // ========= Section 1: KeyTime Selection（百分比） =========
            VStack(alignment: .leading, spacing: 6) {
                Text("KeyTime Selection")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)

                // Selection: 起點% -> 終點%
                Text("Selection: \(vm.selectionPercentText)")
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundStyle(.white)

                // 第一個 Current（百分比）
                Text("Current: \(vm.currentPercentText)")
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundStyle(Color.green)

                KeyTimeSelectionView(
                    position: $vm.startPercent,
                    keyTimes: vm.timeline.keyTimes,
                    indicatorPercent: vm.startPercent,
                    title: nil // 關掉子元件內建標題，與版面一致
                )
                .frame(height: 44)
            }

            // ========= Section 2: Music Timeline（時間） =========
            VStack(alignment: .leading, spacing: 6) {
                Text("Music Timeline")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)

                // Selected: mm:ss -> mm:ss
                Text("Selected: \(vm.selectionTimeText)")
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundStyle(.white)

                // 第二個 Current（mm:ss）
                Text("Current: \(vm.currentTimeText)")
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundStyle(Color.green)

                // 波形：選取匡固定 10 秒、寬度 = 螢幕一半；整首歌總寬度依比例展開
                ScrollingWaveformTrimmer(
                    start: $vm.startPercent,
                    songDurationSeconds: vm.songDurationSeconds,
                    selectionSeconds: Double(vm.selectionSeconds),
                    progressRatioInSelection: vm.progressRatioInSelection,
                    title: nil // 關掉子元件內建標題
                )
                .frame(height: 96)
            }

            // 控制列（左 Play/Pause、右 Reset）
            HStack(spacing: 12) {
                Button(vm.isPlaying ? "Pause" : "Play") { vm.togglePlay() }
                    .buttonStyle(.borderedProminent)

                Button("Reset") { vm.reset() }
                    .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.black)
        // 使用者拖曳 → 將「欲望值」交給 VM，VM 以 StartBounds 收斂到 0...maxStart
        .onChange(of: vm.startPercent) { _, newValue in
            vm.onUserDraggedTrimmer(to: newValue)
        }
    }
}

// MARK: - Preview
#Preview {
    TimelineFeatureView(durationMinutes: 3.2, selectionSeconds: 10)
        .padding()
        .background(.black)
}
