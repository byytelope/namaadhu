import SwiftUI

#if canImport(Toasts)
  import Toasts
#endif

struct ContentView: View {
  @State private var visibility: NavigationSplitViewVisibility = .all
  @State private var selectedIsland: Island?

  var body: some View {
    NavigationSplitView {
      IslandsView(selectedIsland: $selectedIsland)
    } detail: {
      if let island = selectedIsland {
        PrayerTimesView(selectedIsland: island)
          .navigationBarBackButtonHidden()
      } else {
        ContentUnavailableView(
          "Select an island to continue",
          systemImage: "location.slash.circle.fill",
          description: Text("Please select an island from the list.")
        )
      }
    }
  }
}

#Preview {
  ContentView()
    #if canImport(Toasts)
      .installToast(position: .top)
    #endif
}
