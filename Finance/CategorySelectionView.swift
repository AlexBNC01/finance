// код с изменениями в периодах рабочий №1

import SwiftUI

struct CategorySelectionView: View {
    @EnvironmentObject var financeModel: FinanceModel
    @Binding var selectedCategory: String
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            VStack {
                Text("Выберите категорию")
                    .font(.headline)
                    .padding()

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                        ForEach(financeModel.categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                                isPresented = false // Закрываем модальное окно
                            }) {
                                Text(category)
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Категории")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
