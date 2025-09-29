//
//  WaveformTrimmerView.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/29.
//
import SwiftUI
/*
 幫我新增兩個按鈕 play 和 reset
 1. play 按下後，文案會變為 pause，且會從 ScrollingWaveformTrimmer 選取匡的起點開始填充綠色，以每一秒填充一個 bar 的速度，直到選取匡的終點，便不會再往右填充綠色，同時 pause 會變為 play button
 2.  pause button 點擊後，便會暫停填充綠色，並轉換為 play button，再按一次 play button，會接續之前的進度繼續填充，直到選取匡的終點
 3. reset button 按下後，一率變為 play button，並清除所有的綠色填充。若再按 play button 會再從 選取匡的起點開始填充
 幫我用 MVVM + Clean Architecture 的方式實作
 */

public struct ScrollingWaveformTrimmer: View {
    @Binding var start: Double                   // 0...1, selection window start
    public var cornerRadius: CGFloat = 16
    public var backgroundColor: Color = Color.black.opacity(0.95)
    public var barColor: Color = Color.white.opacity(0.65)
    public var selectionFill: Color = Color.white.opacity(0.14)

    @GestureState private var dragDX: CGFloat = 0

    public init(start: Binding<Double>) {
        self._start = start
    }

    public var body: some View {
        GeometryReader { geo in
            let W = max(geo.size.width, 1)
            let H = geo.size.height

            let leftEdgeX  = W * 0.25   // 選取匡左緣
            // let rightEdgeX = W * 0.75 // 選取匡右緣（目前僅需起點）

            // 將 start 線性映射到 offsetX，使起點對齊選取匡左緣
            let baseOffsetX = leftEdgeX - start * (W / 2)

            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)

                waveform(width: W, height: H)
                    .frame(width: W, height: H)
                    .offset(x: baseOffsetX + dragDX)
                    .clipped()

                selectionWindow(width: W, height: H)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($dragDX) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let newOffsetX = baseOffsetX + value.translation.width
                        // offsetX = leftEdgeX - start*(W/2)
                        let t = (leftEdgeX - newOffsetX) / (W / 2)
                        start = min(1, max(0, t))
                    }
            )
        }
        .frame(minHeight: 64)
    }

    // MARK: - 選取窗 (固定一半寬，置中)
    private func selectionWindow(width: CGFloat, height: CGFloat) -> some View {
        let selW = width / 2
        let rect = RoundedRectangle(cornerRadius: 10, style: .continuous)
        return rect
            .fill(selectionFill)
            .frame(width: selW, height: height - 18)
            .overlay(
                rect.strokeBorder(
                    LinearGradient(colors: [.orange, .purple],
                                   startPoint: .leading, endPoint: .trailing),
                    lineWidth: 3
                )
            )
            .overlay(
                HStack {
                    handle
                    Spacer()
                    handle
                }
                .padding(.horizontal, 6)
            )
            .accessibilityLabel("Selection window")
    }

    private var handle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.white)
            .frame(width: 8)
            .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.black.opacity(0.2), lineWidth: 1))
            .padding(.vertical, 8)
    }

    // MARK: - 假波形
    private func waveform(width: CGFloat, height: CGFloat) -> some View {
        let barSpacing: CGFloat = 3
        let barWidth: CGFloat = 3
        let count = Int(max(8, (width - 20) / (barWidth + barSpacing)))
        return HStack(spacing: barSpacing) {
            ForEach(0..<count, id: \.self) { i in
                let seed = Double((i * 137) % 100) / 100.0
                RoundedRectangle(cornerRadius: 2)
                    .fill(barColor)
                    .frame(width: barWidth, height: CGFloat(10 + (height - 26) * seed))
                    .opacity(0.85)
            }
        }
    }
}
