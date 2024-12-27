// код с изменениями в периодах рабочий №1

import SwiftUI

struct ContactDeveloperView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Связь с разработчиком")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Если у вас есть вопросы или предложения, вы можете связаться с нами по электронной почте.")
                .font(.body)
                .padding(.bottom)

            Text("Электронная почта:")
                .font(.headline)

            Text("developer@example.com")
                .font(.body)
                .foregroundColor(.blue)
                .underline()
                .onTapGesture {
                    let email = "developer@example.com"
                    if let url = URL(string: "mailto:\(email)") {
                        UIApplication.shared.open(url)
                    }
                }

            Spacer()
        }
        .padding()
        
    }
}

struct ContactDeveloperView_Previews: PreviewProvider {
    static var previews: some View {
        ContactDeveloperView()
    }
}
