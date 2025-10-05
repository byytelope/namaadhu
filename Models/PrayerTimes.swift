import Foundation
import GRDB

/// Represents daily prayer times with convenient types.
///
/// This model keeps the `dayOfYear` index from the database, but exposes each
/// prayer time as `DateComponents (hour/minute)` instead of raw minutes. It also
/// provides helpers to compute absolute `Date` values when given a specific day/year.
struct PrayerTimes: Sendable, Equatable, FetchableRecord, Decodable {
  let categoryId: Int
  let dayOfYear: Int

  let fajr: DateComponents
  let sunrise: DateComponents
  let dhuhr: DateComponents
  let asr: DateComponents
  let maghrib: DateComponents
  let isha: DateComponents

  private enum CodingKeys: String, CodingKey {
    case categoryId = "category_id"
    case date
    case fajr
    case sunrise
    case dhuhr
    case asr
    case maghrib
    case isha
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let categoryId = try container.decode(Int.self, forKey: .categoryId)
    let dayOfYear = try container.decode(Int.self, forKey: .date)

    func components(for key: CodingKeys) throws -> DateComponents {
      minutesToComponents(try container.decode(Int.self, forKey: key))
    }

    self.init(
      categoryId: categoryId,
      dayOfYear: dayOfYear,
      fajr: try components(for: .fajr),
      sunrise: try components(for: .sunrise),
      dhuhr: try components(for: .dhuhr),
      asr: try components(for: .asr),
      maghrib: try components(for: .maghrib),
      isha: try components(for: .isha)
    )
  }

  init(
    categoryId: Int,
    dayOfYear: Int,
    fajr: DateComponents,
    sunrise: DateComponents,
    dhuhr: DateComponents,
    asr: DateComponents,
    maghrib: DateComponents,
    isha: DateComponents
  ) {
    self.categoryId = categoryId
    self.dayOfYear = dayOfYear
    self.fajr = fajr
    self.sunrise = sunrise
    self.dhuhr = dhuhr
    self.asr = asr
    self.maghrib = maghrib
    self.isha = isha
  }

  func fajrDate(on day: Date, calendar: Calendar = .current) -> Date? {
    time(fajr, on: day, calendar: calendar)
  }
  func sunriseDate(on day: Date, calendar: Calendar = .current) -> Date? {
    time(sunrise, on: day, calendar: calendar)
  }
  func dhuhrDate(on day: Date, calendar: Calendar = .current) -> Date? {
    time(dhuhr, on: day, calendar: calendar)
  }
  func asrDate(on day: Date, calendar: Calendar = .current) -> Date? {
    time(asr, on: day, calendar: calendar)
  }
  func maghribDate(on day: Date, calendar: Calendar = .current) -> Date? {
    time(maghrib, on: day, calendar: calendar)
  }
  func ishaDate(on day: Date, calendar: Calendar = .current) -> Date? {
    time(isha, on: day, calendar: calendar)
  }

  func day(in year: Int, calendar: Calendar = .current) -> Date? {
    guard
      let startOfYear = calendar.date(
        from: DateComponents(year: year, month: 1, day: 1)
      )
    else {
      return nil
    }
    return calendar.date(byAdding: .day, value: dayOfYear, to: startOfYear)
  }
}

private func time(
  _ components: DateComponents,
  on day: Date,
  calendar: Calendar = .current
) -> Date? {
  let midnight = calendar.startOfDay(for: day)
  return calendar.date(byAdding: components, to: midnight)
}

private func minutesToComponents(_ minutes: Int) -> DateComponents {
  DateComponents(hour: minutes / 60, minute: minutes % 60)
}

extension Date {
  /// Zero-based day index within the Gregorian year for this date.
  /// For Jan 1st this returns 0; for Jan 2nd it returns 1, and so on.
  /// - Parameter calendar: Calendar to use (defaults to `.current`).
  public func dayIndex(in calendar: Calendar = .current) -> Int {
    guard
      let startOfYear = calendar.date(
        from: calendar.dateComponents([.year], from: self)
      )
    else {
      return 0
    }
    let startOfDay = calendar.startOfDay(for: self)
    let components = calendar.dateComponents(
      [.day],
      from: calendar.startOfDay(for: startOfYear),
      to: startOfDay
    )
    return components.day ?? 0
  }

  public var dayIndex: Int { dayIndex() }
}
