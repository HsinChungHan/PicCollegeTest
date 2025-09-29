//
//  WaveformTrimmerView.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/29.
//
import SwiftUI

public struct ScrollingWaveformTrimmer: View {
    @Binding var start: Double

    public var cornerRadius: CGFloat = 16
    public var backgroundColor: Color = Color.black.opacity(0.95)
    public var baseBarColor: Color = Color.white.opacity(0.65)
    public var selectionBaseFill: Color = Color.white.opacity(0.08)
    public var selectionBorderGradient: [Color] = [.orange, .purple]
    public var progressFillColor: Color = Color.green.opacity(0.85)

    public var barsInSelection: Int = 0
    public var filledCountInSelection: Int = 0
    public var onBarsInSelectionResolved: ((Int) -> Void)? = nil

    @GestureState private var dragDX: CGFloat = 0

    public init(start: Binding<Double>,
                barsInSelection: Int = 0,
                filledCountInSelection: Int = 0,
                onBarsInSelectionResolved: ((Int) -> Void)? = nil) {
        self._start = start
        self.barsInSelection = barsInSelection
        self.filledCountInSelection = filledCountInSelection
        self.onBarsInSelectionResolved = onBarsInSelectionResolved
    }

    public var body: some View {
        GeometryReader { geo in
            let W = max(geo.size.width, 1)
            let H = geo.size.height

            let selLeftX  = W * 0.25
            let selRightX = W * 0.75
            let selWidth  = selRightX - selLeftX

            let baseOffsetX = selLeftX - start * (W / 2)

            let barSpacing: CGFloat = 3
            let barWidth: CGFloat = 3
            let totalBars = totalBarsFor(width: W, barWidth: barWidth, spacing: barSpacing)
            let selectionBars = max(1, totalBars / 2)

            let progressRatio = min(1.0, Double(filledCountInSelection) / Double(max(selectionBars, 1)))
            let progressWidth = CGFloat(progressRatio) * selWidth

            ZStack {
                // 背板
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)

                // ========= 選取匡底層（容器）+ 綠色背景進度 =========
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(selectionBaseFill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Rectangle()
                        .fill(progressFillColor)
                        .frame(width: progressWidth)
                }
                .frame(width: selWidth, height: H - 18)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .position(x: (selLeftX + selRightX) / 2, y: H / 2)

                // ========= 波形（完整灰白，疊在綠色背景上方） =========
                waveform(totalBars: totalBars,
                         barWidth: barWidth,
                         barSpacing: barSpacing,
                         height: H,
                         color: baseBarColor)
                    .frame(width: W, height: H)
                    .offset(x: baseOffsetX + dragDX)
                    .clipped()

                // ========= 選取匡邊框與把手（最上層） =========
                selectionWindowFrame(width: W, height: H)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($dragDX) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let newOffsetX = baseOffsetX + value.translation.width
                        let t = (selLeftX - newOffsetX) / (W / 2)
                        start = min(1, max(0, t))
                    }
            )
            .onAppear { onBarsInSelectionResolved?(selectionBars) }
            .onChange(of: geo.size.width) { _, _ in
                let updatedTotal = totalBarsFor(width: W, barWidth: barWidth, spacing: barSpacing)
                onBarsInSelectionResolved?(max(1, updatedTotal / 2))
            }
        }
        .frame(minHeight: 64)
    }

    private func selectionWindowFrame(width: CGFloat, height: CGFloat) -> some View {
        let selW = width / 2
        let rect = RoundedRectangle(cornerRadius: 10, style: .continuous)
        return rect
            .strokeBorder(
                LinearGradient(colors: selectionBorderGradient,
                               startPoint: .leading, endPoint: .trailing),
                lineWidth: 3
            )
            .frame(width: selW, height: height - 18)
            .overlay(
                HStack {
                    handle
                    Spacer()
                    handle
                }
                .padding(.horizontal, 6)
            )
            .position(x: width / 2, y: height / 2)
    }

    private var handle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.white)
            .frame(width: 8)
            .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.black.opacity(0.2), lineWidth: 1))
            .padding(.vertical, 8)
    }

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

    private func totalBarsFor(width: CGFloat, barWidth: CGFloat, spacing: CGFloat) -> Int {
        let content = max(8, (width - 20) / (barWidth + spacing))
        return Int(content)
    }
}
