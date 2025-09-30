//
//  JumpToKeyTimeUseCase.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//

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
