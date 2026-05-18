
import SwiftUI

@main
struct Worth_Coming_BackApp: App {
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            LaunchScaffold {
                ContentView()
                    .environmentObject(appViewModel)
                    .environmentObject(appViewModel.store)
            }
        }
    }
}
