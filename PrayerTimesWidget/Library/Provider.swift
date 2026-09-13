import GRDB
import Foundation
import WidgetKit

struct Provider: TimelineProvider {
  private let db = DatabaseService(reader: AppDatabase.shared)

  func placeholder(in context: Context) -> PrayerTimesEntry {
    .placeholder
  }

  func getSnapshot(
    in context: Context,
    completion: @escaping (PrayerTimesEntry) -> Void
  ) {
    let entry = makeEntry(for: Date())
    completion(entry)
  }

  func getTimeline(
    in context: Context,
    completion: @escaping (Timeline<PrayerTimesEntry>) -> Void
  ) {
    let now = Date()
    let currentEntry = makeEntry(for: now)

    guard let firstTransitionDate = currentEntry.upcomingPrayerDate else {
      completion(
        Timeline(
          entries: [currentEntry],
          policy: .after(now.addingTimeInterval(3600))
        )
      )
      return
    }

    var entries = [currentEntry]
    var transitionDate = firstTransitionDate

    // Preload prayer transitions so WidgetKit can change the displayed prayer
    // even while the containing app is suspended.
    while entries.count < 8 {
      let transitionEntry = makeEntry(for: transitionDate)

      guard
        let nextTransitionDate = transitionEntry.upcomingPrayerDate,
        nextTransitionDate > transitionDate
      else {
        break
      }

      entries.append(transitionEntry)
      transitionDate = nextTransitionDate
    }

    let policy: TimelineReloadPolicy =
      entries.count > 1 ? .atEnd : .after(firstTransitionDate)
    completion(Timeline(entries: entries, policy: policy))
  }

  private func makeEntry(for date: Date) -> PrayerTimesEntry {
    guard let island = loadSelectedIsland() else {
      return .empty
    }

    guard let todayPrayerTimes = loadPrayerTimes(for: island, on: date) else {
      return .empty
    }

    guard
      let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date)
    else {
      return .empty
    }

    let tomorrowPrayerTimes = loadPrayerTimes(for: island, on: tomorrow)

    guard
      let state = PrayerSchedule.state(
        at: date,
        today: todayPrayerTimes,
        tomorrow: tomorrowPrayerTimes
      )
    else {
      return .empty
    }

    var currentPrayerDate = todayPrayerTimes.orderedDates()
      .last(where: { $0.date <= date })?.date
    if currentPrayerDate == nil,
      let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date)
    {
      currentPrayerDate = loadPrayerTimes(for: island, on: yesterday)?
        .orderedDates().last(where: { $0.date <= date })?.date
    }

    return PrayerTimesEntry(
      date: date,
      selectedIslandName: island.name,
      currentPrayer: state.currentPrayer,
      upcomingPrayer: state.upcomingPrayer,
      upcomingPrayerDate: state.upcomingPrayerDate,
      prayerTimes: todayPrayerTimes,
      currentPrayerDate: currentPrayerDate
    )
  }

  private func loadSelectedIsland() -> Island? {
    guard
      let data = AppGroup.userDefaults?.data(forKey: "selectedIslandData")
    else {
      return nil
    }

    do {
      return try JSONDecoder().decode(Island.self, from: data)
    } catch {
      print("Widget: failed to decode selectedIsland:", error)
      return nil
    }
  }

  private func loadPrayerTimes(for island: Island, on date: Date)
    -> PrayerTimes?
  {
    do {
      return try db.fetchPrayerTime(for: island, in: date)
    } catch let decodingError as RowDecodingError {
      print("Widget RowDecodingError:", decodingError)
      return nil
    } catch {
      print("Widget error loading prayer times:", error)
      return nil
    }
  }
}
