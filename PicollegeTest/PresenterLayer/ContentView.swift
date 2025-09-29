//
//  ContentView.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/29.
//

import SwiftUI

struct ContentView: View {
    @State private var position: Double = 0.35
    private let keyTimes: [Double] = [0.1, 0.3, 0.45, 0.65, 0.85]
    
    var body: some View {
        VStack(spacing: 20) {
            TimelineFeatureView()
        }.background(.black)
    }
}

#Preview {
    ContentView()
}
