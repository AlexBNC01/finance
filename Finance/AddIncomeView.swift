import SwiftUI

struct AddIncomeView: View {
    @EnvironmentObject var financeModel: FinanceModel
    @Binding var isPresented: Bool
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedAccountID: UUID?
    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                // Сумма
                Section(header: Text("Сумма")) {
                    TextField("Введите сумму", text: $amount)
                        .keyboardType(.decimalPad)
                        .onChange(of: amount) { newValue in
                            // Удаляем некорректные символы
                            amount = newValue.filter { "0123456789., ".contains($0) }
                        }
                }

                // Описание
                Section(header: Text("Описание")) {
                    TextField("Введите описание", text: $description)
                }

                // Выбор даты
                Section(header: Text("Дата")) {
                    DatePicker("Выберите дату", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                }

                // Выбор счёта
                Section(header: Text("Выберите счёт")) {
                    if financeModel.accounts.isEmpty {
                        Text("Нет доступных счетов")
                            .foregroundColor(.gray)
                    } else {
                        Picker("Счёт", selection: $selectedAccountID) {
                            ForEach(financeModel.accounts) { account in
                                Text(account.name).tag(account.id as UUID?)
                            }
                        }
                    }
                }

                // Кнопка сохранения
                Button(action: {
                    saveIncome()
                }) {
                    Text("Сохранить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(financeModel.accounts.isEmpty ? Color.gray : Color.green)
                        .cornerRadius(10)
                }
                .disabled(amount.isEmpty || description.isEmpty || selectedAccountID == nil)
            }
            .navigationTitle("Добавить доход")
            .onAppear {
                if selectedAccountID == nil {
                    selectedAccountID = financeModel.accounts.first?.id
                }
            }
        }
    }

    private func saveIncome() {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")),
              let accountID = selectedAccountID else { return }

        financeModel.addIncome(
            amount: amountValue,
            description: description,
            date: selectedDate,
            to: accountID
        )
        isPresented = false // Закрываем форму
    }
}
