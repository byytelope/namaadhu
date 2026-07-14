import Foundation

enum AppGroup {
  static var identifier: String? {
    Bundle.main.object(forInfoDictionaryKey: "AppGroupIdentifier") as? String
  }

  static var userDefaults: UserDefaults? {
    identifier.flatMap { UserDefaults(suiteName: $0) }
  }
}
