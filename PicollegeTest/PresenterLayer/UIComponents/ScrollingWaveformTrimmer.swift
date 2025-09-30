//
//  ScrollingWaveformTrimmer.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/29.
//
import SwiftUI

/// 選取匡固定 10 秒 & 寬度固定為螢幕的一半；
/// 波型總長 = (歌曲總秒數 / 10) * (選取匡寬度)
/// - `start`: 0...1，整首歌的正規化起點
/// - `progressRatioInSelection`: 0...1，(已播秒數 / 10 秒)，控制匡內「綠色背景」填充
struct ScrollingWaveformTrimmer: View {
    @Binding var start: Double

    var songDurationSeconds: Double
    var selectionSeconds: Double = 10
    var progressRatioInSelection: Double = 0

    // 標題與總長（新增）
    var title: String? = "Music Timeline"
    var titleColor: Color = .white.opacity(0.9)
    var totalDurationLabelColor: Color = .white.opacity(0.7)

    // 外觀
    var cornerRadius: CGFloat = 16
    var backgroundColor: Color = Color.black.opacity(0.95)
    var baseBarColor: Color = Color.white.opacity(0.65)
    var selectionBaseFill: Color = Color.white.opacity(0.08)
    var selectionBorderGradient: [Color] = [.orange, .purple]
    var progressFillColor: Color = Color.green.opacity(0.85)

    @GestureState private var dragDX: CGFloat = 0

    init(start: Binding<Double>,
                songDurationSeconds: Double,
                selectionSeconds: Double = 10,
                progressRatioInSelection: Double = 0,
                title: String? = "Music Timeline") {
        self._start = start
        self.songDurationSeconds = max(1, songDurationSeconds)
        self.selectionSeconds = max(0.1, selectionSeconds)
        self.progressRatioInSelection = min(1, max(0, progressRatioInSelection))
        self.title = title
    }

    var body: some View {
        VStack(spacing: 6) {
            // 標題列：左標題、右歌曲總時長
            HStack {
                if let title {
                    Text(title)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(titleColor)
                }
                Spacer()
                Text(totalDurationText(seconds: songDurationSeconds))
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundStyle(totalDurationLabelColor)
            }

            GeometryReader { geo in
                let W = max(geo.size.width, 1)
                let H = geo.size.height

                // 選取匡寬度固定為螢幕一半
                let selectionWidth = W / 2
                let selLeftX  = (W - selectionWidth) / 2
                let selRightX = selLeftX + selectionWidth

                // 依「10 秒 = selectionWidth」計算整首歌波型總寬度
                let waveformTotalWidth = (songDurationSeconds / selectionSeconds) * selectionWidth

                // 讓 start（0...1）對應到 pixel 偏移，對齊到選取匡左緣
                let baseOffsetX = selLeftX - CGFloat(start) * waveformTotalWidth

                // 波形參數
                let barSpacing: CGFloat = 3
                let barWidth: CGFloat = 3
                let totalBars = max(8, Int((waveformTotalWidth - 20) / (barWidth + barSpacing)))

                // 綠色背景進度寬度（匡內）
                let progressWidth = CGFloat(progressRatioInSelection) * selectionWidth

                ZStack {
                    // 背板
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(backgroundColor)

                    // 選取匡背景 + 綠色進度（限制在匡內）
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(selectionBaseFill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        Rectangle()
                            .fill(progressFillColor)
                            .frame(width: progressWidth)
                    }
                    .frame(width: selectionWidth, height: H - 18)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .position(x: (selLeftX + selRightX) / 2, y: H / 2)

                    // 灰白波形（代表整首歌）
                    waveform(totalBars: totalBars,
                             barWidth: barWidth,
                             barSpacing: barSpacing,
                             height: H,
                             color: baseBarColor)
                        .frame(width: waveformTotalWidth, height: H, alignment: .leading)
                        .offset(x: baseOffsetX + dragDX)
                        .clipped()

                    // 選取匡邊框與把手（最上層）
                    selectionWindowFrame(width: W, height: H, selWidth: selectionWidth)
                }
                // 拖曳 → 反推回 start（0...1）
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .updating($dragDX) { value, state, _ in
                            state = value.translation.width
                        }
                        .onEnded { value in
                            let newOffsetX = baseOffsetX + value.translation.width
                            // baseOffsetX = selLeftX - start*waveformTotalWidth → 求 start
                            let t = (selLeftX - newOffsetX) / waveformTotalWidth

                            // ✅ 最大起點 = 1 - (選取秒數 / 總秒數)
                            let selRatio  = selectionSeconds / songDurationSeconds
                            let maxStart  = max(0.0, 1.0 - selRatio)

                            start = min(maxStart, max(0, Double(t)))
                        }
                )
            }
            .frame(height: 96) // 內部波形區高度
        }
    }

    // MARK: - 視覺：選取匡框與把手
    private func selectionWindowFrame(width: CGFloat, height: CGFloat, selWidth: CGFloat) -> some View {
        let rect = RoundedRectangle(cornerRadius: 10, style: .continuous)
        return rect
            .strokeBorder(
                LinearGradient(colors: selectionBorderGradient,
                               startPoint: .leading, endPoint: .trailing),
                lineWidth: 3
            )
            .frame(width: selWidth, height: height - 18)
            .overlay(
                HStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white)
                        .frame(width: 8)
                        .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.black.opacity(0.2), lineWidth: 1))
                        .padding(.vertical, 8)
                    Spacer()
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white)
                        .frame(width: 8)
                        .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.black.opacity(0.2), lineWidth: 1))
                        .padding(.vertical, 8)
                }
                .padding(.horizontal, 6)
            )
            .position(x: width / 2, y: height / 2)
    }

    // MARK: - 波形
    private func waveform(totalBars: Int,
                          barWidth: CGFloat,
                          barSpacing: CGFloat,
                          height: CGFloat,
                          color: Color) -> some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<totalBars, id: \.self) { i in
                let seed = Double((i * 137) % 100) / 100.0
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: barWidth, height: CGFloat(10 + (height - 26) * seed))
                    .opacity(0.95)
            }
        }
        .padding(.horizontal, 10)
    }

    // MARK: - Helper
    private func totalDurationText(seconds: Double) -> String {
        let s = max(0, Int(seconds.rounded()))
        let m = s / 60, r = s % 60
        return String(format: "Total Duration: %d:%02d", m, r)
    }
}
