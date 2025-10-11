import SwiftUI
import Toasts

@main
struct NamaadhuApp: App {
  var body: some Scene {
    WindowGroup {
      PrayerTimesView()
        .installToast(position: .top)
    }
  }
}
