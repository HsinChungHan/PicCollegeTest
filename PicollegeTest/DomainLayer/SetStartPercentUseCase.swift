//
//  SetStartPercentUseCase.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//

public protocol SetStartPercentUseCase {
    func execute(_ percent: Double) -> Double
}


public final class DefaultSetStartPercentUseCase: SetStartPercentUseCase {
    public func execute(_ percent: Double) -> Double {
        // business rules (clamp 0...1, rounding if needed)
        min(1, max(0, percent))
    }
}
