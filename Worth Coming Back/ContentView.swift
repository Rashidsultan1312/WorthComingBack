
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        Group {
            if appViewModel.isLoading {
                LoadingView()
            } else if !appViewModel.hasSeenOnboarding {
                OnboardingView {
                    appViewModel.completeOnboarding()
                }
            } else {
                MainTabView(selectedTab: $appViewModel.selectedTab)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appViewModel.isLoading)
        .animation(.easeInOut(duration: 0.35), value: appViewModel.hasSeenOnboarding)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let store = PlacesStore.preview
        let viewModel = AppViewModel(store: store)
        return ContentView()
            .environmentObject(viewModel)
            .environmentObject(store)
    }
}
