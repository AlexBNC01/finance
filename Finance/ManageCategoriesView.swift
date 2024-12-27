// код с изменениями в периодах рабочий №1

import SwiftUI

struct ManageCategoriesView: View {
    @EnvironmentObject var financeModel: FinanceModel
    @State private var editedCategory: String = ""
    @State private var editingIndex: Int?

    var body: some View {
        VStack {
            List {
                // Перетаскиваемый список категорий
                ForEach(Array(financeModel.categories.enumerated()), id: \.element) { index, category in
                    HStack {
                        if editingIndex == index {
                            TextField("", text: $editedCategory, onCommit: {
                                saveCategoryEdit(at: index)
                            })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text(category)
                            Spacer()
                            Button(action: {
                                startEditing(index: index, category: category)
                            }) {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                .onMove(perform: moveCategory) // Добавляем поддержку перетаскивания
                .onDelete(perform: deleteCategory)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton() // Кнопка для активации режима редактирования
                }
            }

            Spacer()

            // Кнопка для перехода на экран добавления категории
            NavigationLink(destination: AddCategoryView()) {
                Text("Добавить категорию")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Категории")
    }

    // Метод для удаления категории
    private func deleteCategory(at offsets: IndexSet) {
        financeModel.categories.remove(atOffsets: offsets)
    }

    // Метод для изменения порядка категорий
    private func moveCategory(from source: IndexSet, to destination: Int) {
        financeModel.categories.move(fromOffsets: source, toOffset: destination)
        financeModel.saveCategories() // Сохраняем новый порядок категорий
    }

    // Начать редактирование категории
    private func startEditing(index: Int, category: String) {
        editingIndex = index
        editedCategory = category
    }

    // Сохранить изменения категории
    private func saveCategoryEdit(at index: Int) {
        let trimmedCategory = editedCategory.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedCategory.isEmpty {
            financeModel.categories[index] = trimmedCategory
            financeModel.saveCategories()
        }
        editingIndex = nil
    }
}

struct ManageCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        ManageCategoriesView().environmentObject(FinanceModel())
    }
}
