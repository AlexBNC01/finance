// код с изменениями в периодах рабочий №1

import Foundation

struct Expense: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let wallet: String
    let category: String
    let details: String
    let date: Date
    let accountID: UUID // Поле accountID добавлено

    init(id: UUID = UUID(), amount: Double, wallet: String, category: String, details: String, date: Date, accountID: UUID) {
        self.id = id
        self.amount = amount
        self.wallet = wallet
        self.category = category
        self.details = details
        self.date = date
        self.accountID = accountID
    }
}
