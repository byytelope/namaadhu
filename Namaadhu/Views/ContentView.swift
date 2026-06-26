import SwiftUI

struct ContentView: View {
  @Environment(\.preferencesService) private var prefs

  @Namespace private var islandTransition
  @State private var isSelectingIsland = false

  var body: some View {
    NavigationStack {
      if let island = prefs.selectedIsland {
        PrayerTimesView(
          selectedIsland: island,
          islandTransition: islandTransition,
          onSelectLocation: {
            isSelectingIsland = true
          }
        )
      } else {
        ContentUnavailableView {
          Label(
            "Select an island to continue",
            systemImage: "location.slash.circle.fill"
          )
        } description: {
          Text("Please select an island from the list.")
        } actions: {
          Button("Choose Island", systemImage: "location") {
            isSelectingIsland = true
          }
          .buttonStyle(.borderedProminent)
          .matchedTransitionSource(
            id: "islands",
            in: islandTransition
          )
        }
      }
    }
    .sheet(isPresented: $isSelectingIsland) {
      NavigationStack {
        IslandsView(
          selectedIsland: prefs.selectedIslandBinding
        )
      }
      .navigationTransition(
        .zoom(sourceID: "islands", in: islandTransition)
      )
    }
  }
}

private struct ContentViewPreview: View {
  @State private var preferencesService: PreferencesService
  @State private var timerManager = MockPrayerTimerManager()

  init() {
    let preferencesService = PreferencesService()
    preferencesService.selectedIsland = mockIslands[0]
    _preferencesService = State(initialValue: preferencesService)
  }

  var body: some View {
    ContentView()
      .environment(\.preferencesService, preferencesService)
      .environment(\.timerManager, timerManager)
      .overlay(alignment: .top) {
        Button("Advance Prayer", systemImage: "forward.fill") {
          timerManager.advancePrayer()
        }
        .buttonStyle(.borderedProminent)
        .padding(.top, 50)
      }
  }
}

#Preview {
  ContentViewPreview()
}
