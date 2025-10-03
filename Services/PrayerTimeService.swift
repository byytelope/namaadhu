import GRDB
import SwiftUI

protocol PrayerTimeProtocol {
  func fetchAllIslands() throws -> [Island]
  func fetchPrayerTime(for island: Island, in date: Date) throws
    -> PrayerTime?
}

struct PrayerTimeService: PrayerTimeProtocol {
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
    -> PrayerTime?
  {
    return try reader.read { db in
      try PrayerTime.fetchOne(
        db,
        sql: "SELECT * FROM prayer_times WHERE category_id=? AND date=?",
        arguments: [island.categoryId, date.dayIndex]
      )
    }
  }
}

struct MockPrayerTimeService: PrayerTimeProtocol {
  func fetchAllIslands() throws -> [Island] { mockIslands }
  func fetchPrayerTime(for island: Island, in date: Date) throws
    -> PrayerTime?
  {
    let cal = Calendar.current
    let startOfToday = cal.startOfDay(for: Date())
    let startOfTarget = cal.startOfDay(for: date)
    let day =
      cal.dateComponents([.day], from: startOfToday, to: startOfTarget).day ?? 0

    return
      mockPrayerTimes
      .first(where: { $0.date == day && $0.categoryId == island.categoryId })
  }
}

private struct PrayerTimeServiceKey: EnvironmentKey {
  static let defaultValue: PrayerTimeProtocol = {
    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    {
      MockPrayerTimeService()
    } else {
      PrayerTimeService(reader: AppDatabase.shared)
    }
  }()
}

extension EnvironmentValues {
  var prayerTimeService: PrayerTimeProtocol {
    get { self[PrayerTimeServiceKey.self] }
    set { self[PrayerTimeServiceKey.self] = newValue }
  }
}

extension Calendar {
  /// Gregorian calendar fixed to Maldives time zone.
  static var maldives: Calendar {
    var cal = Calendar(identifier: .gregorian)
    if let tz = TimeZone(identifier: "Indian/Maldives") {
      cal.timeZone = tz
    } else {
      cal.timeZone = TimeZone(secondsFromGMT: 5 * 3600) ?? .current
    }
    return cal
  }
}

extension Date {
  /// Creates a Date in Maldives local time from a 0-based day index (0...365) and a specific year.
  ///
  /// Semantics:
  /// - The index space is always 0...365, reserving an entry for Feb 29.
  /// - In leap years, all indices map 1:1 (index 59 is Feb 29).
  /// - In non-leap years, index 59 is skipped (returns nil), and indices > 59 are shifted by -1.
  /// - Calendar and time zone are fixed to Maldives (Gregorian, Indian/Maldives).
  init?(dayIndex: Int, year: Int, calendar baseCalendar: Calendar = .maldives) {
    guard (0...365).contains(dayIndex) else { return nil }
    let cal = baseCalendar
    guard
      let jan1 = cal.date(from: DateComponents(year: year, month: 1, day: 1)),
      let daysInYear = cal.range(of: .day, in: .year, for: jan1)
    else {
      return nil
    }
    let isLeapYear = (daysInYear.count == 366)
    if !isLeapYear && dayIndex == 59 { return nil }
    let adjustedIndex =
      (!isLeapYear && dayIndex > 59) ? (dayIndex - 1) : dayIndex
    guard let date = cal.date(byAdding: .day, value: adjustedIndex, to: jan1)
    else {
      return nil
    }
    self = date
  }

  /// Returns the 0-based day index (0...365) for Maldives local time, assuming the data set
  /// always includes Feb 29. For non-leap years, days on/after Mar 1 are shifted by +1 to
  /// skip the non-existent Feb 29.
  var dayIndex: Int {
    let cal = Calendar.maldives
    let ord1 = cal.ordinality(of: .day, in: .year, for: self) ?? 1
    var index0 = ord1 - 1
    let year = cal.component(.year, from: self)
    guard
      let jan1 = cal.date(from: DateComponents(year: year, month: 1, day: 1)),
      let daysInYear = cal.range(of: .day, in: .year, for: jan1)
    else {
      return index0
    }
    let isLeapYear = daysInYear.count == 366
    if !isLeapYear, index0 >= 59 {
      index0 += 1
    }

    return index0
  }
}
