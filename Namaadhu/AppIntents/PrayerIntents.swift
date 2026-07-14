import AppIntents
import Foundation

enum PrayerIntentValue: String, AppEnum {
  case fajr
  case sunrise
  case dhuhr
  case asr
  case maghrib
  case isha

  static let typeDisplayRepresentation: TypeDisplayRepresentation = "Prayer"

  static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
    .fajr: "Fajr",
    .sunrise: "Sunrise",
    .dhuhr: "Dhuhr",
    .asr: "Asr",
    .maghrib: "Maghrib",
    .isha: "Isha",
  ]

  var prayer: Prayer { Prayer(rawValue: rawValue)! }
}

enum SunnahPrayerSelection: String, AppEnum {
  case current
  case fajr
  case dhuhr
  case asr
  case maghrib
  case isha

  static let typeDisplayRepresentation: TypeDisplayRepresentation = "Prayer"

  static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
    .current: "Current Prayer",
    .fajr: "Fajr",
    .dhuhr: "Dhuhr",
    .asr: "Asr",
    .maghrib: "Maghrib",
    .isha: "Isha",
  ]

  var prayer: Prayer? { Prayer(rawValue: rawValue) }
}

struct GetNextPrayerIntent: AppIntent {
  static let title: LocalizedStringResource = "Get Next Prayer"
  static let description = IntentDescription(
    "Get the next prayer time for your selected island."
  )

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let dialog = try await MainActor.run {
      let result = try PrayerIntentDataStore().nextPrayer()
      let prayerName = String(localized: result.state.upcomingPrayer.displayName)
      let time = result.state.upcomingPrayerDate.formatted(
        date: .omitted,
        time: .shortened
      )

      return "The next prayer in \(result.island.name) is \(prayerName) at \(time)."
    }

    return .result(dialog: "\(dialog)")
  }
}

struct GetPrayerTimeIntent: AppIntent {
  static let title: LocalizedStringResource = "Get Prayer Time"
  static let description = IntentDescription(
    "Get a prayer time for your selected island."
  )

  @Parameter(title: "Prayer")
  var prayer: PrayerIntentValue

  @Parameter(title: "Date", default: .now)
  var date: Date

  static var parameterSummary: some ParameterSummary {
    Summary("Get \(\.$prayer) time on \(\.$date)")
  }

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let dialog = try await MainActor.run {
      let result = try PrayerIntentDataStore().prayerTime(
        for: prayer.prayer,
        on: date
      )
      let prayerName = String(localized: prayer.prayer.displayName)
      let time = result.time.formatted(date: .omitted, time: .shortened)
      let day = date.formatted(date: .abbreviated, time: .omitted)

      return "\(prayerName) in \(result.island.name) is at \(time) on \(day)."
    }

    return .result(dialog: "\(dialog)")
  }
}

struct GetSunnahRakahsIntent: AppIntent {
  static let title: LocalizedStringResource = "Get Sunnah Rak'ahs"
  static let description = IntentDescription(
    "Get the Sunnah rak'ahs for the current prayer or a selected prayer."
  )

  @Parameter(title: "Prayer", default: .current)
  var prayer: SunnahPrayerSelection

  static var parameterSummary: some ParameterSummary {
    Summary("Get Sunnah Rak'ahs for \(\.$prayer)")
  }

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let dialog = try await MainActor.run {
      let store = PrayerIntentDataStore()
      let selectedPrayer = try prayer.prayer ?? store.currentPrayer()
      let prayerName = String(localized: selectedPrayer.displayName)

      guard let rakahs = selectedPrayer.sunnahRakahs else {
        return "There are no Sunnah rak'ahs listed for \(prayerName)."
      }

      return "\(prayerName): \(rakahs.summary) Sunnah rak'ahs."
    }

    return .result(dialog: "\(dialog)")
  }
}

struct NamaadhuAppShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: GetNextPrayerIntent(),
      phrases: [
        "What is my next prayer in \(.applicationName)",
        "Get next prayer with \(.applicationName)",
      ],
      shortTitle: "Next Prayer",
      systemImageName: "clock"
    )

    AppShortcut(
      intent: GetPrayerTimeIntent(),
      phrases: ["Get prayer time with \(.applicationName)"],
      shortTitle: "Prayer Time",
      systemImageName: "clock.badge.checkmark"
    )

    AppShortcut(
      intent: GetSunnahRakahsIntent(),
      phrases: ["Get Sunnah Rak'ahs with \(.applicationName)"],
      shortTitle: "Sunnah Rak'ahs",
      systemImageName: "hands.sparkles"
    )
  }
}

private struct PrayerIntentDataStore {
  private let database = DatabaseService(reader: AppDatabase.shared)

  func nextPrayer(at date: Date = .now) throws -> (island: Island, state: PrayerState) {
    let island = try selectedIsland()
    let today = try prayerTimes(for: island, on: date)
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date)
      .flatMap { try? prayerTimes(for: island, on: $0) }

    guard
      let state = PrayerSchedule.state(
        at: date,
        today: today,
        tomorrow: tomorrow
      )
    else {
      throw PrayerIntentDataError.noUpcomingPrayer
    }

    return (island, state)
  }

  func currentPrayer(at date: Date = .now) throws -> Prayer {
    try nextPrayer(at: date).state.currentPrayer
  }

  func prayerTime(for prayer: Prayer, on date: Date) throws -> (island: Island, time: Date) {
    let island = try selectedIsland()
    let prayerTimes = try prayerTimes(for: island, on: date)
    let startOfDay = Calendar.current.startOfDay(for: date)

    guard let time = Calendar.current.date(byAdding: prayerTimes[prayer], to: startOfDay) else {
      throw PrayerIntentDataError.invalidPrayerTime
    }

    return (island, time)
  }

  private func selectedIsland() throws -> Island {
    guard let data = AppGroup.userDefaults?.data(forKey: "selectedIslandData") else {
      throw PrayerIntentDataError.noSelectedIsland
    }

    do {
      return try JSONDecoder().decode(Island.self, from: data)
    } catch {
      throw PrayerIntentDataError.invalidSelectedIsland
    }
  }

  private func prayerTimes(for island: Island, on date: Date) throws -> PrayerTimes {
    guard let prayerTimes = try database.fetchPrayerTime(for: island, in: date) else {
      throw PrayerIntentDataError.noPrayerTimes
    }

    return prayerTimes
  }
}

private enum PrayerIntentDataError: LocalizedError {
  case noSelectedIsland
  case invalidSelectedIsland
  case noPrayerTimes
  case noUpcomingPrayer
  case invalidPrayerTime

  var errorDescription: String? {
    switch self {
    case .noSelectedIsland:
      "Select an island in Namaadhu first."
    case .invalidSelectedIsland:
      "Namaadhu could not read the selected island."
    case .noPrayerTimes:
      "Prayer times are unavailable for that date."
    case .noUpcomingPrayer:
      "Namaadhu could not determine the next prayer."
    case .invalidPrayerTime:
      "Namaadhu could not determine that prayer time."
    }
  }
}
