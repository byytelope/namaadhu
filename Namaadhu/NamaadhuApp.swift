import SwiftUI
import Toasts

@main
struct NamaadhuApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .installToast(position: .top)
    }
  }
}
