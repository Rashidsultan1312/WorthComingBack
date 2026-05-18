import SwiftUI

private struct OnboardingStep: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let symbol: String
}

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var selectedPage = 0
    private let steps: [OnboardingStep] = [
        OnboardingStep(
            title: "This is your personal map",
            subtitle: "Save moments in places you actually care about. It is memory, not navigation.",
            symbol: "map.fill"
        ),
        OnboardingStep(
            title: "Color means feeling",
            subtitle: "Blue = loved it, yellow = okay, red = never again. One tap shows your story.",
            symbol: "mappin.circle.fill"
        ),
        OnboardingStep(
            title: "Save in five seconds",
            subtitle: "Drop a pin, write one short note, pick return intent, and move on.",
            symbol: "sparkles"
        )
    ]

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button("Skip", action: onFinish)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                TabView(selection: $selectedPage) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        VStack(spacing: 20) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .fill(Color.white.opacity(0.5))
                                    .frame(width: 196, height: 196)
                                Image(systemName: step.symbol)
                                    .font(.system(size: 70, weight: .semibold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.blue, Color.orange],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)

                            Text(step.title)
                                .font(.system(size: 30, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.primary)

                            Text(step.subtitle)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 26)
                        }
                        .padding(.bottom, 52)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                Button(action: handlePrimaryAction) {
                    Text(selectedPage == steps.count - 1 ? "Start Mapping" : "Next")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color(red: 0.1, green: 0.36, blue: 0.89)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }

    private func handlePrimaryAction() {
        if selectedPage == steps.count - 1 {
            onFinish()
        } else {
            withAnimation(.easeInOut) {
                selectedPage += 1
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onFinish: {})
    }
}
