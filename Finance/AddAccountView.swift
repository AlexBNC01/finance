// код с изменениями в периодах рабочий №1

import SwiftUI

struct AddAccountView: View {
    @EnvironmentObject var financeModel: FinanceModel
    @Environment(\.presentationMode) var presentationMode

    @State private var accountName: String = ""

    var body: some View {
        Form {
            Section(header: Text("Название счёта")) {
                TextField("Введите название", text: $accountName)
            }

            Button(action: {
                if !accountName.isEmpty {
                    financeModel.accounts.append(Account(name: accountName))
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Добавить счёт")
            }
            .disabled(accountName.isEmpty)
        }
        .navigationTitle("Добавить счёт")
    }
}

struct AddAccountView_Previews: PreviewProvider {
    static var previews: some View {
        AddAccountView().environmentObject(FinanceModel())
    }
}
