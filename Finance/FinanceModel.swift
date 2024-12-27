import Foundation
import SwiftUI

// MARK: - Расширение для работы с Color
extension Color {
    init(hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var cleanedHexString = hexString

        // Убираем символ '#' если он присутствует
        if cleanedHexString.hasPrefix("#") {
            cleanedHexString.removeFirst()
        }

        // Убедимся, что строка имеет длину 6 символов
        guard cleanedHexString.count == 6,
              let rgbValue = UInt32(cleanedHexString, radix: 16) else {
            // Если строка некорректна, устанавливаем серый цвет по умолчанию
            self.init(red: 128/255, green: 128/255, blue: 128/255)
            return
        }

        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components, components.count >= 3 else {
            return "#808080" // Серый по умолчанию
        }
        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255))
    }
}

class FinanceModel: ObservableObject {
    // MARK: - Публикуемые свойства
    @Published var accounts: [Account] = [] {
        didSet {
            saveAccounts()
        }
    }

    @Published var incomes: [Income] = [] {
        didSet {
            saveIncomes()
        }
    }

    @Published var expenses: [Expense] = [] {
        didSet {
            saveExpenses()
        }
    }

    @Published var categories: [String] = [] {
        didSet {
            saveCategories()
        }
    }

    @Published var categoryColors: [String: Color] = [:] {
        didSet {
            saveCategoryColors()
        }
    }

    // MARK: - Константы для файлов
    private let accountsFileName = "accounts.json"
    private let incomesFileName = "incomes.json"
    private let expensesFileName = "expenses.json"
    private let categoriesFileName = "categories.json"
    private let categoryColorsFileName = "categoryColors.json"

    // MARK: - Предопределённые категории
    private let defaultCategories = [
        "Продукты питания",
        "Кафе и рестораны",
        "Транспорт",
        "Жильё",
        "Одежда и обувь",
        "Медицина",
        "Образование",
        "Развлечения и досуг",
        "Путешествия",
        "Подарки и благотворительность",
        "Кредиты и долги",
        "Семья и дети",
        "Бытовые расходы",
        "Связь и интернет",
        "Прочее"
    ]

    // MARK: - Палитра предопределённых красивых цветов
    private let defaultColorPalette: [Color] = [
        .red,
        .orange,
        .yellow,
        .green,
        .blue,
        .indigo,
        .purple,
        .pink,
        .teal,
        .brown,
        .cyan,
        .mint,
        Color(red: 1, green: 0, blue: 1), // magenta
        .gray,
        .black
    ]

    // MARK: - Инициализатор
    init() {
        loadAccounts()
        loadIncomes()
        loadExpenses()
        loadCategories()
        loadCategoryColors()

        // Инициализация аккаунтов по умолчанию, если они отсутствуют
        if accounts.isEmpty {
            accounts = [
                Account(name: "Свой счёт"),
                Account(name: "Семейный счёт"),
                Account(name: "Рабочий счёт")
            ]
        }

        // Инициализация категорий по умолчанию, если они отсутствуют
        if categories.isEmpty {
            categories = defaultCategories
        }

        // Назначение предопределённых цветов категориям
        assignDefaultColors()
    }

    // MARK: - Назначение предопределённых цветов категориям
    private func assignDefaultColors() {
        // Индекс для отслеживания текущего цвета в палитре
        var colorIndex = 0

        for category in categories {
            if categoryColors[category] == nil {
                // Назначаем цвет из палитры, циклически если необходимо
                let color = defaultColorPalette[colorIndex % defaultColorPalette.count]
                categoryColors[category] = color
                colorIndex += 1
            }
        }

        // Сохраняем назначенные цвета
        saveCategoryColors()
    }

    // MARK: - Методы управления цветами категорий
    func getCategoryColor(for category: String) -> Color {
        let color = categoryColors[category] ?? .gray
        return color
    }

    func setCategoryColor(for category: String, color: Color) {
        categoryColors[category] = color
        saveCategoryColors()
    }

    // MARK: - Сохранение и загрузка данных
    private func saveCategoryColors() {
        // Преобразуем цвета в шестнадцатеричные строки
        let encodedColors = categoryColors.mapValues { $0.toHex() }
        guard let data = try? JSONEncoder().encode(encodedColors) else {
            print("Ошибка кодирования categoryColors")
            return
        }
        saveToFile(data: data, fileName: categoryColorsFileName)
    }

    private func loadCategoryColors() {
        guard let data = loadFromFile(fileName: categoryColorsFileName),
              let decoded = try? JSONDecoder().decode([String: String].self, from: data) else {
            // Если не удалось загрузить, назначаем цвета по умолчанию
            assignDefaultColors()
            return
        }
        // Преобразуем загруженные строки в цвета
        categoryColors = decoded.mapValues { Color(hex: $0) }

        // Назначаем предопределённые цвета новым категориям, если они были добавлены после последнего сохранения
        assignDefaultColors()
    }

    private func saveAccounts() {
        guard let data = try? JSONEncoder().encode(accounts) else { return }
        saveToFile(data: data, fileName: accountsFileName)
    }

    private func loadAccounts() {
        guard let data = loadFromFile(fileName: accountsFileName),
              let decodedAccounts = try? JSONDecoder().decode([Account].self, from: data) else { return }
        accounts = decodedAccounts
    }

    private func saveIncomes() {
        guard let data = try? JSONEncoder().encode(incomes) else { return }
        saveToFile(data: data, fileName: incomesFileName)
    }

    private func loadIncomes() {
        guard let data = loadFromFile(fileName: incomesFileName),
              let decodedIncomes = try? JSONDecoder().decode([Income].self, from: data) else { return }
        incomes = decodedIncomes
    }

    private func saveExpenses() {
        guard let data = try? JSONEncoder().encode(expenses) else { return }
        saveToFile(data: data, fileName: expensesFileName)
    }

    private func loadExpenses() {
        guard let data = loadFromFile(fileName: expensesFileName),
              let decodedExpenses = try? JSONDecoder().decode([Expense].self, from: data) else { return }
        expenses = decodedExpenses
    }

    func saveCategories() {
        guard let data = try? JSONEncoder().encode(categories) else { return }
        saveToFile(data: data, fileName: categoriesFileName)
    }

    private func loadCategories() {
        guard let data = loadFromFile(fileName: categoriesFileName),
              let decodedCategories = try? JSONDecoder().decode([String].self, from: data) else { return }
        categories = decodedCategories
    }

    private func saveToFile(data: Data, fileName: String) {
        guard let url = getFileURL(fileName: fileName) else {
            print("Ошибка: URL для файла \(fileName) не найден")
            return
        }
        do {
            try data.write(to: url)
        } catch {
            print("Ошибка записи файла \(fileName): \(error)")
        }
    }

    private func loadFromFile(fileName: String) -> Data? {
        guard let url = getFileURL(fileName: fileName) else { return nil }
        return try? Data(contentsOf: url)
    }

    private func getFileURL(fileName: String) -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName)
    }

    // MARK: - Методы управления расходами
    func addExpense(amount: Double, wallet: String, category: String, details: String, date: Date, from accountID: UUID) {
        guard let index = accounts.firstIndex(where: { $0.id == accountID }) else { return }
        accounts[index].balance -= amount
        let newExpense = Expense(
            amount: amount,
            wallet: wallet,
            category: category,
            details: details,
            date: date,
            accountID: accountID
        )
        expenses.insert(newExpense, at: 0)
        saveExpenses()
        saveAccounts()
    }

    func addIncome(amount: Double, description: String, date: Date, to accountID: UUID) {
        guard let index = accounts.firstIndex(where: { $0.id == accountID }) else { return }
        accounts[index].balance += amount
        let newIncome = Income(amount: amount, description: description, date: date, accountID: accountID)
        incomes.insert(newIncome, at: 0)
        saveIncomes()
        saveAccounts()
    }

    func addCategory(_ category: String) {
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedCategory.isEmpty && !categories.contains(trimmedCategory) {
            categories.append(trimmedCategory)

            // Назначаем цвет из палитры, циклически если необходимо
            let assignedColor = defaultColorPalette[categoryColors.count % defaultColorPalette.count]
            categoryColors[trimmedCategory] = assignedColor

            saveCategoryColors()
        }
    }

    func deleteCategory(at offsets: IndexSet) {
        let removedCategories = offsets.map { categories[$0] }
        for category in removedCategories {
            categoryColors.removeValue(forKey: category)
        }
        categories.remove(atOffsets: offsets)
        saveCategoryColors()
    }

    // MARK: - Методы для работы с аналитикой

    // Метод для получения суммарного баланса включенных счетов
    func totalBalance() -> Double {
        accounts.filter { $0.isIncludedInAnalytics }.reduce(0) { $0 + $1.balance }
    }

    // Метод для получения данных для аналитики
    func analyticsData() -> [String: Double] {
        var data: [String: Double] = [:]
        for account in accounts where account.isIncludedInAnalytics {
            data[account.name] = account.balance
        }
        return data
    }
}
