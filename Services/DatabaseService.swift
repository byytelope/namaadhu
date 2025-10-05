import GRDB
import SwiftUI

protocol DatabaseServiceProtocol {
  func fetchAllIslands() throws -> [Island]
  func fetchIslandByID(id: Int) throws -> Island?
  func fetchPrayerTime(for island: Island, in date: Date) throws
    -> PrayerTimes?
}

struct DatabaseService: DatabaseServiceProtocol {
  private let reader: any DatabaseReader

  init(reader: any DatabaseReader) {
    self.reader = reader
  }

  func fetchAllIslands() throws -> [Island] {
    try reader.read { db in
      try Island.fetchAll(
        db,
        sql: "SELECT * FROM islands WHERE status=1 ORDER BY id;"
      )
    }
  }

  func fetchIslandByID(id: Int) throws -> Island? {
    try reader.read { db in
      try Island.fetchOne(
        db,
        sql: "SELECT * FROM islands WHERE id=?",
        arguments: [id]
      )
    }
  }

  func fetchPrayerTime(for island: Island, in date: Date) throws
    -> PrayerTimes?
  {
    return try reader.read { db in
      try PrayerTimes.fetchOne(
        db,
        sql: "SELECT * FROM prayer_times WHERE category_id=? AND date=?",
        arguments: [island.categoryId, date.dayIndex]
      )
    }
  }
}

struct MockDatabaseService: DatabaseServiceProtocol {
  func fetchAllIslands() throws -> [Island] { mockIslands }

  func fetchIslandByID(id: Int) throws -> Island? {
    return mockIslands.first(where: { $0.id == id })
  }

  func fetchPrayerTime(for island: Island, in date: Date) throws
    -> PrayerTimes?
  {
    let cal = Calendar.current
    let startOfToday = cal.startOfDay(for: Date())
    let startOfTarget = cal.startOfDay(for: date)
    let day =
      cal.dateComponents([.day], from: startOfToday, to: startOfTarget).day ?? 0

    return
      mockPrayerTimes
      .first(where: {
        $0.categoryId == island.categoryId && $0.dayOfYear == day
      })
  }
}

private struct DatabaseServiceKey: EnvironmentKey {
  static let defaultValue: DatabaseServiceProtocol = {
    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    {
      MockDatabaseService()
    } else {
      DatabaseService(reader: AppDatabase.shared)
    }
  }()
}

extension EnvironmentValues {
  var databaseService: DatabaseServiceProtocol {
    get { self[DatabaseServiceKey.self] }
    set { self[DatabaseServiceKey.self] = newValue }
  }
}
