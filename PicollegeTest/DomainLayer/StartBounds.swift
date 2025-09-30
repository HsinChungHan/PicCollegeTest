//
//  StartBounds.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//

import Foundation

/// 起點百分比的邊界/收斂規則（Value Object，純邏輯、無副作用）
/// - songSeconds: 整首歌的總秒數
/// - selectionSeconds: 固定選取窗的秒數（例如 10 秒）
struct StartBounds: Sendable {
    let songSeconds: Double
    let selectionSeconds: Double

    init(songSeconds: Double, selectionSeconds: Double) {
        self.songSeconds = max(1, songSeconds)
        self.selectionSeconds = max(0.1, selectionSeconds)
    }

    /// 選取窗占整首歌的比例（0...1）
    var selectionRatio: Double {
        min(1.0, selectionSeconds / songSeconds)
    }

    /// 起點百分比的最大值，確保選取窗右緣不會超出歌曲結尾
    var maxStart: Double {
        max(0.0, 1.0 - selectionRatio)
    }

    /// 將任意目標起點百分比收斂到合法範圍（含 0...1 以及情境上限）
    func clamp(_ target: Double) -> Double {
        let base = min(1.0, max(0.0, target))
        return min(maxStart, max(0.0, base))
    }
}
