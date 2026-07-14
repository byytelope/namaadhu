import Foundation

enum Prayer: String, CaseIterable, Identifiable, Codable, Hashable, Sendable {
  case fajr, sunrise, dhuhr, asr, maghrib, isha

  var id: String { rawValue }

  var displayName: LocalizedStringResource {
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

  var sunnahRakahs: SunnahRakahs? {
    switch self {
    case .fajr:
      .init(before: 2)
    case .sunrise:
      nil
    case .dhuhr:
      .init(before: 4, after: 2)
    case .asr:
      .init(before: 4)
    case .maghrib:
      .init(after: 2)
    case .isha:
      .init(after: 2, witr: 3)
    }
  }
}

struct SunnahRakahs: Sendable, Equatable {
  let before: Int
  let after: Int
  let witr: Int

  init(before: Int = 0, after: Int = 0, witr: Int = 0) {
    self.before = before
    self.after = after
    self.witr = witr
  }

  var summary: String {
    [
      before > 0 ? "\(before) before" : nil,
      after > 0 ? "\(after) after" : nil,
      witr > 0 ? "Witr \(witr)" : nil,
    ]
    .compactMap(\.self)
    .joined(separator: " · ")
  }
}

struct PrayerTimeOccurrence: Identifiable, Sendable, Equatable {
  let prayer: Prayer
  let date: Date

  var id: Prayer { prayer }
}

struct PrayerTimes: Sendable, Equatable {
  struct Values: Sendable, Equatable {
    let fajr: Int
    let sunrise: Int
    let dhuhr: Int
    let asr: Int
    let maghrib: Int
    let isha: Int

    subscript(_ prayer: Prayer) -> Int {
      switch prayer {
      case .fajr: fajr
      case .sunrise: sunrise
      case .dhuhr: dhuhr
      case .asr: asr
      case .maghrib: maghrib
      case .isha: isha
      }
    }

    func applyingOffset(_ offset: Int) -> Values {
      Values(
        fajr: fajr + offset,
        sunrise: sunrise + offset,
        dhuhr: dhuhr + offset,
        asr: asr + offset,
        maghrib: maghrib + offset,
        isha: isha + offset
      )
    }
  }

  let categoryId: Int
  let date: Date

  private let values: Values

  init(
    categoryId: Int,
    date: Date,
    values: Values
  ) {
    self.categoryId = categoryId
    self.date = date
    self.values = values
  }

  subscript(_ prayer: Prayer) -> DateComponents {
    let minutes = values[prayer]
    return DateComponents(hour: minutes / 60, minute: minutes % 60)
  }

  func applyingOffset(_ offset: Int) -> PrayerTimes {
    guard offset != 0 else { return self }

    return PrayerTimes(
      categoryId: categoryId,
      date: date,
      values: values.applyingOffset(offset)
    )
  }

  func orderedDates(calendar: Calendar = .current) -> [PrayerTimeOccurrence] {
    let startOfDay = calendar.startOfDay(for: date)

    return Prayer.allCases.compactMap { prayer in
      calendar.date(byAdding: self[prayer], to: startOfDay)
        .map {
          PrayerTimeOccurrence(prayer: prayer, date: $0)
        }
    }
  }
}

struct PrayerState: Sendable, Equatable {
  let currentPrayer: Prayer
  let upcomingPrayer: Prayer
  let upcomingPrayerDate: Date
}

enum PrayerSchedule {
  static func state(
    at date: Date,
    today: PrayerTimes,
    tomorrow: PrayerTimes?
  ) -> PrayerState? {
    var occurrences = today.orderedDates()
    if let tomorrow {
      occurrences.append(contentsOf: tomorrow.orderedDates())
    }

    guard
      let upcomingIndex = occurrences.firstIndex(where: { $0.date > date })
    else {
      return nil
    }

    let upcoming = occurrences[upcomingIndex]
    let currentPrayer =
      upcomingIndex > 0
      ? occurrences[upcomingIndex - 1].prayer
      : .isha

    return PrayerState(
      currentPrayer: currentPrayer,
      upcomingPrayer: upcoming.prayer,
      upcomingPrayerDate: upcoming.date
    )
  }
}
