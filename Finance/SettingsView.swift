// изменения №2 добавление свзяи с разработчиком
import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Категории", destination: ManageCategoriesView())
                NavigationLink("Связь с разработчиком", destination: ContactDeveloperView()) // Новый пункт меню
                NavigationLink("Цвета категорий", destination: AddColor()) // Новый пункт меню
            }
            .navigationTitle("Настройки")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(FinanceModel())
    }
}
