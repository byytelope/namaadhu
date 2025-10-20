import SwiftUI

#if canImport(Toasts)
  import Toasts
#endif

struct ContentView: View {
  @Environment(\.preferencesService) private var prefs

  @State private var visibility: NavigationSplitViewVisibility = .all
  @State private var searchText: String = ""

  var body: some View {
    NavigationSplitView {
      IslandsView(
        searchText: searchText,
        selectedIsland: prefs.selectedIslandBinding
      )
    } detail: {
      Group {
        if let island = prefs.selectedIsland {
          PrayerTimesView(selectedIsland: island)
        } else {
          ContentUnavailableView(
            "Select an island to continue",
            systemImage: "location.slash.circle.fill",
            description: Text("Please select an island from the list.")
          )
        }
      }
      .navigationBarBackButtonHidden()
    }
    .searchable(
      text: $searchText,
      placement: .sidebar,
      prompt: "Search islands",
    )
  }
}

#Preview {
  ContentView()
    #if canImport(Toasts)
      .installToast(position: .top)
    #endif
}
