//
//  WaveformTrimmerView.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/29.
//
import SwiftUI

public struct ScrollingWaveformTrimmer: View {
    @Binding var start: Double                   // 0...1
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
            let rightEdgeX = W * 0.75   // 選取匡右緣
            
            // 基本 offsetX：把 start 線性映射到 [+W/4, -W/4]
            // start=0 → +W/4 (左邊對齊)，start=1 → -W/4 (右邊對齊)
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

// MARK: - Preview
#Preview {
    StatefulPreview()
        .padding()
        .background(Color.black)
}

private struct StatefulPreview: View {
    @State var start: Double = 0.0
    var body: some View {
        VStack(spacing: 20) {
            ScrollingWaveformTrimmer(start: $start)
                .frame(width: 320, height: 90)
            Text(String(format: "start=%.3f", start))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
    }
}
