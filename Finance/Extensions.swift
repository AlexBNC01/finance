// код с изменениями в периодах рабочий №1

import UIKit

extension UIColor {
    func toHex() -> String {
        guard let components = self.cgColor.components, components.count >= 3 else {
            return "#FFFFFF" // Белый цвет по умолчанию
        }
        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255))
    }
}
