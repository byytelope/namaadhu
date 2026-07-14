import SwiftUI
import WidgetKit

@Observable
class PreferencesService {
  private enum Storage {
    static let selectedIslandDataKey = "selectedIslandData"

    static var selectedIslandData: Data? {
      get {
        AppGroup.userDefaults?.data(forKey: selectedIslandDataKey)
      }
      set {
        guard let userDefaults = AppGroup.userDefaults else { return }

        if let newValue {
          userDefaults.set(newValue, forKey: selectedIslandDataKey)
        } else {
          userDefaults.removeObject(forKey: selectedIslandDataKey)
        }
      }
    }
  }

  var selectedIsland: Island? {
    didSet {
      do {
        Storage.selectedIslandData = try selectedIsland.map {
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
      guard let data = Storage.selectedIslandData else { return nil }
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
