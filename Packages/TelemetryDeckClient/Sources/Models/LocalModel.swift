import Foundation

class LocalModel: Codable, Identifiable, ObservableObject {
    let responsibleManager: DataManager
    let id: UUID
    let type: String
    let lastUpdateAt: Date
    let isDirty: Bool
    var loadingState: LoadingState
    
    static var maxAgeBeforeRefresh: TimeInterval { return 3600 }
    
    func needsPush() -> Bool {
        return isDirty
    }
    
    func needsPull() -> Bool {
        return -lastUpdateAt.timeIntervalSinceNow > maxAgeBeforeRefresh
    }
}
