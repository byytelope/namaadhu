import Foundation

enum Prayer: String, CaseIterable, Identifiable, Codable, Hashable, Sendable {
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

  func orderedDates(calendar: Calendar = .current) -> [(Prayer, Date)] {
    let startOfDay = calendar.startOfDay(for: date)

    return Prayer.allCases.compactMap { prayer in
      calendar.date(byAdding: self[prayer], to: startOfDay)
        .map { (prayer, $0) }
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
      let upcomingIndex = occurrences.firstIndex(where: { $0.1 > date })
    else {
      return nil
    }

    let upcoming = occurrences[upcomingIndex]
    let currentPrayer =
      upcomingIndex > 0
      ? occurrences[upcomingIndex - 1].0
      : .isha

    return PrayerState(
      currentPrayer: currentPrayer,
      upcomingPrayer: upcoming.0,
      upcomingPrayerDate: upcoming.1
    )
  }
}
