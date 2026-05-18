import SwiftUI

struct LoadingView: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 124, height: 124)
                        .scaleEffect(pulse ? 1.08 : 0.92)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)

                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }

                Text("Building your memory map")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("No ratings. No noise. Just your places.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .onAppear {
            pulse = true
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
