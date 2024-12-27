import Foundation

struct Account: Identifiable, Codable {
    let id: UUID
    var name: String
    var balance: Double
    var isIncludedInAnalytics: Bool // Новое свойство для учета в аналитике

    init(id: UUID = UUID(), name: String, balance: Double = 0.0, isIncludedInAnalytics: Bool = true) {
        self.id = id
        self.name = name
        self.balance = balance
        self.isIncludedInAnalytics = isIncludedInAnalytics
    }
}
