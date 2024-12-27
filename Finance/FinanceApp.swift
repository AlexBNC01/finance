// код с изменениями в периодах рабочий №1

import SwiftUI

@main
struct FinanceApp: App {
    // Создаём FinanceModel как StateObject для управления состоянием приложения
    @StateObject private var financeModel = FinanceModel()

    init() {
        setupTabBarAppearance() // Настройка внешнего вида таб-бара
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(financeModel) // Передача FinanceModel как EnvironmentObject
        }
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground() // Устанавливаем непрозрачный фон
        appearance.backgroundColor = UIColor.systemBackground // Цвет фона подстраивается под тему

        // Применяем настройки для стандартного и прокручиваемого таб-бара
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
