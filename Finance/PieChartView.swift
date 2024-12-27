import SwiftUI

struct PieChartView: View {
    @EnvironmentObject var financeModel: FinanceModel // Доступ к модели данных
    let data: [String: Double]
    let totalValue: Double

    init(data: [String: Double]) {
        self.data = data
        self.totalValue = data.values.reduce(0, +)
    }

    @State private var isAnimated: Bool = false

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height)
                let center = CGPoint(x: size / 2, y: size / 2)
                let radius = size / 2

                ZStack {
                    ForEach(calculateSlices(), id: \.id) { slice in
                        PieSliceView(
                            slice: slice,
                            center: center,
                            radius: radius,
                            isAnimated: isAnimated,
                            color: financeModel.getCategoryColor(for: slice.category)
                        )
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            withAnimation(Animation.easeOut(duration: 2.0)) {
                isAnimated = true
            }
        }
    }

    private func calculateSlices() -> [PieSlice] {
        var slices: [PieSlice] = []
        var startAngle: Double = -90

        // Сортируем данные по значению
        let sortedData = data.sorted(by: { $0.value > $1.value })

        for (category, value) in sortedData {
            let angle = value / totalValue * 360
            let slice = PieSlice(
                id: UUID(),
                category: category,
                startAngle: Angle(degrees: startAngle),
                endAngle: Angle(degrees: startAngle + angle)
            )
            slices.append(slice)
            startAngle += angle
        }

        return slices
    }
}

struct PieSlice: Identifiable {
    let id: UUID
    let category: String
    let startAngle: Angle
    let endAngle: Angle
}

struct PieSliceView: View {
    let slice: PieSlice
    let center: CGPoint
    let radius: CGFloat
    let isAnimated: Bool
    let color: Color

    @State private var pulsate: Bool = false
    @State private var animationEnded: Bool = false

    var body: some View {
        let currentRadius = isAnimated ? radius : 0

        let slicePath = Path { path in
            path.move(to: center)
            path.addArc(
                center: center,
                radius: currentRadius,
                startAngle: slice.startAngle,
                endAngle: slice.endAngle,
                clockwise: false
            )
        }

        // Создаем градиент для заливки
        let gradient = AngularGradient(
            gradient: Gradient(colors: [color, color.opacity(0.5)]),
            center: .center,
            startAngle: slice.startAngle,
            endAngle: slice.endAngle
        )

        slicePath
            .fill(gradient)
            .overlay(slicePath.stroke(Color.white, lineWidth: 1))
            .scaleEffect(pulsate ? 1.05 : 1.0, anchor: .center)
            .animation(pulsateAnimation(), value: pulsate)
            .onAppear {
                // Запускаем пульсацию
                pulsate = true

                // Останавливаем пульсацию через 3 секунды
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation {
                        pulsate = false
                    }
                }
            }
    }

    // Функция для управления анимацией пульсации
    private func pulsateAnimation() -> Animation {
        if pulsate {
            return Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
        } else {
            return Animation.default
        }
    }
}
