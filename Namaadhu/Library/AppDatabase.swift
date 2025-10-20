import Foundation
import GRDB

struct AppDatabase {
  static let shared: DatabasePool = {
    guard
      let url = Bundle.main.url(forResource: "salat", withExtension: "sqlite")
    else {
      preconditionFailure("Missing bundled database: salat.sqlite")
    }
    let uri = "file:\(url.path)?mode=ro&immutable=1"

    var config = Configuration()
    config.readonly = true

    do {
      return try DatabasePool(path: uri, configuration: config)
    } catch {
      fatalError("Failed to open bundled database: \(error)")
    }
  }()
}
