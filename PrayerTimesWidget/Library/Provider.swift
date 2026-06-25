import GRDB
import SwiftUI
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

    let entry = makeEntry(for: now)
    let reloadDate = entry.upcomingPrayerDate ?? now.addingTimeInterval(3600)

    let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
    completion(timeline)
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

    return PrayerTimesEntry(
      date: date,
      selectedIslandName: island.name,
      currentPrayer: state.currentPrayer,
      upcomingPrayer: state.upcomingPrayer,
      upcomingPrayerDate: state.upcomingPrayerDate,
      prayerTimes: todayPrayerTimes
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
