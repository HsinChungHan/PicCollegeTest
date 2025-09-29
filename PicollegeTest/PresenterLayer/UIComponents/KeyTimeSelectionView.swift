//
//  KeyTimeSelectionView.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/29.
//

import SwiftUI

public struct KeyTimeSelectionView: View {
    @Binding public var position: Double         // 0...1 目前位置
    public var keyTimes: [Double]                // 0...1
    public var indicatorPercent: Double?         // 黃色指示 bar

    public var cornerRadius: CGFloat = 10
    public var trackHeight: CGFloat = 14
    public var dotDiameter: CGFloat = 12

    public var trackColor: Color = Color.white.opacity(0.15)
    public var trackBorder: Color = Color.black.opacity(0.35)
    public var dotColor: Color = Color.pink
    public var indicatorColor: Color = Color.yellow

    public init(position: Binding<Double>, keyTimes: [Double], indicatorPercent: Double? = nil) {
        self._position = position
        self.keyTimes = keyTimes
        self.indicatorPercent = indicatorPercent
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
                    .allowsHitTesting(false)

                // 黃色指示 bar
                if let ip = indicatorPercent {
                    let p = min(1, max(0, ip))
                    let x = p * W
                    Rectangle()
                        .fill(indicatorColor)
                        .frame(width: 3, height: trackHeight + 10)
                        .position(x: x, y: trackY)
                }

                // 粉紅點（每個可點擊）
                ForEach(Array(keyTimes.enumerated()), id: \.offset) { _, t in
                    let p = min(1, max(0, t))
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
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .frame(width: max(36, dotDiameter + 20), height: max(36, dotDiameter + 20))
                    .position(x: x, y: trackY)
                    .zIndex(2)
                }
            }
        }
        .frame(height: max(trackHeight + 20, dotDiameter + 20))
    }
}

