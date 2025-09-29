//
//  ContentView.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/29.
//

import SwiftUI

struct ContentView: View {
    //    @State var start: Double = 0.8
    //    var body: some View {
    //        VStack {
    //
    //            ScrollingWaveformTrimmer(start: $start)
    //                .frame(height: 90)
    //        }
    //        .padding()
    //    }
    
    @State private var position: Double = 0.35
    private let keyTimes: [Double] = [0.1, 0.3, 0.45, 0.65, 0.85]
    
    var body: some View {
        VStack(spacing: 20) {
            KeyTimeSelectionView(position: $position,
                                 keyTimes: keyTimes,
                                 selection: 0.38...0.50) // 可選：黃色區間
            .frame(height: 40)
            .padding(.horizontal, 16)
            .background(Color.black.opacity(0.9))
            
            Text(String(format: "position = %.2f (%.0f%%)", position, position * 100))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
    }
}

#Preview {
    ContentView()
}
