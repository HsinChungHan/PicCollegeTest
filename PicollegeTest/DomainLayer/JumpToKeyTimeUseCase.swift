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

protocol JumpToKeyTimeUseCase {
    func execute(currentStart: Double, targetKeyPercent: Double) -> Double
}

final class DefaultJumpToKeyTimeUseCase: JumpToKeyTimeUseCase {
    private let setStart: SetStartPercentUseCase
    init(setStart: SetStartPercentUseCase) {
        self.setStart = setStart
    }
    
    func execute(currentStart: Double, targetKeyPercent: Double) -> Double {
        // later you can add snapping or easing rules here
        setStart.execute(targetKeyPercent)
    }
}
