import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: PlacesStore
    @Binding var selectedTab: AppTab

    var body: some View {
        TabView(selection: $selectedTab) {
            MapHomeView { coordinate in
                store.prepareQuickAdd(at: coordinate)
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    selectedTab = .add
                }
            }
            .tabItem {
                Label(AppTab.map.title, systemImage: AppTab.map.systemImage)
            }
            .tag(AppTab.map)

            AddPlaceView(selectedTab: $selectedTab)
                .tabItem {
                    Label(AppTab.add.title, systemImage: AppTab.add.systemImage)
                }
                .tag(AppTab.add)

            JournalView()
                .tabItem {
                    Label(AppTab.journal.title, systemImage: AppTab.journal.systemImage)
                }
                .tag(AppTab.journal)

            ExploreView()
                .tabItem {
                    Label(AppTab.explore.title, systemImage: AppTab.explore.systemImage)
                }
                .tag(AppTab.explore)
        }
        .tint(Color(red: 0.1, green: 0.38, blue: 0.91))
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(selectedTab: .constant(.map))
            .environmentObject(PlacesStore.preview)
    }
}
