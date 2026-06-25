import SwiftUI

@main
struct NamaadhuApp: App {
  @State private var preferencesService = PreferencesService()
  @State private var timerManager = PrayerTimerManager()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.preferencesService, preferencesService)
        .environment(\.timerManager, timerManager)
    }
  }
}
