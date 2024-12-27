
// код с изменениями в периодах рабочий №1
import SwiftUI

struct IncomeView: View {
    @EnvironmentObject var financeModel: FinanceModel
    @State private var isPresentingAddIncome = false

    var body: some View {
        NavigationView {
            VStack {
                if financeModel.incomes.isEmpty {
                    Text("Нет добавленных доходов")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(financeModel.incomes) { income in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(income.description)
                                    .font(.headline)
                                Text("\(income.amount, specifier: "%.2f") ₽")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                                if let account = financeModel.accounts.first(where: { $0.id == income.accountID }) {
                                    Text("Счёт: \(account.name)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: deleteIncome)
                    }
                }

                // Кнопка добавления дохода
                Button(action: {
                    isPresentingAddIncome = true
                }) {
                    Text("Добавить доход")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $isPresentingAddIncome) {
                    AddIncomeView(isPresented: $isPresentingAddIncome)
                        .environmentObject(financeModel)
                }
            }
            .navigationTitle("Доходы")
        }
    }

    private func deleteIncome(at offsets: IndexSet) {
        for offset in offsets {
            let income = financeModel.incomes[offset]
            if let accountIndex = financeModel.accounts.firstIndex(where: { $0.id == income.accountID }) {
                // Уменьшаем баланс счёта
                financeModel.accounts[accountIndex].balance -= income.amount
            }
        }
        // Удаляем доход из списка
        financeModel.incomes.remove(atOffsets: offsets)
    }
}
