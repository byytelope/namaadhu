import GRDB
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
  private let db = DatabaseService(reader: AppDatabase.shared)

  func placeholder(in context: Context) -> PrayerTimerEntry {
    .placeholder
  }

  func getSnapshot(
    in context: Context,
    completion: @escaping (PrayerTimerEntry) -> Void
  ) {
    let entry = makeEntry(for: Date())
    completion(entry)
  }

  func getTimeline(
    in context: Context,
    completion: @escaping (Timeline<PrayerTimerEntry>) -> Void
  ) {
    let now = Date()

    let entry = makeEntry(for: now)
    let reloadDate = entry.upcomingPrayerDate ?? now.addingTimeInterval(3600)

    let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
    completion(timeline)
  }

  private func makeEntry(for date: Date) -> PrayerTimerEntry {
    guard let island = loadSelectedIsland() else {
      return .empty
    }

    let calendar = Calendar.current

    guard let todayPrayerTimes = loadPrayerTimes(for: island, on: date) else {
      return .empty
    }

    let tomorrow = calendar.date(byAdding: .day, value: 1, to: date)!
    let tomorrowPrayerTimes = loadPrayerTimes(for: island, on: tomorrow)

    var allOccurrences: [(Prayer, Date)] = todayPrayerTimes.orderedDates()

    if let tomorrowPT = tomorrowPrayerTimes {
      let tomorrowOccurrences = tomorrowPT.orderedDates()
      allOccurrences.append(contentsOf: tomorrowOccurrences)
    }

    guard let nextTuple = allOccurrences.first(where: { $0.1 > date }) else {
      return .empty
    }

    var currentPrayer: Prayer?
    if let upcomingIndex = allOccurrences.firstIndex(where: {
      $0.0 == nextTuple.0 && $0.1 == nextTuple.1
    }) {
      if upcomingIndex > 0 {
        currentPrayer = allOccurrences[upcomingIndex - 1].0
      } else {
        currentPrayer = .isha
      }
    }

    return PrayerTimerEntry(
      date: date,
      selectedIslandName: island.name,
      currentPrayer: currentPrayer,
      upcomingPrayer: nextTuple.0,
      upcomingPrayerDate: nextTuple.1
    )
  }

  private func loadSelectedIsland() -> Island? {
    guard
      let data = UserDefaults(suiteName: "group.me.shadhaan.Namaadhu")!.data(
        forKey: "selectedIslandData"
      )
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
