// код с изменениями в периодах рабочий №1

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Аналитика")
                }
            AccountsView()
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Счета")
                }
            IncomeView()
                .tabItem {
                    Image(systemName: "arrow.down.circle.fill")
                    Text("Доходы")
                }
            ExpensesView()
                .tabItem {
                    Image(systemName: "arrow.up.circle.fill")
                    Text("Расходы")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Настройки")
                }
            
        }
    }
}
