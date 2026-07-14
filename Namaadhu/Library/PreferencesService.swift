import SwiftUI
import WidgetKit

@Observable
class PreferencesService {
  private enum Storage {
    static let selectedIslandDataKey = "selectedIslandData"
    static let notificationPrayerIdentifiersKey = "notificationPrayerIdentifiers"

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

    static var notificationPrayerIdentifiers: Set<String> {
      get {
        Set(
          AppGroup.userDefaults?.stringArray(
            forKey: notificationPrayerIdentifiersKey
          ) ?? []
        )
      }
      set {
        AppGroup.userDefaults?.set(
          newValue.sorted(),
          forKey: notificationPrayerIdentifiersKey
        )
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

  private(set) var notificationEnabledPrayers: Set<Prayer> {
    didSet {
      Storage.notificationPrayerIdentifiers = Set(
        notificationEnabledPrayers.map(\.rawValue)
      )
    }
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

    notificationEnabledPrayers = Set(
      Storage.notificationPrayerIdentifiers.compactMap(Prayer.init(rawValue:))
    )
  }

  func notificationBinding(for prayer: Prayer) -> Binding<Bool> {
    Binding(
      get: { self.notificationEnabledPrayers.contains(prayer) },
      set: { isEnabled in
        if isEnabled {
          self.notificationEnabledPrayers.insert(prayer)
        } else {
          self.notificationEnabledPrayers.remove(prayer)
        }
      }
    )
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
