import SwiftUI

struct AddExpenseView: View {
    @EnvironmentObject var financeModel: FinanceModel
    @Binding var isPresented: Bool

    @State private var selectedAccountID: UUID?
    @State private var amount: String = ""
    @State private var selectedCategory: String = "Выбрать категорию"
    @State private var details: String = ""
    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // Выбор счёта
                    Picker("Счёт", selection: $selectedAccountID) {
                        ForEach(financeModel.accounts) { account in
                            Text(account.name).tag(account.id as UUID?)
                        }
                    }

                    // Сумма
                    TextField("Сумма", text: $amount)
                        .keyboardType(.decimalPad)

                    // Выбор категории
                    Picker("Категория", selection: $selectedCategory) {
                        Text("Выбрать категорию").tag("Выбрать категорию")
                        ForEach(financeModel.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }

                    // Детали
                    TextField("Описание", text: $details)

                    // Выбор даты
                    DatePicker("Дата", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                }

                Spacer()

                // Кнопка "Добавить"
                Button(action: {
                    saveExpense()
                }) {
                    Text("Добавить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedAccountID != nil && selectedCategory != "Выбрать категорию" && !amount.isEmpty
                            ? Color.blue
                            : Color.gray
                        )
                        .cornerRadius(10)
                }
                .disabled(selectedAccountID == nil || selectedCategory == "Выбрать категорию" || amount.isEmpty)
                .padding()
            }
            .navigationTitle("Добавить расход")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                if selectedAccountID == nil, let firstAccount = financeModel.accounts.first {
                    selectedAccountID = firstAccount.id
                }
            }
        }
    }

    private func saveExpense() {
        guard let accountID = selectedAccountID,
              let expenseAmount = Double(amount.replacingOccurrences(of: ",", with: ".")) else { return }

        financeModel.addExpense(
            amount: expenseAmount,
            wallet: "Счёт",
            category: selectedCategory,
            details: details,
            date: selectedDate,
            from: accountID
        )
        isPresented = false
    }
}
