import SwiftUI

#if canImport(Toasts)
  import Toasts
#endif

@main
struct NamaadhuApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        #if canImport(Toasts)
          .installToast(position: .top)
        #endif
    }
  }
}
