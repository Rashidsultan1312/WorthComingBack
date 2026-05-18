import SwiftUI

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.94, green: 0.97, blue: 1.0),
                    Color(red: 0.89, green: 0.94, blue: 1.0),
                    Color(red: 0.97, green: 0.96, blue: 0.91)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.45))
                .frame(width: 230, height: 230)
                .blur(radius: 18)
                .offset(x: -120, y: -280)

            Circle()
                .fill(Color(red: 0.55, green: 0.84, blue: 1.0).opacity(0.28))
                .frame(width: 290, height: 290)
                .blur(radius: 24)
                .offset(x: 130, y: -110)

            Circle()
                .fill(Color(red: 1.0, green: 0.78, blue: 0.47).opacity(0.24))
                .frame(width: 260, height: 260)
                .blur(radius: 24)
                .offset(x: -110, y: 280)
        }
    }
}
