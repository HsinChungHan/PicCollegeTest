//
//  JumpToKeyTimeUseCase.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//

public protocol JumpToKeyTimeUseCase {
    func execute(currentStart: Double, targetKeyPercent: Double) -> Double
}

public final class DefaultJumpToKeyTimeUseCase: JumpToKeyTimeUseCase {
    private let setStart: SetStartPercentUseCase
    public init(setStart: SetStartPercentUseCase) {
        self.setStart = setStart
    }
    
    public func execute(currentStart: Double, targetKeyPercent: Double) -> Double {
        // later you can add snapping or easing rules here
        setStart.execute(targetKeyPercent)
    }
}
