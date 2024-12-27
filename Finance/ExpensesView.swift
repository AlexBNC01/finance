// код с изменениями в периодах рабочий №1

import SwiftUI

struct ExpensesView: View {
    @EnvironmentObject var financeModel: FinanceModel
    @State private var isPresentingAddExpense = false

    var body: some View {
        NavigationView {
            VStack {
                if financeModel.expenses.isEmpty {
                    Text("Нет добавленных расходов")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(financeModel.expenses) { expense in
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(expense.details)
                                        .font(.headline)
                                    Text("Категория: \(expense.category)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    if let account = financeModel.accounts.first(where: { $0.id == expense.accountID }) {
                                        Text("Счёт: \(account.name)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(expense.amount, specifier: "%.2f") ₽")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                    Text(formatDate(expense.date))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete(perform: deleteExpense)
                    }
                }

                // Кнопка добавления расхода
                Button(action: {
                    isPresentingAddExpense = true
                }) {
                    Text("Добавить расход")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $isPresentingAddExpense) {
                    AddExpenseView(isPresented: $isPresentingAddExpense)
                        .environmentObject(financeModel)
                }
            }
            .navigationTitle("Расходы")
        }
    }

    private func deleteExpense(at offsets: IndexSet) {
        for offset in offsets {
            let expense = financeModel.expenses[offset]
            if let accountIndex = financeModel.accounts.firstIndex(where: { $0.id == expense.accountID }) {
                financeModel.accounts[accountIndex].balance += expense.amount
            }
        }
        financeModel.expenses.remove(atOffsets: offsets)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
