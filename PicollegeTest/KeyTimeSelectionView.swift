//
//  KeyTimeSelectionView.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/29.
//

import SwiftUI

public struct KeyTimeSelectionView: View {
    // 0...1 的目前游標/時間位置（點擊點會更新它）
    @Binding public var position: Double
    
    // 需顯示的關鍵時間點（百分比 0...1）
    public var keyTimes: [Double]
    
    // 可選：選取區段（0...1），例如 0.40...0.52 會畫成黃色
    public var selection: ClosedRange<Double>?
    
    // 外觀可調
    public var cornerRadius: CGFloat = 10
    public var trackHeight: CGFloat = 14
    public var dotDiameter: CGFloat = 12
    
    public var trackColor: Color = Color.white.opacity(0.15)
    public var trackBorder: Color = Color.black.opacity(0.35)
    public var dotColor: Color = Color.pink
    public var selectionColor: Color = Color.yellow
    
    public init(position: Binding<Double>,
                keyTimes: [Double],
                selection: ClosedRange<Double>? = nil) {
        self._position = position
        self.keyTimes = keyTimes
        self.selection = selection
    }
    
    public var body: some View {
        GeometryReader { geo in
            let W = max(geo.size.width, 1)
            let H = geo.size.height
            let trackY = H / 2
            
            ZStack {
                // 背景軌道
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(trackColor)
                    .frame(height: trackHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(trackBorder, lineWidth: 1)
                    )
                    .position(x: W/2, y: trackY)
                    .allowsHitTesting(false) // 軌道不吃事件
                
//                // 選取黃色區段（可選）
//                if let sel = selection {
//                    let clamped = ClosedRange(uncheckedBounds:
//                        (lower: max(0, min(1, sel.lowerBound)),
//                         upper: max(0, min(1, sel.upperBound)))
//                    )
//                    let leftX  = clamped.lowerBound * W
//                    let rightX = clamped.upperBound * W
//                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
//                        .fill(selectionColor)
//                        .frame(width: max(0, rightX - leftX), height: trackHeight - 4)
//                        .position(x: (leftX + rightX) / 2, y: trackY)
//                        .allowsHitTesting(false) // 黃色區段不吃事件
//                }
                
                // 粉紅點（改成 Button，每個都能點擊）
                ForEach(Array(keyTimes.enumerated()), id: \.offset) { _, t in
                    let p = max(0, min(1, t))
                    let x = p * W
                    
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                            position = p
                        }
                        print(String(format: "KeyTime tapped: %.3f (%.0f%%)", p, p * 100))
                    } label: {
                        Circle()
                            .fill(dotColor)
                            .frame(width: dotDiameter, height: dotDiameter)
                    }
                    .buttonStyle(.plain)
                    .position(x: x, y: trackY)              // 放在對應座標
                    .zIndex(2)
                    .accessibilityLabel("Key time")
                    .accessibilityValue("\(Int(p*100))%")
                    .accessibilityAddTraits(.isButton)
                }

            }
        }
        .frame(height: max(trackHeight + 20, dotDiameter + 20))
    }
}

// MARK: - Preview
#Preview {
    StatefulPreview()
        .padding()
        .background(Color.black)
}

private struct StatefulPreview: View {
    @State private var position: Double = 0.35
    private let keyTimes: [Double] = [0.1, 0.3, 0.45, 0.65, 0.85]
    
    var body: some View {
        VStack(spacing: 20) {
            KeyTimeSelectionView(position: $position,
                                 keyTimes: keyTimes,
                                 selection: 0.38...0.50)
                .frame(height: 40)
                .padding(.horizontal, 16)
                .background(Color.black.opacity(0.9))
            
            Text(String(format: "position = %.2f (%.0f%%)", position, position * 100))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
    }
}
