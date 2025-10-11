import Foundation
import GRDB

enum Prayer: String, CaseIterable, Identifiable {
  case fajr, sunrise, dhuhr, asr, maghrib, isha
  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .fajr: return "Fajr"
    case .sunrise: return "Sunrise"
    case .dhuhr: return "Dhuhr"
    case .asr: return "Asr"
    case .maghrib: return "Maghrib"
    case .isha: return "Isha"
    }
  }

  var sfSymbol: String {
    switch self {
    case .fajr: return "moon.haze"
    case .sunrise: return "sunrise"
    case .dhuhr: return "sun.max"
    case .asr: return "sun.min"
    case .maghrib: return "sunset"
    case .isha: return "moon.stars"
    }
  }

  var dbColumn: String { rawValue }
}

struct PrayerTimes: Sendable, Equatable, FetchableRecord {
  let categoryId: Int
  let day: Date

  let fajr: DateComponents
  let sunrise: DateComponents
  let dhuhr: DateComponents
  let asr: DateComponents
  let maghrib: DateComponents
  let isha: DateComponents

  init(row: Row) {
    categoryId = row["category_id"] ?? 0

    let dayIndex: Int = row["date"] ?? 0
    let calendar = Calendar.current
    let year = calendar.component(.year, from: Date())
    let startOfYear = calendar.date(
      from: DateComponents(year: year, month: 1, day: 1)
    )!
    day = calendar.date(byAdding: .day, value: dayIndex, to: startOfYear)!

    func comps(_ col: String) -> DateComponents {
      let minutes: Int = row[col] ?? 0
      return minutesToComponents(minutes)
    }

    fajr = comps(Prayer.fajr.dbColumn)
    sunrise = comps(Prayer.sunrise.dbColumn)
    dhuhr = comps(Prayer.dhuhr.dbColumn)
    asr = comps(Prayer.asr.dbColumn)
    maghrib = comps(Prayer.maghrib.dbColumn)
    isha = comps(Prayer.isha.dbColumn)
  }

  init(
    categoryId: Int,
    dayOfYear: Int,
    fajrMinutes: Int,
    sunriseMinutes: Int,
    dhuhrMinutes: Int,
    asrMinutes: Int,
    maghribMinutes: Int,
    ishaMinutes: Int,
  ) {
    self.categoryId = categoryId
    let calendar = Calendar.current

    let year = calendar.component(.year, from: Date())
    let startOfYear = calendar.date(
      from: DateComponents(year: year, month: 1, day: 1)
    )!
    self.day = calendar.date(byAdding: .day, value: dayOfYear, to: startOfYear)!

    func comps(from minutes: Int) -> DateComponents {
      DateComponents(hour: (minutes / 60), minute: (minutes % 60))
    }

    self.fajr = comps(from: fajrMinutes)
    self.sunrise = comps(from: sunriseMinutes)
    self.dhuhr = comps(from: dhuhrMinutes)
    self.asr = comps(from: asrMinutes)
    self.maghrib = comps(from: maghribMinutes)
    self.isha = comps(from: ishaMinutes)
  }

  var orderedTimes: [(Prayer, DateComponents)] {
    [
      (.fajr, fajr),
      (.sunrise, sunrise),
      (.dhuhr, dhuhr),
      (.asr, asr),
      (.maghrib, maghrib),
      (.isha, isha),
    ]
  }

  func orderedDates() -> [(Prayer, Date)] {
    orderedTimes.compactMap { prayer, comps in
      time(comps, on: day).map { (prayer, $0) }
    }
  }

  func mapTimes<T>(_ transform: (Prayer, DateComponents) -> T) -> [T] {
    orderedTimes.map(transform)
  }

  func mapDates<T>(
    _ transform: (Prayer, Date) -> T
  ) -> [T] {
    orderedDates().map(transform)
  }

  subscript(_ prayer: Prayer) -> DateComponents {
    switch prayer {
    case .fajr: return fajr
    case .sunrise: return sunrise
    case .dhuhr: return dhuhr
    case .asr: return asr
    case .maghrib: return maghrib
    case .isha: return isha
    }
  }
}

extension PrayerTimes: Sequence {
  public typealias Element = (Prayer, DateComponents)
  public func makeIterator() -> IndexingIterator<[(Prayer, DateComponents)]> {
    orderedTimes.makeIterator()
  }
}

private func time(
  _ components: DateComponents,
  on day: Date,
) -> Date? {
  let calendar = Calendar.current
  return calendar.date(byAdding: components, to: calendar.startOfDay(for: day))
}

private func minutesToComponents(_ minutes: Int) -> DateComponents {
  DateComponents(hour: minutes / 60, minute: minutes % 60)
}

private func componentsToMinutes(_ components: DateComponents) -> Int {
  (components.hour ?? 0) * 60 + (components.minute ?? 0)
}
