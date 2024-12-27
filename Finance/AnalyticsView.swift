import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var financeModel: FinanceModel
    @State private var selectedTab: AnalyticsTab = .individual
    @State private var selectedAccountID: UUID?
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate: Date = Date()

    enum AnalyticsTab: String, CaseIterable {
        case individual = "По счетам"
        case allAccounts = "Все счета"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Переключатель вкладок аналитики
                    Picker("Аналитика", selection: $selectedTab) {
                        ForEach(AnalyticsTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Выбор периода
                    periodSelectionView

                    // Контент вкладок
                    if selectedTab == .individual {
                        individualAnalyticsView
                    } else {
                        allAccountsAnalyticsView
                    }

                    Spacer(minLength: 16)
                }
                .padding(.top, 16)
                .padding(.bottom, 32)
                .onAppear {
                    if selectedAccountID == nil, let firstAccount = financeModel.accounts.first {
                        selectedAccountID = firstAccount.id
                    }
                }
                .onReceive(financeModel.$expenses) { _ in
                    // Обновляем представление при изменении расходов
                }
            }
            .navigationTitle("Аналитика")
        }
    }

    // Выбор периода в одну строку
    private var periodSelectionView: some View {
        HStack {
            Spacer()
            DatePicker("", selection: $startDate, displayedComponents: .date)
                .labelsHidden()
            Text("–")
                .font(.headline)
                .foregroundColor(.secondary)
            DatePicker("", selection: $endDate, displayedComponents: .date)
                .labelsHidden()
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    // Вычисляемые свойства для аналитики
    private var individualAnalytics: [(category: String, amount: Double, percentage: Double)] {
        guard let accountID = selectedAccountID else { return [] }
        return calculateAnalytics(for: accountID)
    }

    private var allAccountsAnalytics: [(category: String, amount: Double, percentage: Double)] {
        return calculateAnalyticsForAllAccounts()
    }

    // Вкладка "По счетам"
    private var individualAnalyticsView: some View {
        VStack(spacing: 16) {
            if !financeModel.accounts.isEmpty {
                Picker("Выберите счёт", selection: $selectedAccountID) {
                    ForEach(financeModel.accounts) { account in
                        Text(account.name).tag(account.id as UUID?)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                if let accountID = selectedAccountID {
                    if let account = financeModel.accounts.first(where: { $0.id == accountID }) {
                        Text("Баланс счёта \(account.name): \(account.balance, specifier: "%.2f") ₽")
                            .font(.headline)
                            .padding(.top)

                        if !individualAnalytics.isEmpty {
                            VStack(alignment: .center, spacing: 16) {
                                PieChartView(data: analyticsData(from: individualAnalytics))
                                    .id(UUID())
                                    .frame(height: 250)
                                    .padding(.horizontal)
                                legend(for: individualAnalytics)

                                // Суммы доходов и расходов
                                let totalIncome = calculateTotalIncome(for: accountID)
                                let totalExpense = calculateTotalExpense(for: accountID)

                                VStack(spacing: 10) {
                                    Text("Общие доходы: \(totalIncome, specifier: "%.2f") ₽")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                    Text("Общие расходы: \(totalExpense, specifier: "%.2f") ₽")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                }
                                .padding(.top)
                            }
                            .padding(.horizontal)
                        } else {
                            Text("Нет данных для отображения расходов")
                                .foregroundColor(.gray)
                        }
                    }
                }
            } else {
                Text("Нет доступных счетов")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }

    // Вкладка "Все счета"
    private var allAccountsAnalyticsView: some View {
        VStack(spacing: 16) {
            Text("Общий баланс по всем счетам: \(financeModel.totalBalance(), specifier: "%.2f") ₽")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal)

            if !allAccountsAnalytics.isEmpty {
                VStack(alignment: .center, spacing: 16) {
                    PieChartView(data: analyticsData(from: allAccountsAnalytics))
                        .id(UUID())
                        .frame(height: 250)
                        .padding(.horizontal)
                    legend(for: allAccountsAnalytics)

                    // Общие доходы и расходы
                    let totalIncome = calculateTotalIncomeForAllAccounts()
                    let totalExpense = calculateTotalExpenseForAllAccounts()

                    VStack(spacing: 10) {
                        Text("Общие доходы: \(totalIncome, specifier: "%.2f") ₽")
                            .font(.headline)
                            .foregroundColor(.green)
                        Text("Общие расходы: \(totalExpense, specifier: "%.2f") ₽")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    .padding(.top)
                }
                .padding(.horizontal)
            } else {
                Text("Нет данных для отображения расходов")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
        }
    }

    // Преобразование аналитики в данные для диаграммы
    private func analyticsData(from analytics: [(category: String, amount: Double, percentage: Double)]) -> [String: Double] {
        var data: [String: Double] = [:]
        for item in analytics {
            data[item.category] = item.amount
        }
        return data
    }

    // Расчёты с учётом нормализации дат
    private func calculateAnalytics(for accountID: UUID) -> [(category: String, amount: Double, percentage: Double)] {
        let normalizedStartDate = Calendar.current.startOfDay(for: startDate)
        let normalizedEndDate = Calendar.current.startOfDay(for: endDate).addingTimeInterval(86399)

        let filteredExpenses = financeModel.expenses.filter {
            $0.accountID == accountID &&
            $0.date >= normalizedStartDate &&
            $0.date <= normalizedEndDate
        }
        let totalExpenses = filteredExpenses.reduce(0) { $0 + $1.amount }

        var categoryTotals: [String: Double] = [:]
        for expense in filteredExpenses {
            categoryTotals[expense.category, default: 0] += expense.amount
        }

        return categoryTotals.map { (category, amount) in
            let percentage = (amount / totalExpenses * 100)
            return (category: category, amount: amount, percentage: percentage)
        }
        .sorted { $0.amount > $1.amount }
    }

    private func calculateAnalyticsForAllAccounts() -> [(category: String, amount: Double, percentage: Double)] {
        let normalizedStartDate = Calendar.current.startOfDay(for: startDate)
        let normalizedEndDate = Calendar.current.startOfDay(for: endDate).addingTimeInterval(86399)

        let includedAccountIDs = financeModel.accounts.filter { $0.isIncludedInAnalytics }.map { $0.id }
        let filteredExpenses = financeModel.expenses.filter {
            includedAccountIDs.contains($0.accountID) &&
            $0.date >= normalizedStartDate &&
            $0.date <= normalizedEndDate
        }
        let totalExpenses = filteredExpenses.reduce(0) { $0 + $1.amount }

        var categoryTotals: [String: Double] = [:]
        for expense in filteredExpenses {
            categoryTotals[expense.category, default: 0] += expense.amount
        }

        return categoryTotals.map { (category, amount) in
            let percentage = (amount / totalExpenses * 100)
            return (category: category, amount: amount, percentage: percentage)
        }
        .sorted { $0.amount > $1.amount }
    }

    private func calculateTotalIncome(for accountID: UUID) -> Double {
        let normalizedStartDate = Calendar.current.startOfDay(for: startDate)
        let normalizedEndDate = Calendar.current.startOfDay(for: endDate).addingTimeInterval(86399)

        return financeModel.incomes
            .filter {
                $0.accountID == accountID &&
                $0.date >= normalizedStartDate &&
                $0.date <= normalizedEndDate
            }
            .reduce(0) { $0 + $1.amount }
    }

    private func calculateTotalExpense(for accountID: UUID) -> Double {
        let normalizedStartDate = Calendar.current.startOfDay(for: startDate)
        let normalizedEndDate = Calendar.current.startOfDay(for: endDate).addingTimeInterval(86399)

        return financeModel.expenses
            .filter {
                $0.accountID == accountID &&
                $0.date >= normalizedStartDate &&
                $0.date <= normalizedEndDate
            }
            .reduce(0) { $0 + $1.amount }
    }

    private func calculateTotalIncomeForAllAccounts() -> Double {
        let normalizedStartDate = Calendar.current.startOfDay(for: startDate)
        let normalizedEndDate = Calendar.current.startOfDay(for: endDate).addingTimeInterval(86399)

        let includedAccountIDs = financeModel.accounts.filter { $0.isIncludedInAnalytics }.map { $0.id }
        return financeModel.incomes
            .filter {
                includedAccountIDs.contains($0.accountID) &&
                $0.date >= normalizedStartDate &&
                $0.date <= normalizedEndDate
            }
            .reduce(0) { $0 + $1.amount }
    }

    private func calculateTotalExpenseForAllAccounts() -> Double {
        let normalizedStartDate = Calendar.current.startOfDay(for: startDate)
        let normalizedEndDate = Calendar.current.startOfDay(for: endDate).addingTimeInterval(86399)

        let includedAccountIDs = financeModel.accounts.filter { $0.isIncludedInAnalytics }.map { $0.id }
        return financeModel.expenses
            .filter {
                includedAccountIDs.contains($0.accountID) &&
                $0.date >= normalizedStartDate &&
                $0.date <= normalizedEndDate
            }
            .reduce(0) { $0 + $1.amount }
    }

    // Легенда
    private func legend(for analytics: [(category: String, amount: Double, percentage: Double)]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(analytics, id: \.category) { item in
                HStack {
                    Circle()
                        .fill(financeModel.getCategoryColor(for: item.category))
                        .frame(width: 10, height: 10)
                    Text(item.category)
                        .font(.subheadline)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(item.amount, specifier: "%.2f") ₽")
                            .font(.subheadline)
                        Text("\(item.percentage, specifier: "%.1f")%")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
