//
//  JumpToKeyTimeUseCase.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//

/*
 Responsiblity: 在使用者「點擊某個 key time」時，計算新的起點百分比 (startPercent)
 Rule/Side effects:
    1. 未來未來可擴充 snapping / easing 等跳轉策略，最後一律透過 StartBounds.clamp(_:) 收斂到合法範圍（含 0…1 與 右邊界 1 - selectionRatio）
    2. No side effects
 Interaction: 於 TimelineFeatureViewModel 在 call onUserTappedKeyTime 時使用 JumpToKeyTimeUseCase
 */

import Foundation

protocol JumpToKeyTimeUseCase {
    /// 根據目標 key 百分比計算新的起點；實際合法範圍由 StartBounds 決定
    func execute(currentStart: Double,
                 targetKeyPercent: Double,
                 bounds: StartBounds) -> Double
}

final class DefaultJumpToKeyTimeUseCase: JumpToKeyTimeUseCase {
    func execute(currentStart: Double,
                        targetKeyPercent: Double,
                        bounds: StartBounds) -> Double {
        // 之後可在這裡加入 snapping / easing 策略，再交給 bounds.clamp() 收斂
        return bounds.clamp(targetKeyPercent)
    }
}
