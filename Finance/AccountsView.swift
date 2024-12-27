import SwiftUI

struct AccountsView: View {
    @EnvironmentObject var financeModel: FinanceModel
    @State private var editedAccountID: UUID?
    @State private var editedAccountName: String = ""
    @State private var editedAccountBalance: String = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(financeModel.accounts) { account in
                    VStack(alignment: .leading) {
                        if editedAccountID == account.id {
                            // Режим редактирования
                            VStack(spacing: 10) {
                                TextField("Название счёта", text: $editedAccountName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())

                                TextField("Баланс", text: $editedAccountBalance)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())

                                HStack {
                                    Button("Сохранить") {
                                        saveChanges(for: account.id)
                                    }
                                    .font(.headline)
                                    .foregroundColor(.green)

                                    Button("Отмена") {
                                        cancelEditing()
                                    }
                                    .font(.headline)
                                    .foregroundColor(.red)
                                }
                            }
                        } else {
                            // Отображение счёта
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(account.name)
                                        .font(.headline)
                                    Text("Баланс: \(account.balance, specifier: "%.2f") ₽")
                                        .font(.subheadline)
                                        .foregroundColor(account.balance >= 0 ? .green : .red)
                                }

                                Spacer()

                                // Переключатель для учета в аналитике
                                Toggle(isOn: binding(for: account)) {
                                    Text("Учитывать в аналитике")
                                        .font(.subheadline)
                                }
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                .frame(width: 50)

                                Button(action: {
                                    startEditing(account)
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
                .onDelete(perform: deleteAccounts)
            }
            .navigationTitle("Счета")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить счёт") {
                        addNewAccount()
                    }
                }
            }
        }
    }

    // Функция для получения привязки к свойству isIncludedInAnalytics
    private func binding(for account: Account) -> Binding<Bool> {
        guard let index = financeModel.accounts.firstIndex(where: { $0.id == account.id }) else {
            return .constant(account.isIncludedInAnalytics)
        }
        return $financeModel.accounts[index].isIncludedInAnalytics
    }

    // Начать редактирование
    private func startEditing(_ account: Account) {
        editedAccountID = account.id
        editedAccountName = account.name
        editedAccountBalance = String(account.balance)
    }

    // Сохранить изменения
    private func saveChanges(for accountID: UUID) {
        if let index = financeModel.accounts.firstIndex(where: { $0.id == accountID }),
           let newBalance = Double(editedAccountBalance.replacingOccurrences(of: ",", with: ".")) {
            financeModel.accounts[index].name = editedAccountName
            financeModel.accounts[index].balance = newBalance
        }
        cancelEditing() // Завершаем редактирование
    }

    // Отмена редактирования
    private func cancelEditing() {
        editedAccountID = nil
        editedAccountName = ""
        editedAccountBalance = ""
    }

    // Добавить новый счёт
    private func addNewAccount() {
        let newAccount = Account(name: "Новый счёт", balance: 0)
        financeModel.accounts.append(newAccount)
    }

    // Удаление счетов
    private func deleteAccounts(at offsets: IndexSet) {
        financeModel.accounts.remove(atOffsets: offsets)
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsView()
            .environmentObject(FinanceModel())
    }
}
