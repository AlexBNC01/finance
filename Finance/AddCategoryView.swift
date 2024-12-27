// код с изменениями в периодах рабочий №1

import SwiftUI

struct AddCategoryView: View {
    @EnvironmentObject var financeModel: FinanceModel
    @Environment(\.presentationMode) var presentationMode

    @State private var newCategory: String = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Название категории", text: $newCategory)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                addCategory()
            }) {
                Text("Добавить")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .disabled(newCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding()

            Spacer()
        }
        .padding()
        .navigationTitle("Добавить категорию")
    }

    private func addCategory() {
        let trimmedCategory = newCategory.trimmingCharacters(in: .whitespacesAndNewlines)
        if !financeModel.categories.contains(trimmedCategory) {
            financeModel.categories.append(trimmedCategory)
        }
        newCategory = ""
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        AddCategoryView().environmentObject(FinanceModel())
    }
}
