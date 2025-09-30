//
//  JumpToKeyTimeUseCase.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//

/*
 Responsiblity: 集中「選取框起點百分比」的基本商業規則集中：目前做 0…1 夾值（clamp）
 Rule/Side effects: No side effects, 可替換 Timeline 資料來源（記憶體、網路、磁碟），VM 不需知道細節
 Interaction: 於 TimelineFeatureViewModel 的 refreshTimeline() 使用
 */

import Foundation

protocol JumpToKeyTimeUseCase {
    /// 根據目標 key 百分比計算新的起點；實際合法範圍由 StartBounds 決定
    func execute(currentStart: Double,
                 targetKeyPercent: Double,
                 bounds: StartBounds) -> Double
}

final class DefaultJumpToKeyTimeUseCase: JumpToKeyTimeUseCase {
    init() {}

    func execute(currentStart: Double,
                        targetKeyPercent: Double,
                        bounds: StartBounds) -> Double {
        // 之後可在這裡加入 snapping / easing 策略，再交給 bounds.clamp() 收斂
        return bounds.clamp(targetKeyPercent)
    }
}
