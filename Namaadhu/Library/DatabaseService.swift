import GRDB
import SwiftUI

protocol DatabaseServiceProtocol {
  func fetchAllIslands() throws -> [Island]
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

  func fetchPrayerTime(for island: Island, in date: Date) throws
    -> PrayerTimes?
  {
    return try reader.read { db in
      try PrayerTimesRecord.fetchOne(
        db,
        sql: "SELECT * FROM prayer_times WHERE category_id=? AND date=?",
        arguments: [island.categoryId, date.prayerTimesDatabaseDayIndex]
      )
      .map {
        $0.prayerTimes(on: date)
          .applyingOffset(island.minutes)
      }
    }
  }
}

struct MockDatabaseService: DatabaseServiceProtocol {
  func fetchAllIslands() throws -> [Island] { mockIslands }

  func fetchPrayerTime(for island: Island, in date: Date) throws
    -> PrayerTimes?
  {
    return
      mockPrayerTimes
      .first(where: {
        $0.categoryId == island.categoryId
          && Calendar.current.isDate($0.date, inSameDayAs: date)
      })
      .map { $0.applyingOffset(island.minutes) }
  }
}

private struct PrayerTimesRecord: FetchableRecord {
  let categoryId: Int
  let values: PrayerTimes.Values

  init(row: Row) throws {
    categoryId = try Self.requiredInt("category_id", from: row)
    values = PrayerTimes.Values(
      fajr: try Self.requiredInt(Prayer.fajr.rawValue, from: row),
      sunrise: try Self.requiredInt(Prayer.sunrise.rawValue, from: row),
      dhuhr: try Self.requiredInt(Prayer.dhuhr.rawValue, from: row),
      asr: try Self.requiredInt(Prayer.asr.rawValue, from: row),
      maghrib: try Self.requiredInt(Prayer.maghrib.rawValue, from: row),
      isha: try Self.requiredInt(Prayer.isha.rawValue, from: row)
    )
  }

  func prayerTimes(on date: Date) -> PrayerTimes {
    PrayerTimes(
      categoryId: categoryId,
      date: date,
      values: values
    )
  }

  private static func requiredInt(_ column: String, from row: Row) throws -> Int {
    guard let value: Int = row[column] else {
      throw PrayerTimesRecordError.missingValue(column)
    }

    return value
  }
}

private enum PrayerTimesRecordError: LocalizedError {
  case missingValue(String)

  var errorDescription: String? {
    switch self {
    case .missingValue(let column):
      "Missing prayer-time value for database column '\(column)'."
    }
  }
}

private extension Calendar {
  func isLeapYear(_ year: Int) -> Bool {
    let startOfYear = date(from: DateComponents(year: year))!
    return range(of: .day, in: .year, for: startOfYear)!.count == 366
  }
}

private extension Date {
  var prayerTimesDatabaseDayIndex: Int {
    let calendar = Calendar.current
    var ord: Int {
      let _ord = calendar.ordinality(of: .day, in: .year, for: self) ?? 1
      return _ord - 1
    }

    let comps = calendar.dateComponents([.year, .month, .day], from: self)
    guard let year = comps.year, let month = comps.month else {
      return ord
    }

    if !calendar.isLeapYear(year) {
      if month > 2 {
        return ord + 1
      }
    }

    return ord
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
