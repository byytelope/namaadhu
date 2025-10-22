import Foundation
import GRDB

enum Prayer: String, CaseIterable, Identifiable, Codable {
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
  let date: Date

  let fajr: DateComponents
  let sunrise: DateComponents
  let dhuhr: DateComponents
  let asr: DateComponents
  let maghrib: DateComponents
  let isha: DateComponents

  init(row: Row) {
    self.categoryId = row["category_id"] ?? 0

    let dayIndex: Int = row["date"] ?? 0
    self.date = dateFromDayOfLeapYear(dayIndex)

    func comps(_ col: String) -> DateComponents {
      let minutes: Int = row[col] ?? 0
      return minutesToComponents(minutes)
    }

    self.fajr = comps(Prayer.fajr.dbColumn)
    self.sunrise = comps(Prayer.sunrise.dbColumn)
    self.dhuhr = comps(Prayer.dhuhr.dbColumn)
    self.asr = comps(Prayer.asr.dbColumn)
    self.maghrib = comps(Prayer.maghrib.dbColumn)
    self.isha = comps(Prayer.isha.dbColumn)
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
    self.date = dateFromDayOfLeapYear(dayOfYear)

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
      time(comps, on: date).map { (prayer, $0) }
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

private func dateFromDayOfLeapYear(_ dayIndex: Int) -> Date {
  let calendar = Calendar.current
  let refYear = 2000
  guard
    let startOfRefYear = calendar.date(
      from: DateComponents(year: refYear, month: 1, day: 1)
    )
  else {
    let fallbackYear = calendar.component(.year, from: .now)
    let startOfYear = calendar.date(
      from: DateComponents(year: fallbackYear, month: 1, day: 1)
    )!
    return calendar.date(byAdding: .day, value: dayIndex, to: startOfYear)!
  }

  let refDate = calendar.date(
    byAdding: .day,
    value: dayIndex,
    to: startOfRefYear
  )!

  let md = calendar.dateComponents([.month, .day], from: refDate)
  let targetMonth = md.month ?? 1
  var targetDay = md.day ?? 1
  let finalYear = calendar.component(.year, from: .now)
  if targetMonth == 2 && targetDay == 29 {
    let febFirst = calendar.date(
      from: DateComponents(year: finalYear, month: 2, day: 1)
    )!
    let daysInFeb = calendar.range(of: .day, in: .month, for: febFirst)!.count
    if daysInFeb < 29 {
      targetDay = 28
    }
  }

  let finalComponents = DateComponents(
    year: finalYear,
    month: targetMonth,
    day: targetDay
  )

  return calendar.date(from: finalComponents)!
}
