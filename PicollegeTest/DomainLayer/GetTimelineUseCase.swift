//
//  GetTimelineUseCase.swift
//  PicollegeTest
//
//  Created by Chung Han Hsin on 2025/9/30.
//

/*
 Responsiblity: 從 TimelineRepository讀取 Timeline，把取得時間軸這件事從 UI/VM 拆開
 Rule/Side effects: No side effects, 可替換 Timeline 資料來源（記憶體、網路、磁碟），VM 不需知道細節
 Interaction: 於 TimelineFeatureViewModel 的 refreshTimeline() 使用
 */

protocol GetTimelineUseCase {
    func execute() -> Timeline
}


final class DefaultGetTimelineUseCase: GetTimelineUseCase {
    private let repo: TimelineRepository
    
    init(repo: TimelineRepository) {
        self.repo = repo
    }
    
    func execute() -> Timeline {
        repo.fetchTimeline()
    }
}
