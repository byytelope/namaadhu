import SwiftUI

@Observable
class PreferencesService {
  private class Storage {
    @AppStorage("selectedIslandID") var selectedIslandData: Data?
  }

  private let storage = Storage()

  var selectedIsland: Island? {
    didSet {
      if let island = selectedIsland {
        do {
          let data = try JSONEncoder().encode(island)
          storage.selectedIslandData = data
        } catch {
          print("PreferencesService: failed to encode selectedIsland:", error)
        }
      } else {
        storage.selectedIslandData = nil
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
