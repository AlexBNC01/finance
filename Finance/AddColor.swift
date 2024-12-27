// код с изменениями в периодах рабочий №3
import SwiftUI

struct AddColor: View {
    @EnvironmentObject var financeModel: FinanceModel

    var body: some View {
        NavigationView {
            List {
                ForEach(financeModel.categories.indices, id: \ .self) { index in
                    HStack {
                        Text(financeModel.categories[index])
                            .font(.headline)

                        Spacer()

                        ColorPicker("Цвет", selection: Binding(
                            get: { financeModel.getCategoryColor(for: financeModel.categories[index]) },
                            set: { newColor in
                                financeModel.setCategoryColor(for: financeModel.categories[index], color: newColor)
                            }
                        ))
                        .labelsHidden()
                        .frame(maxWidth: 50)
                    }
                }
            }
            .navigationTitle("Цвета категорий")
        }
    }
}

struct AddColor_Previews: PreviewProvider {
    static var previews: some View {
        AddColor().environmentObject(FinanceModel())
    }
}
