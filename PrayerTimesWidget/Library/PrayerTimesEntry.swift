import Foundation
import WidgetKit

struct PrayerTimesEntry: TimelineEntry {
  let date: Date
  let selectedIslandName: String?
  let currentPrayer: Prayer?
  let upcomingPrayer: Prayer?
  let upcomingPrayerDate: Date?
  let prayerTimes: PrayerTimes?

  static let empty = PrayerTimesEntry(
    date: Date(),
    selectedIslandName: nil,
    currentPrayer: nil,
    upcomingPrayer: nil,
    upcomingPrayerDate: nil,
    prayerTimes: nil
  )

  static let placeholder = PrayerTimesEntry(
    date: Date(),
    selectedIslandName: "K. Malé",
    currentPrayer: .dhuhr,
    upcomingPrayer: .asr,
    upcomingPrayerDate: Date().addingTimeInterval(3600),
    prayerTimes: mockPrayerTimes[0]
  )
}
