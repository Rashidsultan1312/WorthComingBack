import Foundation

@MainActor
final class AppViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var hasSeenOnboarding: Bool
    @Published var selectedTab: AppTab = .map

    let store: PlacesStore

    private let onboardingKey = "worth_coming_back_has_seen_onboarding"

    init(store: PlacesStore) {
        self.store = store
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        Task { await runLoadingAnimation() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            Task { @MainActor in
                self?.finishLoadingIfNeeded()
            }
        }
    }

    convenience init() {
        self.init(store: PlacesStore())
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }

    private func runLoadingAnimation() async {
        try? await Task.sleep(nanoseconds: 1_250_000_000)
        finishLoadingIfNeeded()
    }

    private func finishLoadingIfNeeded() {
        guard isLoading else { return }
        isLoading = false
    }
}
