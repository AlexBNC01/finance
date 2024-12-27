// код с изменениями в периодах рабочий №1

import Foundation

struct Income: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let description: String
    let date: Date
    let accountID: UUID // Поле accountID добавлено

    init(id: UUID = UUID(), amount: Double, description: String, date: Date, accountID: UUID) {
        self.id = id
        self.amount = amount
        self.description = description
        self.date = date
        self.accountID = accountID
    }
}
