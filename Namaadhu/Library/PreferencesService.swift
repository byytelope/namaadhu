import SwiftUI
import WidgetKit

@Observable
class PreferencesService {
  private class Storage {
    @AppStorage(
      "selectedIslandData",
      store: UserDefaults(suiteName: "group.me.shadhaan.Namaadhu")
    )
    var selectedIslandData: Data?
  }

  private let storage = Storage()

  var selectedIsland: Island? {
    didSet {
      do {
        storage.selectedIslandData = try selectedIsland.map {
          try JSONEncoder().encode($0)
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "PrayerTimesWidget")
      } catch {
        print("PreferencesService: failed to encode selectedIsland:", error)
      }
    }
  }

  var selectedIslandBinding: Binding<Island?> {
    Binding(
      get: { self.selectedIsland },
      set: { newValue in
        self.selectedIsland = newValue
      }
    )
  }

  init() {
    selectedIsland = {
      guard let data = storage.selectedIslandData else { return nil }
      do {
        return try JSONDecoder()
          .decode(Island.self, from: data)
      } catch {
        print("PreferencesService: failed to decode selectedIsland:", error)
        return nil
      }
    }()
  }
}

private struct PreferencesServiceKey: EnvironmentKey {
  static let defaultValue = PreferencesService()
}

extension EnvironmentValues {
  var preferencesService: PreferencesService {
    get { self[PreferencesServiceKey.self] }
    set { self[PreferencesServiceKey.self] = newValue }
  }
}
